// belts.scad -- v3 belt paths (unchanged from v2: same pulleys, motor XY and belt plane) (visualisation / clearance checks; not printed) + belt maths echo.
// Both GT2-6 loops run in ONE plane, z = z_belt (-7.5), just behind the back plate:
//   A: knob A (66T printed) -> motor A (16T metal, 10 mm-belt type), 158 mm loop
//   B: knob B (66T printed) -> motor B (16T metal),                     220 mm loop
// The belt follows the knob pulley (flanged) as the knob walks +/-2.6 mm; it slides on the
// 11 mm face of the metal 16T, whose plane is matched by sliding the motor in its pocket.

include <mount_params_defaults.scad>
include <attachment_params.scad>
use <gt2_pulley.scad>
use <knob_extension.scad>
use <mirror_mount.scad>

$fn = 64;
belt_t = 1.38;                       // GT2 belt total thickness
belt_out = 1.13;                     // belt back outside the pitch line
belt_in  = 0.20;                     // pitch line to the belt's inner land (0.05 outside the tooth tips: no coincident faces)

// closed loop around two pitch circles: band from (pitch - belt_in) to (pitch + belt_out)
module belt_loop(p1, r1, p2, r2, z, w = belt_w) {
    translate([0, 0, z - w/2]) linear_extrude(w) difference() {
        hull() { translate(p1) circle(r = r1 + belt_out); translate(p2) circle(r = r2 + belt_out); }
        hull() { translate(p1) circle(r = r1 - belt_in);  translate(p2) circle(r = r2 - belt_in); }
    }
}

// purchased GT2 16T, 5 mm bore, 10 mm-belt width (11 mm face) -- stand-in, local +Z = away from motor
// z = 0 at its front flange (toward the motor), hub at the far end (mounted HUB-OUT).
module gt2_metal_pulley_wide() {
    difference() {
        union() {
            cylinder(d = mp_flange_d, h = mp_flange_t);
            translate([0, 0, mp_flange_t]) cylinder(d = gt2_od(motor_teeth), h = mp_face);
            translate([0, 0, mp_flange_t + mp_face]) cylinder(d = mp_flange_d, h = mp_flange_t);
            translate([0, 0, 2*mp_flange_t + mp_face]) cylinder(d = mp_hub_d, h = mp_hub_l);
        }
        translate([0, 0, -1]) cylinder(d = motor_shaft_d, h = mp_len + 2, $fn = 24);
    }
}
// global placement of motor pulley i for ramp shift s and slide dz: front flange at z_flange - pilot - gap
module motor_pulley(i, s = 0, dz = 0) {
    m = motor_xy(i, s);
    // v4.1: hub-in -> the hub (local far end) faces the motor: flip the stand-in so its hub is at the pilot side
    if (mp_hub_in) translate([m[0], m[1], z_flange + dz - motor_pilot_h - mp_gap - mp_len]) gt2_metal_pulley_wide();
    else translate([m[0], m[1], z_flange + dz - motor_pilot_h - mp_gap]) mirror([0, 0, 1]) gt2_metal_pulley_wide();
}
// belt i for ramp shift s and knob walk w (the belt follows the knob pulley)
module belt(i, s = 0, w = 0) {
    belt_loop(dknob[i], D2(i)/2, motor_xy(i, s), D1/2, z_belt + w, belt_w);
}

module belts_scene() {
    mirror_mount(mount_type, true, [0, 0]);
    hand() for (i = [0, 1]) {
        color([0.98, 0.85, 0.10]) translate([dknob[i][0], dknob[i][1], -knob_len]) knob_extension(i);
        color([0.78, 0.78, 0.82]) motor_pulley(i, s_req(i));
        color([0.55, 0.05, 0.05]) belt(i, s_req(i));
    }
}

view_yup = false;
if (is_undef(ASSEMBLY)) rotate(view_yup ? [90, 0, 0] : [0, 0, 0]) belts_scene();

for (i = [0, 1]) {
    C0 = c_for_len(belt_L[i], i);
    m = motor_xy(i, s_req(i));
    wrap_small = 180 - 2*asin((D2(i) - D1)/(2*norm(m - dknob[i])));
    echo(str("BELT ", i == 0 ? "A" : "B", " (", mount_type, "): ", belt_L[i], " mm loop (", belt_L[i]/2, "T), ",
             knob_teeth[i], "T:", motor_teeth, "T = ", knob_teeth[i]/motor_teeth, ":1 | zero-slack C ", C0,
             " | motor ", m, " at ramp s = ", s_req(i), " (range +/-", s_range, ") | C ", norm(m - dknob[i]),
             " | wrap on 16T ", wrap_small, " deg = ", wrap_small/360*motor_teeth, " teeth"));
}
