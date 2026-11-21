// gt2_pulley.scad -- shared GT2 (2 mm pitch) pulley profile + toothed body.
// Tooth groove geometry is the widely used GT2-2mm polygon (droftarts' parametric
// pulley, derived from the Gates 2GT spec): groove depth 0.75 mm, groove width 1.49 mm,
// 0.254 mm pitch-line offset.  Use with `use <gt2_pulley.scad>`.

GT2_PITCH = 2.0;
GT2_PLD   = 0.254;               // pitch-line differential (belt pitch line outside OD)

function gt2_pd(t) = t * GT2_PITCH / PI;            // pitch diameter
function gt2_od(t) = gt2_pd(t) - 2 * GT2_PLD;       // outside (tooth-tip) diameter

module gt2_groove_2d() {
    polygon([[0.747183,-0.5],[0.747183,0],[0.647876,0.037218],[0.598311,0.130528],
             [0.578556,0.238423],[0.547158,0.343077],[0.504649,0.443762],[0.451556,0.53975],
             [0.358229,0.636924],[0.247349,0.707597],[0.120329,0.746321],[0,0.750882],
             [-0.120329,0.746321],[-0.247349,0.707597],[-0.358229,0.636924],[-0.451556,0.53975],
             [-0.504649,0.443762],[-0.547158,0.343077],[-0.578556,0.238423],[-0.598311,0.130528],
             [-0.648543,0.037218],[-0.747183,0],[-0.747183,-0.5]]);
}

// 2D toothed profile. add_w / add_d: print compensation (mm) on groove width / depth.
module gt2_profile_2d(teeth, add_w = 0.2, add_d = 0.0) {
    od = gt2_od(teeth);
    tw = 1.494; td = 0.764;
    dist = sqrt(pow(od/2, 2) - pow((tw + add_w)/2, 2));
    difference() {
        circle(d = od, $fn = teeth * 4);
        for (i = [0 : teeth - 1])
            rotate(i * 360 / teeth)
                translate([0, -dist])
                    scale([(tw + add_w)/tw, (td + add_d)/td])
                        gt2_groove_2d();
    }
}

// Toothed pulley body along +Z: [flange][teeth face_w][flange]. No bore (caller cuts it).
module gt2_pulley(teeth, face_w, flange_t = 1.2, flange_extra = 2.0, add_w = 0.2) {
    fd = gt2_pd(teeth) + 2 * flange_extra;
    // lower flange with 45-deg chamfer toward the teeth (prints without support)
    cylinder(d = fd, h = flange_t, $fn = 96);
    translate([0, 0, flange_t - 0.01]) linear_extrude(face_w + 0.02) gt2_profile_2d(teeth, add_w);   // 0.01 overlap: no coincident faces
    translate([0, 0, flange_t + face_w]) cylinder(d = fd, h = flange_t, $fn = 96);
}

// Simple visual stand-in for a purchased metal pulley (e.g. 16T, 5 mm bore, 6 mm belt).
module gt2_metal_pulley(teeth = 16, bore = 5) {
    difference() {
        union() {
            cylinder(d = 13, h = 6.5, $fn = 48);                       // hub
            translate([0, 0, 6.5]) gt2_pulley(teeth, 7, 0.75, 2.4, 0);
        }
        translate([0, 0, -1]) cylinder(d = bore, h = 30, $fn = 24);
    }
}

// demo
gt2_pulley(40, 11);
