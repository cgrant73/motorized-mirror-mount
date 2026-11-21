// knob_extension.scad -- v3 SHORT knob cap: printed 66T GT2 pulley right on the knob, clamped by
// 3 set screws. One part per knob (A, B), printed per mount type (bore = knob_d + kx_bore_clr, v4: + 0.6 for MJF).
// v3: no magnet pocket and no nose (the AS5048A output encoder is gone; the encoder is on the motor).
// The 1.6 mm end wall seats the cap axially on the knob end and has a hex-key hole for manual override.
//
// Local frame: axis = Z, z = 0 at the knob END face (the cap's floor seats on it), +Z toward the
// mount. Global placement:  translate([knob_pos[i][0], knob_pos[i][1], -knob_len]) knob_extension(i);
//
//   z (local)                      what
//   -kx_floor_t .. 0               end wall, D3.2 hex-key hole on the axis
//   0 .. pulley rear               set-screw hub D26 over the knurled head: 3x M3 at 120 deg into
//                                  M3 heat-set inserts, axis kx_screw_dz in front of the knob end
//   pulley rear .. pulley front    66T GT2 pulley, 6.6 mm face between 1 mm flanges (it GUIDES the
//                                  belt; the belt walks on the wide metal 16T as the knob moves)
//                                  front face at global z = kp_front_z (-3.2): 2.6 mm knob walk + 0.6
// Print: FRONT face (pulley flange) down, axis vertical -> crisp teeth, no supports.

include <mount_params_defaults.scad>
include <attachment_params.scad>
use <gt2_pulley.scad>

which = 0;
$fn = 96;

function kx_pf(i) = kp_front_z + knob_len;          // local z of the pulley front face (KM100: 14.1)
function kx_pr(i) = kx_pf(i) - kp_len;              // local z of the pulley rear face  (KM100: 5.5)

module knob_extension(i = 0) {
    if (kx_grip == "inclined") knob_extension_incl(i); else knob_extension_radial(i);
}

// v4.2: set-screw axes in the cap's local frame (shared with assembly.scad and the checks).
// Radial (KM100): screw from the knob surface outward at z = kx_screw_dz. Inclined (short knobs): from the contact point
// on the knurl (r = knob_d/2, z = kx_incl_zc) outward and REARWARD at kx_incl_ang from radial; +Z of children = screw axis
module cap_screw_frames() {
    for (a = [0, 120, 240]) rotate(a + 90)
        if (kx_grip == "inclined") translate([knob_d/2, 0, kx_incl_zc]) rotate([0, 90 + kx_incl_ang, 0]) children();
        else translate([knob_d/2, 0, kx_screw_dz]) rotate([0, 90, 0]) children();
}
// set-screw solids (visual / checks): tip 0.02 off the knurl, shank 0.1 under the clearance hole
module cap_screw_solids(L = (kx_grip == "inclined") ? kx_incl_L : 8) cap_screw_frames() translate([0, 0, 0.02]) cylinder(d = 2.9, h = L, $fn = 16);

// v4.2 short-knob cap: [rear hub with 3 inclined M3 inserts][end wall seats on the knob end][pulley over the knurled head]
module knob_extension_incl(i = 0) {
    bore = knob_d + kx_bore_clr;
    pr = kx_pr(i); pf = kx_pf(i);
    n = knob_teeth[i];
    assert(pr > 0.3, "pulley rear face must be in front of the knob end face (kp_front_z too far back for this knob_len)");
    difference() {
        union() {
            translate([0, 0, pr]) gt2_pulley(n, kp_face, kp_flange_t, kp_flange_x, kp_add_w);
            translate([0, 0, -kx_rear_t + 1]) cylinder(d = kx_hub_d_incl, h = pr + kx_rear_t - 1 + e);
            translate([0, 0, -kx_rear_t]) cylinder(d1 = kx_hub_d_incl - 2, d2 = kx_hub_d_incl, h = 1 + e);
            // solid web inside the tooth root over the knurled head (the inclined screws pass through it)
            translate([0, 0, pr]) cylinder(d = gt2_od(n) - 2, h = kp_len - e);
        }
        cylinder(d = bore, h = pf + 1);                                              // knob bore, end wall at z = 0
        translate([0, 0, pf - 0.8]) cylinder(d1 = bore, d2 = bore + 1.6, h = 0.81);
        translate([0, 0, -kx_rear_t - 1]) cylinder(d = kx_key_d, h = kx_rear_t + 2, $fn = 32);   // hex-key hole
        cap_screw_frames() {
            translate([0, 0, -1.5]) cylinder(d = m3_clr, h = kx_incl_L - ins3_l + 1.5 + e, $fn = 24);   // clearance through the web
            translate([0, 0, kx_incl_L - ins3_l]) cylinder(d = ins3_d, h = ins3_l + e, $fn = 24);     // insert, flush at t = L
            translate([0, 0, kx_incl_L]) cylinder(d = 7.0, h = 25, $fn = 32);                         // spot face square to the axis
        }
        // index groove at screw #1 on the hub, label on the rear face
        rotate(90) translate([kx_hub_d_incl/2 - 0.6, -0.5, -kx_rear_t + 1]) cube([1, 1, kx_rear_t - 1 + pr - 0.5]);
        translate([0, -kx_hub_d_incl/2 + 4.2, -kx_rear_t - e]) mirror([1, 0, 0])
            linear_extrude(0.6) text(i == 0 ? "A" : "B", size = 3.5, halign = "center", valign = "center");
    }
}

module knob_extension_radial(i = 0) {
    bore = knob_d + kx_bore_clr;
    pr = kx_pr(i); pf = kx_pf(i);
    n = knob_teeth[i];
    difference() {
        union() {
            translate([0, 0, pr]) gt2_pulley(n, kp_face, kp_flange_t, kp_flange_x, kp_add_w);
            // set-screw hub + end wall, 1 mm 45 deg chamfer on the rear edge
            translate([0, 0, -kx_floor_t + 1]) cylinder(d = kx_hub_d, h = pr + kx_floor_t - 1 + e);
            translate([0, 0, -kx_floor_t]) cylinder(d1 = kx_hub_d - 2, d2 = kx_hub_d, h = 1 + e);
        }
        // knob bore (open toward the mount); the knob end face seats on the floor at z = 0
        cylinder(d = bore, h = pf + 1);
        translate([0, 0, pf - 0.8]) cylinder(d1 = bore, d2 = bore + 1.6, h = 0.81);
        // hex-key hole through the end wall (manual adjustment with the drivers off)
        translate([0, 0, -kx_floor_t - 1]) cylinder(d = kx_key_d, h = kx_floor_t + 2, $fn = 32);
        // material-saving pocket in the pulley web from the FRONT (leaves 6 spokes and a 3 mm rear web)
        translate([0, 0, pr + 3]) difference() {
            cylinder(d = gt2_od(n) - 6, h = kp_len);
            cylinder(d = bore + 5, h = kp_len);
            for (a = [0:60:359]) rotate(a) translate([0, -1.5, 0]) cube([gt2_od(n), 3, kp_len]);
        }
        // 3x M3 set screws at 120 deg on the knurled head: insert from outside + tap drill
        for (a = [0, 120, 240]) rotate(a + 90)
            translate([0, 0, kx_screw_dz]) rotate([0, 90, 0]) {
                cylinder(d = m3_clr, h = kx_hub_d);          // v4: clearance (was tap drill = printed thread)
                translate([0, 0, kx_hub_d/2 - ins3_l]) cylinder(d = ins3_d, h = ins3_l + 1);
            }
        // index groove in line with set screw #1 (on the hub)
        rotate(90) translate([kx_hub_d/2 - 0.6, -0.5, 0.5]) cube([1, 1, pr - 1]);
        // label A / B on the rear face of the rear flange (outside the hub)
        translate([0, 0, pr - e]) rotate(-90) translate([kx_hub_d/2 + 3.2, 0, 0]) rotate(90) mirror([1, 0, 0])
            linear_extrude(0.6) text(i == 0 ? "A" : "B", size = 3.5, halign = "center", valign = "center");
    }
}
e = 0.01;

// print pose: pulley front face on the bed
module knob_extension_print(i = 0) {
    translate([0, 0, kx_pf(i)]) rotate([180, 0, 0]) knob_extension(i);
}

echo(str("KNOB CAP v4.2 (", kx_grip, " grip) ", which == 0 ? "A" : "B", " (", mount_type, "): ", knob_teeth[which], "T PD=", gt2_pd(knob_teeth[which]),
         " OD=", gt2_od(knob_teeth[which]), " flange D=", gt2_pd(knob_teeth[which]) + 2*kp_flange_x,
         " | local z ", (kx_grip == "inclined" ? -kx_rear_t : -kx_floor_t), "..", kx_pf(which),
         " | global z ", -knob_len - (kx_grip == "inclined" ? kx_rear_t : kx_floor_t), "..", kp_front_z, " belt plane ", z_belt,
         " | bore ", knob_d + kx_bore_clr));

if (is_undef(ASSEMBLY)) knob_extension_print(which);
