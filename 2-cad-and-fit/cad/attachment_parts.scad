// attachment_parts.scad -- v3: every printable part laid out flat in its print orientation.
//   1x base block (attachment_bracket)  rear face (z = 0) DOWN: pockets, ramps, stop ribs, cable
//                                       channel, cheeks and post are vertical prisms -> no supports
//   1x rear_bar                         back face DOWN
//   2x knob cap (A, B)                  pulley front face DOWN (teeth vertical)
// Caps are per mount type: -D 'mount_type="KM100T"'. (v2's encoder arm is gone.)
// only = "all" | "rear_bar"   (single-part print poses used for the STLs)

include <mount_params_defaults.scad>
include <attachment_params.scad>
use <attachment_bracket.scad>
use <knob_extension.scad>

only = "all";
$fn = 64;

module rear_bar_print() translate([0, 0, -(-rear_g - rear_t)]) hand() rear_bar();      // back face (z = -7) -> 0

if (only == "rear_bar") rear_bar_print();
else {
    color([0.95, 0.55, 0.15]) hand() base_block();
    color([0.80, 0.40, 0.05]) translate([60, -40, 0]) rear_bar_print();
    color([0.98, 0.85, 0.10]) translate([75, 75, 0]) knob_extension_print(0);
    color([0.98, 0.85, 0.10]) translate([75, 25, 0]) knob_extension_print(1);
}
