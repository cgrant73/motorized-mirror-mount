// clearance_check.scad -- v3 CGAL interference checks. Empty result == no interference.
//   openscad -o out.stl -D 'mount_type="KM100T"' -D 'check="belts"' -D t=1 -D s=1 checks/clearance_check.scad
// Parameters
//   check : "mount"   attachment (block, rear bar, motors with encoder housing, connectors and leads,
//                     16T pulleys) vs the mount with the front plate at the 4 corner tilts (+/-4 deg,
//                     +/-4 deg) -- the plate's far corners swing back ~5 mm into the L opening
//           "caps"    block, rear bar and motors vs both knob caps at walk t
//           "belts"   each belt vs everything it must not touch: the mount, the attachment, the
//                     OTHER knob cap and the OTHER motor pulley/motor (belt at walk t, motors at ramp s)
//           "pulleys" cap A vs cap B (same plane) at walks t / -t
//           "motors"  motors (body + encoder + connectors + leads) at ramp s and slide dz vs the base
//                     block (pocket, stop rib, cable channel) and vs the caps at walk t
//   (v2's "encoder" case -- AS5048A board vs cap magnet gap -- no longer exists)
//   t  : knob walk as a fraction of the full +/-2.6 mm (-1..1). +1 = cap toward the mount.
//   s  : motor ramp position as a fraction of the physical +/-1.5 mm (absolute, not relative to s_req)
//   dz : 0 = nominal, -1 = slide fully rearward (z_slide[0]), +1 = fully forward (z_slide[1])
ASSEMBLY = true;
include <../../mount_params.scad>
include <../../attachment_bracket.scad>
include <../../knob_extension.scad>
include <../../belts.scad>
include <../../mount_params.scad>
lug_r = mp(mount_type, "lug_r"); pivot_pos = mp(mount_type, "pivot_pos"); z_hole = mp(mount_type, "z_hole");
side_hole = mp(mount_type, "side_hole"); adj_range_deg = mp(mount_type, "adj_range_deg");
use <../../mirror_mount.scad>

mount_type = "KM100";
check = "mount";
t  = 0;
s  = 0;
dz = 0;
$fn = 32;

W  = t * knob_travel;
function sm(i) = s * s_range;     // physical ramp extremes (absolute), any mount
DZ = dz < 0 ? z_slide[0] : (dz > 0 ? z_slide[1] : 0);

module motor_body(i) {
    m = motor_xy(i, sm(i));
    translate([m[0], m[1], z_flange + DZ]) { nema11_enc_body(); nema11_conn(); nema11_leads(); }
}
module motor_set(i) { motor_body(i); motor_pulley(i, sm(i), DZ); }
// v4.1: set screws at their purchased lengths are part of the checked solids (tips 0.02 off their contact faces,
// shanks 0.1 under the clearance holes): caps M3 x 8 cup point, rear bar M4 x 10, outer cheek M4 x 10,
// inner cheek M3 x 10, foot M3 x 10
// tips start 1.0 mm back from the contact point: the tip-on-part contact is by design (the 30 deg foot screw's flat end and
// the inner-cheek tip on the KM100 lug bulge would otherwise show as 0.2-0.7 mm 'interference'); shanks and heads are checked
module ss(p, d, L, dir) translate(p) point_to(dir) translate([0, 0, 1.0]) cylinder(d = d, h = L - 1.0, $fn = 16);
module cap_screws(i, w = W) translate([dknob[i][0], dknob[i][1], -knob_len + w]) cap_screw_solids();   // v4.2: radial or inclined
module fixed_screws() {
    for (y = cheek_out_y) ss([xR, y, cheek_z[1]], 3.9, 10, [1, 0, 0]);
    for (y = cheek_in_y)  ss([x_leg_in, y, cheek_z[0]], 2.9, 10, [-1, 0, 0]);
    ss(foot_tip, 2.9, 10, foot_dir);
    for (p = rear_screw_pos) ss([p[0], p[1], 0], 3.9, 10, [0, 0, -1]);
}
module cap(i, w = W) { translate([dknob[i][0], dknob[i][1], -knob_len + w]) knob_extension(i); cap_screws(i, w); }
module attachment_fixed() { base_block(); rear_bar(); fixed_screws(); }

module mount_tilted() {
    // 0.05 mm drop: ignore the designed resting contact of the pad on the lug crown
    translate([0, -0.05, 0]) {
        mirror_mount(mount_type, false, [0, 0]);
        pv = mp(mount_type, "pivot_pos"); piv = [pv[0], pv[1], back_t + gap/2];
        for (a = [-1, 1], b = [-1, 1])
            translate(piv) rotate([a*adj_range_deg, b*adj_range_deg, 0]) translate(-piv) front_assembly(mount_type);
    }
}

// v4.2: attachment parts are in the design frame (leg on +X); hand() mirrors them onto a handed = -1 mount
if (check == "mount")   intersection() { hand() union() { attachment_fixed(); for (i = [0, 1]) motor_set(i); } mount_tilted(); }
if (check == "caps")    intersection() { union() { base_block(); rear_bar(); for (i = [0, 1]) motor_set(i); } union() { cap(0); cap(1); } }
if (check == "belts")   for (i = [0, 1]) intersection() {
                            hand() belt(i, sm(i), W);
                            union() { mount_tilted(); hand() union() { attachment_fixed(); cap(1 - i, -W); motor_set(1 - i); motor_body(i); cap_screws(i, W); } }
                        }
if (check == "pulleys") intersection() { cap(0, W); cap(1, -W); }
// v4.1: the set screws vs the parts they pass through / sit next to (tips excluded by the 0.02 offset)
if (check == "screws")  { intersection() { fixed_screws(); union() { base_block(); rear_bar(); } }
                          for (i = [0, 1]) intersection() { cap_screws(i, W); knob_extension_at(i); } }
module knob_extension_at(i) translate([dknob[i][0], dknob[i][1], -knob_len + W]) knob_extension(i);
if (check == "motors")  for (i = [0, 1]) intersection() { motor_set(i); union() { base_block(); cap(0); cap(1); } }

// v4.2: both caps (+ set screws) at walk t vs the STATIONARY back plate and its rear-face keep-outs (MDI spring posts):
// the cap front face must stay off the rear face and the posts over the whole walk (the adjusters themselves are excluded)
if (check == "capmount") intersection() { hand() union() { cap(0, W); cap(1, W); } union() { back_plate(mount_type); rear_keepouts(mount_type); } }
