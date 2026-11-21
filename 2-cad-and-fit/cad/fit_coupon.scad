// fit_coupon.scad -- MIR_fit_coupon_v1: MJF PA12 fit test for the first print (design review 2026-10-15).
// Print it in the SAME JLC3DP MJF order as the real parts and check it before installing anything:
//   * plate, top row:    M3 heat-set insert holes  D3.8 / 3.9 / 4.0 / 4.1 (CAD uses ins3_d = 3.9)  for McMaster 94459A130 (M3 x 4.3)
//   * plate, bottom row: M4 heat-set insert holes  D5.4 / 5.5 / 5.6 / 5.7 (CAD uses ins4_d = 5.5)  for McMaster 94459A150 (M4 x 4.7)
//     each = insert pocket (insert length + 0.5) + clearance hole through, exactly as in the parts
//   * rings below the plate: KM100 knob bores  knob_d 14.8 + 0.4 / 0.5 / 0.6 (CAD uses + 0.6)
//   * rings above the plate: KM100T knob bores knob_d 13.5 + 0.4 / 0.5 / 0.6
// Smallest size is always at the chamfered (-X) end. Sizes are also engraved.
// What to look for: insert goes in at ~230-245 C iron with light pressure, ends flush, does not spin on an M3/M4 screw
// torqued by hand on a short key; the ring slides onto the real knob by hand with the least rattle.
// Then set ins3_d / ins4_d / kx_bore_clr in attachment_params.scad to the winners and re-export the caps.
// Frame: plate on z = 0 (print pose irrelevant for MJF). Units mm. Volume ~13 cm^3.

include <mount_params_defaults.scad>
include <attachment_params.scad>

$fn = 64;
e = 0.01;
T  = 6.0;                 // plate thickness (M4 pocket 5.2 + 0.8 clearance)
L  = 64;  W = 26;
xs = [8, 24, 40, 56];
m3_d = [3.8, 3.9, 4.0, 4.1];
m4_d = [5.4, 5.5, 5.6, 5.7];
y3 = 19.5;  y4 = 9.5;
ring_h = 5;  ring_w = 2.5;
clr = [0.4, 0.5, 0.6];
rx  = [11, 32, 53];
kd  = [14.8, 13.5];       // KM100 / KM100T knob_d (mount_params.scad, flag E)

module label(t, p, sz = 2.4) translate([p[0], p[1], T - 0.6]) linear_extrude(1)
    text(t, size = sz, font = "Liberation Sans:style=Bold", halign = "left", valign = "center");

module ring(id) difference() {
    cylinder(d = id + 2*ring_w, h = ring_h);
    translate([0, 0, -1]) cylinder(d = id, h = ring_h + 2);
    translate([0, 0, ring_h - 0.6]) cylinder(d1 = id, d2 = id + 1.2, h = 0.61);   // entry chamfer as on the cap
}

module coupon() {
    difference() {
        union() {
            cube([L, W, T]);
            // KM100 rings below (y < 0), KM100T rings above (y > W); each overlaps the plate edge by 1 mm
            for (k = [0 : 2]) {
                id0 = kd[0] + clr[k];  translate([rx[k], -(id0/2 + ring_w) + 1, 0]) ring(id0);
                id1 = kd[1] + clr[k];  translate([rx[k], W + (id1/2 + ring_w) - 1, 0]) ring(id1);
            }
        }
        // orientation chamfer at the -X end (smallest sizes)
        translate([0, -1, T]) rotate([0, 45, 0]) cube([2.5, W + 2, 2.5], center = true);
        for (k = [0 : 3]) {
            // insert pocket from the top face + clearance through (same scheme as insert_hole())
            translate([xs[k], y3, T - ins3_l]) cylinder(d = m3_d[k], h = ins3_l + e);
            translate([xs[k], y3, -1]) cylinder(d = m3_clr, h = T + 2);
            translate([xs[k], y4, T - ins4_l]) cylinder(d = m4_d[k], h = ins4_l + e);
            translate([xs[k], y4, -1]) cylinder(d = m4_clr, h = T + 2);
            label(str(m3_d[k]), [xs[k] + 3.2, y3]);
            label(str(m4_d[k]), [xs[k] + 3.6, y4]);
        }
        for (k = [0 : 2]) {
            label(str("+", clr[k]), [rx[k] - 3.5, 2.2], 2.2);
            label(str("+", clr[k]), [rx[k] - 3.5, W - 2.4], 2.2);
        }
        label("M3", [L - 6.5, y3 + 4.2], 2.0);
        label("M4", [L - 6.5, y4 - 4.4], 2.0);
    }
}

coupon();
