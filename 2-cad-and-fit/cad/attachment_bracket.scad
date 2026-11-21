// attachment_bracket.scad -- v3 base block + yoke + left post (ONE solid print) and the rear bar.
// Frame: CONVENTIONS.md (origin = bottom-centre of the back-plate rear face, +Z toward the mirror,
// knobs protrude in -Z). Parameters: attachment_params.scad.
//
//  * BASE BLOCK sits on TOP of the mount: two NEMA 11 + encoder pockets side by side in X (shafts -Z,
//    bodies +Z over the mount). v3 motors carry a factory rear encoder (built: 11HS12-1004D-E1000,
//    50 mm; option ME1K, 57.5 mm), so each pocket is a square tube (walls 4 mm) as long as the motor
//    that ends, from the connector box forward, in an OPEN-TOP CABLE CHANNEL: the motor's side
//    connector box faces +Y, its cables U-turn up and run forward (+Z) out of the channel on top,
//    never down toward the mirror. One cable tie in the notches at the front end holds both bundles.
//      - 45 deg ramp in the lower INNER corner; 2x M3 set screws in the OUTER side wall push the motor
//        inward and up the ramp => belt tension (+/-1.5 mm)
//      - 1x M3 set screw in the TOP wall locks it (pushes it back onto the ramp)
//      - Z slide -0.8 / +4 mm for the pulley plane; the FRONT STOP RIB (outer-top corner of the pocket's
//        rear end) catches the flange face at the -0.8 limit, so a motor cannot slide toward the mount
//    In front of the back plate (z > back_t) the underside steps up to the pocket floors (4 mm), which
//    saves material and keeps the COM back.
//  * YOKE on the +X leg of the L-shaped back plate (unchanged from v2; all contact z 0..9.7):
//      - rest pad on the lug crown over adjuster A (vertical support #1)
//      - outer cheek on the +X face, 2x M4 (clamp screws, driven from +X)
//      - inner cheek on the leg's inner face, 2x M4 (pre-set datum screws, driven from -X)
//      - rear bar (separate part) behind the leg, 2x M4 on the rear face (anti-pitch)
//  * LEFT POST drops from the block down the open L to a FOOT over the TOP of the bottom leg with
//    1x M4 set screw (30 deg off vertical, driven from the upper left) = vertical support #2.
//
// Parts in this file: base_block(), rear_bar().

include <mount_params_defaults.scad>
include <attachment_params.scad>

part = "block";          // "block" | "rear_bar"
show_context = false;
view_yup = false;
$fn = 40;
e = 0.01;

// heat-set insert pocket + CLEARANCE hole beyond it (v4: was a tap-drill hole = an implied printed thread);
// surface at z=0, going -Z
module insert_hole(ins_d, ins_l, clr_d, through = 30) {
    translate([0, 0, -ins_l]) cylinder(d = ins_d, h = ins_l + e);
    translate([0, 0, -through]) cylinder(d = clr_d, h = through + e);
}
// orient +Z of a child to direction d (unit)
module point_to(d) {
    b = acos(d[2]); a = atan2(d[1], d[0]);
    rotate([0, b, a]) children();
}

// ---------- pocket cross-section (2D, global XY) ---------------------------------------------
// local u = inward*(x - x0), v = y - y0; pocket = |u|,|v| <= pk_half minus the ramp u - v >= ramp_K
module ramp_2d() {
    polygon([[ramp_K - pk_half - 0.01, -pk_half - 0.01],
             [pk_half + 0.01, -pk_half - 0.01],
             [pk_half + 0.01, pk_half - ramp_K + 0.01]]);
}
// front stop rib: outer-top corner triangle, -u + v >= rib_K
module rib_2d() {
    polygon([[-pk_half - 0.01, pk_half + 0.01], [-pk_half - 0.01, rib_K - pk_half], [pk_half - rib_K, pk_half + 0.01]]);
}
module pocket_local(i) translate([motor_x0[i], motor_y0[i]]) scale([inward[i], 1]) children();
module pocket_cut_2d(i) pocket_local(i) difference() { square(2*pk_half, center = true); ramp_2d(); }

// ---------- block -------------------------------------------------------------------------
x_cw = (motor_x0[0] - pk_half + motor_x0[1] + pk_half)/2;     // centre-wall middle (-6)
function pk_floor(i) = motor_y0[i] - pk_half - wall;           // tube underside in front of the back plate
module block_solid() {
    // rear, full-depth section over the back plate (z 0..back_t): down to blk_bot, carries the yoke and post
    translate([blk_x0, blk_bot, blk_z0]) cube([x_cw - blk_x0, blk_top[1] - blk_bot, blk_zf - blk_z0]);
    translate([x_cw - e, blk_bot, blk_z0]) cube([blk_x1 - x_cw + e, blk_top[0] - blk_bot, blk_zf - blk_z0]);
    // the two square tubes, full length (B left, A right); 45 deg chamfer from the full section up to the tube floors
    translate([blk_x0, pk_floor(1), blk_z0]) cube([x_cw - blk_x0, blk_top[1] - pk_floor(1), blk_z1 - blk_z0]);
    translate([x_cw - e, pk_floor(0), blk_z0]) cube([blk_x1 - x_cw + e, blk_top[0] - pk_floor(0), blk_z1 - blk_z0]);
    for (s = [[blk_x0, x_cw, pk_floor(1)], [x_cw - e, blk_x1, pk_floor(0)]]) {
        d = s[2] - blk_bot;
        translate([s[0], blk_bot, blk_zf - e]) rotate([90, 0, 90]) linear_extrude(s[1] - s[0])
            polygon([[0, 0], [d + e, 0], [d + e, d]]);
    }
    // set-screw bosses
    for (i = [0, 1]) {
        xo = motor_x0[i] - inward[i]*(pk_half + wall);         // outer wall face
        for (z = sc_z) translate([xo + inward[i]*e, motor_y0[i], z]) rotate([0, -inward[i]*90, 0]) cylinder(d = boss_d, h = boss_h + e);
        translate([motor_x0[i], blk_top[i] - e, top_sc_z]) rotate([-90, 0, 0]) cylinder(d = boss_d, h = boss_h + e);
    }
}

module block_cuts() {
    for (i = [0, 1]) {
        // motor pocket, through in Z
        translate([0, 0, blk_z0 - 1]) linear_extrude(blk_z1 - blk_z0 + 2) pocket_cut_2d(i);
        // cable channel: the top wall stops at z_chan (connectors + leads exit upward, then forward)
        translate([motor_x0[i] - pk_half, motor_y0[i] + pk_half - 1, z_chan]) cube([2*pk_half, wall + 2, blk_z1 - z_chan + 1]);
        // v4: 45 deg chamfer (chan_ch) on the top wall's front edge: room + a lead-in for the cables' R7 U-turn at the
        // -0.8 slide / bottom-of-ramp corner (v3's R~3 cable model hid this), and no sharp edge on the cable jacket
        translate([motor_x0[i] - pk_half, 0, 0]) rotate([90, 0, 90]) linear_extrude(2*pk_half)
            polygon([[blk_top[i] + e, z_chan - chan_ch], [blk_top[i] + e, z_chan + e], [blk_top[i] - chan_ch, z_chan + e]]);
        // v4.1: access slot over the hub-in 16T grub (key from +Y with the belt on), covers the -0.8 / +4 slide
        if (mp_hub_in) translate([motor_x0[i] - acc_slot_w/2, motor_y0[i] + pk_half - 1, blk_z0 - 1])
            cube([acc_slot_w, wall + boss_h + 2, z_flange - mp_grub_z + z_slide[1] + 2.5 + 1]);
        // outer-wall set screws (insert from outside, through the boss)
        xo = motor_x0[i] - inward[i]*(pk_half + wall + boss_h);
        for (z = sc_z) translate([xo, motor_y0[i], z]) rotate([0, -inward[i]*90, 0]) mirror([0, 0, 1])
            insert_hole(ins3_d, ins3_l, m3_clr, wall + boss_h + 1);
        // top set screw
        translate([motor_x0[i], blk_top[i] + boss_h, top_sc_z]) rotate([-90, 0, 0]) mirror([0, 0, 1])
            insert_hole(ins3_d, ins3_l, m3_clr, wall + boss_h + 1);
        // Z witness: 1 mm ticks on the top face (rear end), read against the motor's flange corner
        for (k = [0 : 6]) {
            tl = (k % 5 == 0) ? 4 : 2.5;
            translate([motor_x0[i] + 7, blk_top[i] - 0.5, blk_z0 + z_flange + z_slide[0] + k - 0.25]) cube([tl, 1, 0.5]);
        }
        // cable-tie notches in the channel walls (one tie wraps the front end over both lead bundles)
        for (xw = [motor_x0[i] - inward[i]*(pk_half + wall/2)]) translate([xw - wall/2 - 1, blk_top[i] - 2.5, tie_z - 2]) cube([wall + 2, 3, 4]);
    }
    // tie notch in the centre wall (between the two channels) and a tie groove under each tube floor
    translate([x_cw - 3, min(blk_top) - 2.5, tie_z - 2]) cube([6, 10, 4]);
    for (i = [0, 1]) translate([motor_x0[i] - pk_half - wall - 1, pk_floor(i) - 1, tie_z - 2]) cube([2*(pk_half + wall) + 2, 1.8, 4]);
    // label engraved in the -X face of motor B's outer wall, above the set-screw bosses
    translate([blk_x0 + 0.8, motor_y0[1] + boss_d/2 + 5, (sc_z[0] + sc_z[1])/2]) rotate([0, -90, 0])
        linear_extrude(1) mirror([handed < 0 ? 1 : 0, 0])      // v4.2: reads correctly after hand() mirrors the block
            text(_BM ? str("MDI PROV v4 ", motor_type) : str("KM100/T v4 ", motor_type), size = 2.6, halign = "center", valign = "center");
}

// front stop ribs (left standing in the pocket's rear end)
module stop_ribs() {
    for (i = [0, 1]) translate([0, 0, blk_z0]) linear_extrude(z_rib - blk_z0) pocket_local(i) rib_2d();
}

// ---------- yoke, post and foot (unchanged from v2) ---------------------------------------------
module yoke_solid() {
    // bridge under the right half of the block: rests on the lug crown (y = DESIGN_LUG_TOP)
    translate([x_ci0, DESIGN_LUG_TOP, 0]) cube([x_co1 - x_ci0, blk_bot - DESIGN_LUG_TOP + e, yoke_zmax]);
    // outer cheek (+X face of the leg); x > body_w/2 so it may use the full z 0..9.7
    translate([x_co0, cheek_out_bot, 0]) cube([cheek_t, blk_bot + 8 - cheek_out_bot, back_t - 0.5]);
    // fillet the outer cheek into the block side
    if (x_co1 > blk_x1) translate([blk_x1 - e, blk_bot - e, 0]) cube([x_co1 - blk_x1 + e, 8, back_t - 0.5]);
    // inner cheek (inner face of the leg, inside the L opening)
    translate([x_ci0, cheek_in_bot, 0]) cube([cheek_t, blk_bot - cheek_in_bot + e, yoke_zmax]);
    // left post down the open L, and the foot over the bottom leg
    translate([post_x[0], foot_y[1] - e, 0]) cube([post_x[1] - post_x[0], blk_bot - foot_y[1] + 2*e, post_zmax]);
    translate([foot_x[0], foot_y[0], 0]) cube([foot_x[1] - foot_x[0], foot_y[1] - foot_y[0], foot_zmax]);
    if (foot_ins_low && len(foot_boss) > 0) translate([foot_boss[0][0] - e, foot_boss[1][0], 0]) cube([foot_boss[0][1] - foot_boss[0][0] + e, foot_boss[1][1] - foot_boss[1][0], foot_zmax]);
    // gusset post -> block underside
    translate([post_x[1] - e, blk_bot - 8, 0]) linear_extrude(post_zmax)
        polygon([[0, 8 + e], [8, 8 + e], [0, 0]]);
}

foot_dir = [-sin(foot_ang), cos(foot_ang), 0];   // from the tip toward the screw head
module yoke_cuts() {
    // outer cheek: 2x M4 pushing -X on the +X face
    for (y = cheek_out_y) translate([x_co1, y, cheek_z[1]]) rotate([0, 90, 0]) insert_hole(ins4_d, ins4_l, m4_clr, cheek_t + 1);
    // inner cheek: 2x M3 (v4; was M4 with 1.0 mm walls in the 7.5 mm cheek) pushing +X on the leg's inner face
    for (y = cheek_in_y) translate([x_ci0, y, cheek_z[0]]) rotate([0, -90, 0])
        if (cheek_in_m == 3) insert_hole(ins3_d, ins3_l, m3_clr, cheek_t + 1); else insert_hole(ins4_d, ins4_l, m4_clr, cheek_t + 1);
    // rear-bar bolts: 2x M3 inserts in the outer cheek rear face (z = 0)
    for (y = rear_bolt_y) translate([x_co0 + cheek_t/2, y, 0]) rotate([180, 0, 0]) insert_hole(ins3_d, ins3_l, m3_clr, 8);
    // foot screw: M4, axis from the tip on the leg top up-left through the post; insert at the post's -X face
    tip = foot_tip;
    t_out = (tip[0] - post_x[0]) / sin(foot_ang);          // distance from tip to the post's -X face
    translate(tip) point_to(foot_dir) {
        fi_d = foot_m == 3 ? ins3_d : ins4_d;  fi_l = foot_m == 3 ? ins3_l : ins4_l;  fc_d = foot_m == 3 ? m3_clr : m4_clr;
        translate([0, 0, -1]) cylinder(d = fc_d, h = t_out + 2);             // v4: clearance bore (was a 14 mm long tap-drill bore)
        if (foot_ins_low) {
            // v4.1: insert at the LOW end, set from below into a spot face square to the axis (block off the mount), so the
            // same M3 x 10 brass-tip as the inner cheeks reaches the leg; the key goes down the clearance bore from the post face
            translate([0, 0, -8]) cylinder(d = 6, h = 8 + foot_seat_t);                 // spot face (seat at t = foot_seat_t)
            translate([0, 0, foot_seat_t - e]) cylinder(d = fi_d, h = fi_l + e);         // insert pocket
            translate([0, 0, t_out]) cylinder(d = 6, h = 20);                           // key entry
        } else {
            translate([0, 0, t_out - fi_l]) cylinder(d = fi_d, h = fi_l + 5);   // insert from outside
            translate([0, 0, t_out]) cylinder(d = 9, h = 20);                   // spot face / key access
        }
    }
}

module base_block() {
    difference() {
        union() { block_solid(); yoke_solid(); }
        block_cuts();
        yoke_cuts();
    }
    stop_ribs();
}

// ---------- MIR_cable_clip_v1 (07_Electronics_Package fig2c item 2) ------------------------------------------
// Sits on the front end of the block WITHOUT changing it: three feet on the wall tops (outer walls + centre wall), a
// bridge over both open channels (clear of the connector boxes at the +4 slide), and a C-channel cantilevered in front
// of the block end. The leads come forward over the bridge, meet the front fence, turn 90 deg and leave at the -X end
// (design frame: the side away from the leg, toward the post), never forward over the mirror. The existing single cable
// tie now goes OVER the bridge (locating groove at tie_z), down the block's outer faces and through the floor groove, so
// it holds the clip and the leads together. Design frame; mirrored by hand() for handed = -1.
clip_t    = 2.5;                                   // plate thickness
clip_y0   = motor_y0[0] + s_range + motor_w/2 + conn_h + 1.0;  // bridge underside: 1.0 over motor A's connector box at ramp s = +1.5
clip_z0   = tie_z - 4.0;                           // rear edge (on the block)
clip_zf   = blk_z1 + 11.0;                         // front fence outer face (in front of the block end)
clip_fh   = 14.0;                                  // fence height above the bridge top
clip_lip  = 4.0;                                   // roof lip depth (over the C-channel)
module cable_clip() {
    yb = clip_y0; yt = clip_y0 + clip_t;
    x0 = blk_x0; x1 = blk_x1;
    difference() {
        union() {
            translate([x0, yb, clip_z0]) cube([x1 - x0, clip_t, clip_zf - clip_z0]);                       // bridge + C floor
            translate([x0, yb, clip_zf - clip_t]) cube([x1 - x0, clip_fh + clip_t, clip_t]);                // front fence
            translate([x0, yt + clip_fh - clip_t, clip_zf - clip_t - clip_lip]) cube([x1 - x0, clip_t, clip_lip + e]);   // roof lip
            translate([x1 - clip_t, yb, blk_z1]) cube([clip_t, clip_fh + clip_t, clip_zf - blk_z1]);        // +X end wall
            // feet down to the wall tops (A outer wall, centre wall on the A side of x_cw, B outer wall)
            for (f = [[x1 - wall, blk_top[0]], [x_cw, blk_top[0]], [x0, blk_top[1]]])
                translate([f[0], f[1], clip_z0]) cube([wall, yb - f[1] + e, blk_z1 - clip_z0]);
        }
        // tie groove across the bridge top at tie_z (the one cable tie goes over the clip)
        translate([x0 - 1, yt - 0.8, tie_z - 2.2]) cube([x1 - x0 + 2, 1, 4.4]);
        // leave the existing wall notches open under the feet (tie may also be threaded through them)
        for (f = [x1 - wall, x_cw, x0]) translate([f - 1, min(blk_top) - 3, tie_z - 2]) cube([wall + 2, clip_y0 - min(blk_top) + 2.5, 4]);
    }
}

// ---------- rear bar (separate; slid in behind the +X leg after the block is seated) --------------
rear_z1 = -rear_g;                 // front face (0.5 mm off the leg's rear face)
rear_z0 = -rear_g - rear_t;
module rear_bar() {
    difference() {
        union() {
            translate([x_leg_in, rear_y[0], rear_z0]) cube([x_co1 - x_leg_in, rear_y[1] - rear_y[0], rear_t]);
            // pad against the outer cheek's rear face (bar front is 0.5 mm off the leg)
            translate([x_co0 + 0.3, rear_y[0], rear_z1 - e]) cube([cheek_t - 0.3, rear_y[1] - rear_y[0], rear_g + e]);
        }
        // 2x M4 set screws pushing +Z on the leg's rear face; inserts from the back face
        for (p = rear_screw_pos) translate([p[0], p[1], rear_z0 - e]) {
            cylinder(d = ins4_d, h = ins4_l + e);
            cylinder(d = m4_clr, h = rear_t + 1);              // v4: clearance (was tap drill); insert pocket 5.2 leaves a 1.3 floor
        }
        // M3 x 12 bolts to the cheek
        for (y = rear_bolt_y) translate([x_co0 + cheek_t/2, y, rear_z0 - 1]) cylinder(d = 3.4, h = rear_t + 3);
        // clear the KM100/KM100T Z-axis hole (12.25, 12.7)
        translate([dk(z_hole)[0], z_hole[1], rear_z0 - 1]) cylinder(d = z_hole[2] + 1.5, h = rear_t + 2);   // v4.2: design frame
    }
}

// ---------- motor stand-in (motor_type: 11HS12-1004D-E1000 or 11HS20-0674-ME1K) -------------------
// local frame: z = 0 at the flange face, body +Z, shaft -Z; connector box on +Y. Used by assembly + checks.
module nema11_enc_body(with_pilot = true) {
    linear_extrude(motor_body_len) motor_profile_2d();
    // encoder housing: same square, slightly smaller (rounded corners on the real part)
    translate([0, 0, motor_body_len - e]) linear_extrude(motor_enc_len + e) offset(r = -0.2) motor_profile_2d();
    if (with_pilot) translate([0, 0, -motor_pilot_h]) cylinder(d = motor_pilot_d, h = motor_pilot_h + e);
}
module nema11_conn() {   // connector / cable box on the +Y face (45 deg chamfer at its rear end, as drawn)
    translate([conn_w/2, motor_w/2 - e, conn_z[0]]) rotate([0, -90, 0]) linear_extrude(conn_w)
        polygon([[0, 0], [conn_z[1] - conn_z[0], 0], [conn_z[1] - conn_z[0], conn_h*0.6], [conn_z[1] - conn_z[0] - conn_h*0.4, conn_h + e], [0, conn_h + e]]);
}
// cables. E1000: they leave the box's -Z end axially, U-turn upward (r ~3) over the box and run forward
// (+Z) out of the open channel. ME1K: straight up out of the connectors, then forward.
module _chain(pts) for (k = [0 : len(pts) - 2]) hull() { translate(pts[k]) sphere(d = lead_d, $fn = 16); translate(pts[k + 1]) sphere(d = lead_d, $fn = 16); }
module nema11_leads(L = 18) {
    yt = motor_w/2 + conn_h;                 // box top
    yr = yt + lead_d/2 + 0.1;                // run height over the box
    if (lead_exit_rear) for (x = lead_x) {
        ym = motor_w/2 + conn_h/2;
        translate([x, ym, conn_z[0] + 0.02]) mirror([0, 0, 1]) cylinder(d = lead_d, h = 1.5, $fn = 16);
        // v4: U-turn at centreline radius lead_R (7 = 1.75 x OD; v3 modelled ~3, a kink at the box's strain relief).
        // The bend clears the top wall's end (z_chan) at the -0.8 slide limit; the run then sits ~14 mm over the box.
        cz = conn_z[0] - 1.5; cy = ym + lead_R;
        _chain(concat([for (k = [0 : 8]) let(ph = 180*k/8) [x, cy - lead_R*cos(ph), cz - lead_R*sin(ph)]],
                      [[x, ym + 2*lead_R, motor_len + L]]));
    } else for (x = lead_x) {
        for (zc = [(conn_z[0] + 51)/2, (51.4 + conn_z[1])/2]) hull() {
            translate([x, yt + 0.02, zc]) rotate([-90, 0, 0]) cylinder(d = lead_d, h = 1.5, $fn = 16);
            translate([x, yr, zc]) sphere(d = lead_d, $fn = 16);
        }
        _chain([[x, yr, (conn_z[0] + 51)/2], [x, yr, motor_len + L]]);
    }
}

// ---------- context ----------------------------------------------------------------------------
use <mirror_mount.scad>
module ghost_motor(i) {
    m = motor_xy(i, 0);
    translate([m[0], m[1], z_flange]) {
        nema11_enc_body(); nema11_conn();
        mirror([0, 0, 1]) cylinder(d = motor_shaft_d, h = motor_shaft_l);
    }
}

if (is_undef(ASSEMBLY)) rotate(view_yup ? [90, 0, 0] : [0, 0, 0]) {
    if (part == "block") color([0.95, 0.55, 0.15]) hand() base_block();
    else if (part == "cable_clip") hand() cable_clip();
    else hand() rear_bar();
    if (part == "block" && show_context) {
        color([0.80, 0.40, 0.05]) hand() rear_bar();
        %mirror_mount(mount_type, true, [0, 0]);
        for (i = [0, 1]) %hand() ghost_motor(i);
    }
}

echo(str("BLOCK v4.2 ", mount_type, " bracket ", bracket, " handed ", handed, " (", motor_type, "): x ", blk_x0 - boss_h, "..", x_co1, "  y ", DESIGN_LUG_TOP, "/", blk_bot, "..", max(blk_top) + boss_h,
         "  z ", blk_z0, "..", blk_z1, " (full depth to ", blk_zf, ", channel from ", z_chan, ", rib to ", z_rib, ")",
         " | motor xy0 ", motor_xy(0, 0), " ", motor_xy(1, 0),
         " | flange z ", z_flange, " belt plane z ", z_belt, " | tube floors y ", pk_floor(0), " / ", pk_floor(1)));
