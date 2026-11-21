// mirror_mount.scad -- clean ESTIMATE model of Thorlabs KM100 / KM100T kinematic mounts
// Frame and parameter names: cad/CONVENTIONS.md.  Dimensions: cad/mount_params.scad.
//
// Usage:
//   use/include this file, then  mirror_mount("KM100T", show_front=false, tilt=[0,0]);
//   CLI:  openscad -D mount_type="KM100T" -o out.stl mirror_mount.scad
//
// show_front : false hides the moving (front) plate, mirror, pivot ball, springs and tips
// tilt       : [rx, ry] degrees, rotation of the front plate about the pivot ball
//              (rx about +X, ry about +Y); use +/-adj_range_deg for clearance checks.

include <mount_params.scad>

show_front = true;
tilt       = [0, 0];

$fn = 64;

C_BODY  = [0.22, 0.22, 0.25];
C_FRONT = [0.30, 0.30, 0.36];
C_KNOB  = [0.75, 0.75, 0.78];
C_MIRR  = [0.55, 0.80, 1.00];
C_SPRING= [0.80, 0.65, 0.20];

mirror_mount(mount_type, show_front, tilt);

// ---------------------------------------------------------------------------
module mirror_mount(type = "KM100", show_front = true, tilt = [0, 0]) {
    bw = mp(type, "body_w");
    bt = mp(type, "back_t");
    g  = mp(type, "gap");
    pv = mp(type, "pivot_pos");
    piv = [pv[0], pv[1], bt + g / 2];

    color(C_BODY) back_plate(type);
    color(C_SPRING) rear_keepouts(type);
    adjusters(type);
    if (show_front)
        translate(piv) rotate([tilt[0], tilt[1], 0]) translate(-piv)
            front_assembly(type);
}

// ---------------------------------------------------------------------------
// 2D profile of the L-shaped stationary plate (front view, CONVENTIONS frame)
module back_profile(type) {
    if (mp(type, "lug_r") > 0) back_profile_lug(type); else back_profile_open(type);
}
// v4.2: open L with a round bore relief (Radiant Dyes MDI): square outline minus the opening above the bottom leg on the
// side away from the leg, minus the clear-aperture bore. handed = -1 puts the leg on -X.
module back_profile_open(type) {
    bw = mp(type, "body_w"); bh = mp(type, "body_h");
    lw = mp(type, "leg_w");  lhb = mpd(type, "leg_h_bottom", lw);
    hd = mpd(type, "handed", 1);
    op = mp(type, "optic_pos"); ca = mp(type, "clear_ap_d");
    xl = hd > 0 ? -bw/2 - 1 : -bw/2 + lw;
    xr = hd > 0 ? bw/2 - lw : bw/2 + 1;
    difference() {
        translate([-bw/2, 0]) square([bw, bh]);
        translate([xl, lhb]) square([xr - xl, bh]);
        translate(op) circle(d = ca);
    }
}
// rear-face keep-outs (stationary): spring posts / cross-pins standing proud of the rear face (MDI; none on the KM100)
module rear_keepouts(type) {
    h = mpd(type, "spring_rear_h", 0); d = mpd(type, "spring_rear_d", 0);
    if (h > 0) for (s = mp(type, "spring_pos")) translate([s[0], s[1], -h]) cylinder(d = d, h = h + 0.01);
}
module back_profile_lug(type) {
    bw = mp(type, "body_w");
    xR = bw / 2;
    lw = mp(type, "leg_w");
    lr = mp(type, "lug_r");
    kp = mp(type, "knob_pos");
    kA = kp[0]; kB = kp[1];
    fr = mp(type, "inner_fillet");
    union() {
        // +X leg, up to adjuster A
        translate([xR - lw, 0]) square([lw, kA[1]]);
        hull() {
            translate(kA) circle(r = lr);
            translate([xR - lw, kA[1] - 2]) square([lw, 2]);
        }
        // bottom leg, out to adjuster B
        translate([kB[0], 0]) square([xR - kB[0], lw]);
        hull() {
            translate(kB) circle(r = lr);
            translate([kB[0], 0]) square([2, lw]);
        }
        // inner-corner fillet
        translate([xR - lw - fr, lw]) difference() {
            square(fr);
            translate([0, fr]) circle(r = fr);
        }
    }
}

module back_plate(type) {
    bt  = mp(type, "back_t");
    bw  = mp(type, "body_w");
    ph  = mp(type, "post_hole");
    phz = mp(type, "post_hole_z");
    sh  = mp(type, "side_hole");
    zh  = mp(type, "z_hole");
    lw  = mp(type, "leg_w");
    kp  = mp(type, "knob_pos");
    kbd = mp(type, "knob_body_d");
    difference() {
        linear_extrude(height = bt) back_profile(type);
        // post / 8-32 (M4) clearance hole, vertical through bottom leg
        translate([ph[0], -1, phz]) rotate([-90, 0, 0]) cylinder(d = ph[2], h = lw + 2);
        // side clearance hole along X through +X leg (KM100)
        if (sh[2] > 0)
            translate([mpd(type, "handed", 1) > 0 ? bw / 2 - lw - 1 : -bw / 2 - 1, sh[0], sh[1]]) rotate([0, 90, 0]) cylinder(d = sh[2], h = lw + 2);
        // Z clearance hole
        translate([zh[0], zh[1], -1]) cylinder(d = zh[2], h = bt + 2);
        // adjuster screw bores
        for (k = kp) translate([k[0], k[1], -1]) cylinder(d = kbd, h = bt + 2);
    }
}

// ---------------------------------------------------------------------------
module adjusters(type) {
    kp  = mp(type, "knob_pos");
    kd  = mp(type, "knob_d");
    kl  = mp(type, "knob_len");
    kbd = mp(type, "knob_body_d");
    bd  = mp(type, "bushing_d");
    btk = mp(type, "bushing_t");
    nl  = mp(type, "knob_neck_len");
    cd  = mp(type, "knob_collar_d");
    cl  = mp(type, "knob_collar_len");
    bt  = mp(type, "back_t");
    g   = mp(type, "gap");
    for (k = kp) translate([k[0], k[1], 0]) {
        // bushing flange on rear face + shank
        if (bd > 0 && btk > 0) color(C_KNOB) translate([0, 0, -btk]) cylinder(d = bd, h = btk + 0.2);
        color(C_KNOB) translate([0, 0, -nl]) cylinder(d = kbd, h = nl);
        // knob: collar + head (knurl modelled as a plain cylinder)
        if (cd > 0 && cl > 0) color(C_KNOB) translate([0, 0, -nl - cl]) cylinder(d = cd, h = cl);
        color(C_KNOB) translate([0, 0, -kl]) cylinder(d = kd, h = kl - nl - cl);
        // screw through the bushing to the front plate (fixed part)
        color(C_KNOB) cylinder(d = 3.0, h = bt + g + 0.5);
    }
}

// ---------------------------------------------------------------------------
module front_profile(type) {
    fb = mp(type, "front_box");
    ch = mp(type, "front_chamfer");
    lr = mp(type, "lug_r");
    kp = mp(type, "knob_pos");
    x0 = fb[0][0]; y0 = fb[0][1]; x1 = fb[1][0]; y1 = fb[1][1];
    union() {
        polygon([[x0, y0], [x1, y0], [x1, y1], [x0 + ch, y1], [x0, y1 - ch]]);
        if (mp(type, "front_lugs") == 1) {
            // lug at adjuster A (top, +X)
            hull() {
                translate(kp[0]) circle(r = lr);
                translate([kp[0][0] - lr, y1 - 2]) square([2 * lr, 2]);
            }
            // lug at adjuster B (bottom, -X)
            hull() {
                translate(kp[1]) circle(r = lr);
                translate([x0, kp[1][1] - lr]) square([2, 2 * lr]);
            }
        }
    }
}

module front_assembly(type) {
    bt  = mp(type, "back_t");
    g   = mp(type, "gap");
    ft  = mp(type, "front_t");
    bw  = mp(type, "body_w");
    op  = mp(type, "optic_pos");
    bd  = mp(type, "optic_bore_d");
    bdp = mp(type, "optic_bore_depth");
    ca  = mp(type, "clear_ap_d");
    md  = mp(type, "mirror_d");
    mt  = mp(type, "mirror_t");
    zh  = mp(type, "z_hole");
    sm1 = mp(type, "sm1_thread");
    pv  = mp(type, "pivot_pos");
    pd  = mp(type, "pivot_d");
    sp  = mp(type, "spring_pos");
    sd  = mp(type, "spring_d");
    fb  = mp(type, "front_box");
    z0  = bt + g;           // rear face of front plate
    z1  = z0 + ft;          // front face of front plate

    color(C_FRONT) difference() {
        translate([0, 0, z0]) linear_extrude(height = ft) front_profile(type);
        // optic recess / SM1 bore from the front
        translate([op[0], op[1], z1 - bdp]) cylinder(d = bd + 0.2, h = bdp + 1);   // +0.2 slip-fit clearance
        // clear aperture through
        translate([op[0], op[1], z0 - 1]) cylinder(d = ca, h = ft + 2);
        // Z clearance hole (KM100T: through, counterbored on the front)
        translate([zh[0], zh[1], z0 - 1]) cylinder(d = zh[2], h = ft + 2);
        if (sm1 == 1)
            translate([zh[0], zh[1], z1 - 4]) cylinder(d = 7.6, h = 5);
        // KM100: 8-32 nylon-tipped setscrew bore from the top-left chamfer toward the optic
        if (sm1 == 0)
            translate([op[0], op[1], z1 - bdp / 2]) rotate([0, 0, 135]) rotate([0, 90, 0])
                cylinder(d = 3.5, h = 30);
        // spring pin recesses (cosmetic)
        for (s = sp) translate([s[0], s[1], z0 - 1]) cylinder(d = sd + 1, h = 3);
    }
    // mirror (O25.4 x 6 disc)
    mz = (sm1 == 1) ? z1 - 2.5 - mt : z1 - 1.0 - mt;
    color(C_MIRR) translate([op[0], op[1], mz]) cylinder(d = md, h = mt);
    if (sm1 == 1) {
        // SM1 retaining ring in front of the optic; thread shown as a groove ring at the face
        color(C_KNOB) translate([op[0], op[1], z1 - 2.5])
            rotate_extrude() translate([11.0, 0]) square([(bd - 0.3) / 2 - 11.0, 2.0]);
    } else {
        // nylon-tipped 8-32 setscrew (shown seated)
        color([0.9, 0.9, 0.9]) translate([op[0], op[1], z1 - bdp / 2]) rotate([0, 0, 135])
            translate([md / 2 - 0.5, 0, 0]) rotate([0, 90, 0]) cylinder(d = 3.2, h = 3);
    }
    // pivot ball between the plates
    color(C_KNOB) translate([pv[0], pv[1], bt + g / 2]) sphere(d = pd);
    // extension springs bridging the gap (simple cylinders)
    for (s = sp) color(C_SPRING) translate([s[0], s[1], bt - 2]) cylinder(d = sd, h = g + 4);
}
