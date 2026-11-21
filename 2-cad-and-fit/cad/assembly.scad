// assembly.scad -- v4 (MJF design review 2026-10-15; geometry otherwise v3) combined model: Thorlabs KM100 / KM100T + motorisation attachment.
// Frame: cad/CONVENTIONS.md (origin = bottom-centre of the back-plate rear face, +X right looking at
// the mirror, +Y up, +Z toward the mirror; knobs protrude in -Z). Units: mm.
//
// Shows: mount (grey), front plate + mirror (blue), base block + yoke + post (orange), rear bar
// (dark orange), NEMA 11 motors with factory rear encoders (black, 11HS20-0674-ME1K) with their
// side-exit connectors (white) and lead bundles (light grey) leaving through the open-top cable
// channel, metal 16T pulleys (silver), knob caps with printed 66T pulleys (yellow), GT2 belts (dark
// red). v3: no encoder arm, no AS5048A boards, no magnets.
// The drivers (2x TMC2209) and the Raspberry Pi Pico live in a REMOTE box -- not modelled;
// a text note is drawn above the block when show_note = true.
//
// CLI examples
//   openscad -D 'mount_type="KM100T"' -D view_yup=true --preview -o x.png assembly.scad
//   openscad -D exploded=true ...
//   openscad --render -o stl/assembly_KM100.stl assembly.scad          (combined, viewing only)
// Renders: sh render_assembly.sh  ->  renders/assembly/*.png
//
// ---- Parameter reconciliation (same scheme as v1) ----------------------------------------------
//   1. mount_params.scad first (MOUNT_DB + flat names);
//   2. the attachment part files are include<>d so their modules see THIS file's variables (their
//      own top-level geometry is skipped because ASSEMBLY is defined);
//   3. mount_params.scad again LAST: the mount agent's table wins for every shared flat name;
//   4. names it does not flatten are re-derived from its table below.
//   The bracket itself is fixed geometry (DESIGN_KNOB = KM100); caps and the motor ramp position
//   (s_req) follow the selected mount.

ASSEMBLY = true;

include <mount_params.scad>          // (1)
include <attachment_bracket.scad>    // (2) mount_params_defaults + attachment_params + base_block(), rear_bar()
include <knob_extension.scad>        //     knob_extension(i)
include <belts.scad>                 //     belt(), motor_pulley()
include <mount_params.scad>          // (3) authoritative values

// (4) names missing from mount_params.scad's flat set
lug_r         = mp(mount_type, "lug_r");
pivot_pos     = mp(mount_type, "pivot_pos");
bushing_d     = mp(mount_type, "bushing_d");
side_hole     = mp(mount_type, "side_hole");
z_hole        = mp(mount_type, "z_hole");
adj_range_deg = mp(mount_type, "adj_range_deg");

use <mirror_mount.scad>

// ---------------- user switches ----------------------------------------------------------
mount_type           = "KM100";      // "KM100" | "KM100T"
show_mount           = true;         // back plate, adjusters, front plate, mirror
show_attachment      = true;         // base block + yoke + post, rear bar
show_knob_extensions = true;         // knob caps with 66T pulleys
show_belts           = true;
show_motors          = true;         // NEMA 11 + encoder, connectors, leads, 16T pulleys
show_note            = true;         // text note: remote electronics
exploded             = false;
show_refs            = false;        // magenta lines at z = 0 and z = back_t
tilt                 = [0, 0];       // front-plate tilt for review renders (deg)
walk                 = 0;            // knob axial walk fraction (-1..1) for review renders
view_yup             = false;        // PNGs only: rotate so +Y is up on screen
show_clip            = true;         // MIR_cable_clip_v1 on the block front
show_screws          = true;         // set screws drawn as solids (contact points)
group                = "all";        // export one colour group for the CGAL render pipeline (tools/make_renders.py):
                                     // mount_back mount_front block rear_bar motors pulley16 conn leads caps
                                     // belts screws note refs
section_z            = -1000;        // > -1000: keep only z >= section_z (cut view, look from -Z)
section_x            = 1000;         // < 1000: keep only x <= section_x (cut view, look from +X)
$fn = 64;
function G(n) = (group == "all" || group == n);
module sec() {
    if (section_z <= -999 && section_x >= 999) children();
    else intersection() {
        children();
        translate([-300 + min(section_x, 300) - 300, -300, max(section_z, -300)]) cube([600, 600, 600]);
    }
}

// ---------------- colours (v1 scheme) ------------------------------------------------------
C_MOUNT      = [0.62, 0.62, 0.65];
C_FRONTPLATE = [0.20, 0.42, 0.85];
C_YOKE       = [0.95, 0.55, 0.15];
C_BAR        = [0.80, 0.40, 0.05];
C_MOTOR      = [0.08, 0.08, 0.09];
C_BOARD      = [0.10, 0.55, 0.20];
C_CONN       = [0.95, 0.95, 0.90];
C_PULLEY16   = [0.78, 0.78, 0.82];
C_KNOBEXT    = [0.98, 0.85, 0.10];
C_BELT       = [0.55, 0.05, 0.05];
C_LEAD       = [0.82, 0.82, 0.86];
C_GUIDE      = [0.35, 0.35, 0.35];
C_REF        = [0.90, 0.10, 0.80];
C_SCREW      = [0.30, 0.30, 0.34];

// ---------------- exploded offsets (assembly directions) ---------------------------------
EX = exploded ? 1 : 0;
EX_BLOCK   = EX * [0, 45, 0];                      // block is lowered onto the +X leg from above
EX_BAR     = EX * [40, 0, -12];                    // rear bar slides in along -X, then +Z
EX_MOTOR   = EX_BLOCK + EX * [0, 0, 60];           // motors slide into the pockets from the front (-Z)
EX_KNOB    = EX * [0, 0, -30];                     // caps slide onto the knobs along +Z
EX_BELT    = EX * [0, 0, -55];                     // loops slip onto the pulleys along +Z

module guide(pts) {
    color(C_GUIDE) for (k = [0 : len(pts) - 2])
        hull() { translate(pts[k]) sphere(d = 0.6, $fn = 6); translate(pts[k + 1]) sphere(d = 0.6, $fn = 6); }
}

// ---------------- parts ------------------------------------------------------------------
module mount_part() {
    if (G("mount_back")) color(C_MOUNT) render(convexity = 6) mirror_mount(mount_type, false, [0, 0]);
    pv = mp(mount_type, "pivot_pos"); piv = [pv[0], pv[1], back_t + gap/2];
    // the mount model's adjuster screws / springs overlap the front plate: subtract the back group so the
    // two colour groups never share volume (clean CGAL section views)
    if (G("mount_front")) color(C_FRONTPLATE) render(convexity = 6) difference() {
        translate(piv) rotate([tilt[0], tilt[1], 0]) translate(-piv) front_assembly(mount_type);
        mirror_mount(mount_type, false, [0, 0]);
    }
}

module nema11(i) {
    m = motor_xy(i, s_req(i));
    translate([m[0], m[1], z_flange]) {
        if (G("motors")) color(C_MOTOR) nema11_enc_body();
        // motor (4-pin) + encoder (8-pin) connectors on the +Y face; leads go up, then forward (+Z)
        if (G("conn")) color(C_CONN) nema11_conn();
        if (G("leads")) color(C_LEAD) nema11_leads();
    }
    if (G("pulley16")) color(C_PULLEY16) {
        motor_pulley(i, s_req(i));
        translate([m[0], m[1], z_flange - motor_shaft_l]) cylinder(d = motor_shaft_d - 0.02, h = motor_shaft_l - motor_pilot_h + 0.01, $fn = 24);
    }
}

function wz() = walk * knob_travel;
module cap_part(i) {
    if (G("caps")) color(C_KNOBEXT) translate([dknob[i][0], dknob[i][1], -knob_len + wz()]) knob_extension(i);
}

// set screws as solids (tips 0.02 mm off the surfaces they bear on)
// drawn 0.1 mm under the tap drill so the solids never overlap the plastic (clean section views)
module setscrew(p, d, L, dir) translate(p) point_to(dir) translate([0, 0, 0.02]) cylinder(d = d, h = L, $fn = 24);
module screws_block() {   // attached to the base block (move with it when exploded)
    for (y = cheek_out_y) setscrew([xR, y, cheek_z[1]], 3.9, 10, [1, 0, 0]);          // v4: M4 x 10 brass tip
    for (y = cheek_in_y)  setscrew([x_leg_in, y, cheek_z[0]], 2.9, 10, [-1, 0, 0]);  // v4: M3 x 10 brass tip
    setscrew(foot_tip, 2.9, 10, foot_dir);                     // v4.1: M3 x 10 brass tip (insert at the low end)
    for (i = [0, 1]) {
        m = motor_xy(i, s_req(i));
        for (z = sc_z) setscrew([m[0] - inward[i]*motor_w/2, m[1], z], 2.9, 8, [-inward[i], 0, 0]);   // v4: M3 x 8
        setscrew([m[0], m[1] + motor_w/2, top_sc_z], 2.9, 8, [0, 1, 0]);
    }
}
module screws_bar() for (p = rear_screw_pos) setscrew([p[0], p[1], 0], 3.9, 10, [0, 0, -1]);   // v4.1 purchasing: M4 x 10 brass tip
module screws_cap(i) cap_screw_solids();   // v4.1 purchasing: M3 x 8 cup point (radial); v4.2 short-knob caps: M3 x 10 inclined

module note() {     // readable from the rear (-Z), sits just above the block
    color([0.2, 0.2, 0.2]) translate([blk_x1 - 2, max(blk_top) + boss_h + 3, blk_z0 + 2]) rotate([0, 180, 0])
        linear_extrude(0.6) {
            translate([0, 5]) text("REMOTE BOX (not modelled):", size = 3.2);
            text("Pico + 2x TMC2209 + 12/24 V PSU", size = 3.2);
        }
}

module refs() {
    color(C_REF) for (z = [0, back_t]) {
        translate([-60, -40, z]) rotate([-90, 0, 0]) cylinder(d = 0.6, h = 160, $fn = 6);
        translate([-60, 110, z]) rotate([0, 90, 0]) cylinder(d = 0.6, h = 120, $fn = 6);
    }
}

module assembly() {
    if (show_mount) mount_part();
    hand() attachment_side();     // v4.2: the attachment is built in the design frame (leg on +X) and mirrored for handed = -1
}
module attachment_side() {
    if (show_attachment) {
        if (G("block")) translate(EX_BLOCK) color(C_YOKE) base_block();
        if (G("block") && show_clip) translate(EX_BLOCK + EX * [0, 25, 0]) color(C_BAR) cable_clip();   // v4.2: MIR_cable_clip_v1
        if (G("rear_bar")) translate(EX_BAR) color(C_BAR) rear_bar();
        if (exploded && group == "all") {
            for (p = [[x_co0 + cheek_t/2, cheek_out_bot, cheek_z[1]], [(post_x[0] + post_x[1])/2, foot_y[0], 3]])
                guide([p, p + EX_BLOCK]);
            p = [x_leg_in, 12, rear_z0]; guide([p, p + EX_BAR]);
        }
        if (show_screws && G("screws")) color(C_SCREW) { translate(EX_BLOCK) screws_block(); translate(EX_BAR) screws_bar(); }
    }
    if (show_motors) for (i = [0, 1]) {
        translate(EX_MOTOR) nema11(i);
        if (exploded && group == "all") { p = [motor_x0[i], motor_y0[i], z_flange + motor_len]; guide([p, p + EX_MOTOR]); }
    }
    if (show_knob_extensions) for (i = [0, 1]) {
        translate(EX_KNOB) cap_part(i);
        if (show_screws && G("screws")) color(C_SCREW) translate(EX_KNOB) translate([dknob[i][0], dknob[i][1], -knob_len + wz()]) screws_cap(i);
        if (exploded && group == "all") { p = [dknob[i][0], dknob[i][1], -knob_len - kx_floor_t]; guide([p + [0, 0, 0.5], p + EX_KNOB]); }
    }
    if (show_belts && G("belts")) for (i = [0, 1]) translate(EX_BELT) color(C_BELT) belt(i, s_req(i), wz());
    if (show_note && handed > 0 && show_attachment && G("note")) translate(EX_BLOCK) note();
    if (show_refs && G("refs")) refs();
}

rotate(view_yup ? [90, 0, 0] : [0, 0, 0]) sec() assembly();

echo(str("ASSEMBLY v4.2 ", mount_type, " (bracket ", bracket, ", handed ", handed, ", grip ", kx_grip, ", teeth ", knob_teeth, ", belts ", belt_L, ")", ": knob_pos=", knob_pos, " knob_d=", knob_d, " knob_len=", knob_len,
         " | motors ", motor_xy(0, s_req(0)), " ", motor_xy(1, s_req(1)), " ramp s=", [s_req(0), s_req(1)],
         " | flange z ", z_flange, " belt plane z ", z_belt,
         " | C=", [norm(motor_xy(0, s_req(0)) - dknob[0]), norm(motor_xy(1, s_req(1)) - dknob[1])]));
