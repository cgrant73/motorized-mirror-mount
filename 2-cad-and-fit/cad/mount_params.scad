// mount_params.scad -- Thorlabs KM100 / KM100T kinematic mirror mount ESTIMATE parameters
// Units: mm.  Frame per cad/CONVENTIONS.md:
//   origin = bottom-centre of the STATIONARY (back) plate rear face
//   +X right looking at the mirror from the front, +Y up, +Z toward the front (mirror) plate
//   back plate z in [0, back_t]; gap; front plate z in [back_t+gap, back_t+gap+front_t]
//   adjuster knobs protrude in -Z.
// Sources (see MOUNT_DIMENSIONS.md for per-number citation):
//   KM100 : Thorlabs drawing 6628-E0W "KM100 KINEMATIC MIRROR MOUNT", REV C (redrawn 09/OCT/14)
//           https://media.thorlabs.com/globalassets/items/k/km/km1/km100/6628-e0w.pdf
//   KM100T: Thorlabs drawing 6634-E01 (file 6634-E0W) "KM100T SM1 THREADED KINEMATIC MOUNT", REV D (redrawn 05/17/10)
//           https://media.thorlabs.com/globalassets/items/k/km/km1/km100t/6634-e0w.pdf
// Comment tag (E) = ESTIMATED by scaling the drawing; untagged = dimensioned on, or derived from, the drawing.
//
// Select the mount from the CLI with:  -D mount_type="KM100T"

mount_type = "KM100";          // "KM100" | "KM100T"

// ---------------------------------------------------------------------------
// Lookup table.  Positions are already in the CONVENTIONS frame.
// The back plate is an L-shaped bracket (one leg along the +X edge, one along the bottom);
// its +X edge sits at x = +body_w/2.  The optic axis is 25.4 mm (1.00 in) from the +X edge
// and 25.4 mm above the bottom on both mounts, so x_opt = body_w/2 - 25.4 = -0.45 mm.
// ---------------------------------------------------------------------------
MOUNT_DB = [
  ["KM100", [
    ["body_w",      49.9],              // 1.97 in overall width (drawing)
    ["body_h",      49.9],              // 1.97 in overall height (drawing)
    ["back_t",      10.2],              // 0.40 in (drawing)
    ["front_t",      8.4],              // 0.33 in (drawing, incl. ~1 mm front lip)
    ["gap",          2.5],              // 0.83 - 0.40 - 0.33 = 0.10 in (derived, nominal)
    ["knob_pos",  [[17.55, 44.4], [-19.55, 7.4]]], // A: 0.29 in from +X edge, 1.75 in up; B: 1.75 in from +X edge, 0.29 in up (drawing)
    ["knob_d",      14.8],              // 2 x 0.29 in tangent offset; scaled 0.58 in (E, consistent)
    ["knob_len",    17.3],              // 1.51 - 0.83 in (derived)
    ["knob_body_d",  6.35],             // 1/4in-80 adjuster shank between plate and knob (drawing callout)
    ["bushing_d",    8.5],              // (E) bushing flange on rear face
    ["bushing_t",    0.8],              // (E)
    ["knob_neck_len", 5.9],             // (E) exposed shank incl. bushing flange
    ["knob_collar_d", 11.4],            // (E)
    ["knob_collar_len", 3.4],           // (E)
    ["post_hole",  [-0.45, 0, 4.5]],    // #8 [M4] clearance, vertical through bottom leg at optic x (drawing: 1.00 in from +X edge)
    ["post_hole_z",  5.1],              // 0.83 - 0.63 = 0.20 in from rear face (derived)
    ["side_hole",  [25.4, 5.1, 4.5]],   // 2nd #8 [M4] clearance @90 deg: along X through +X leg, [y, z, dia] (drawing)
    ["z_hole",     [12.25, 12.7, 4.5]], // (E) [x, y, dia] Z-axis hole seen in rear view ~0.5 in from +X edge / bottom
    ["top_clear",  [[12.25, 24.95, 44.4, 5.5, "rounded lug carrying adjuster A; no lock screw"]]],
    ["leg_w",       12.7],              // (E) width of both legs of the L back plate
    ["lug_r",        5.5],              // body_h - 44.4 (derived): lug radius around adjusters
    ["inner_fillet",10.0],              // (E)
    ["optic_pos",  [-0.45, 25.4]],      // 1.00 in from +X edge, 1.00 in up (drawing)
    ["optic_bore_d", 25.4],             // accepts 1.00 in optics (drawing)
    ["optic_bore_depth", 7.0],          // 0.30 in [7.0 mm] deep (drawing)
    ["clear_ap_d",  24.0],              // 0.94 in [24.0 mm] clear aperture (drawing)
    ["sm1_thread",   0],                // plain bore + 8-32 nylon-tipped setscrew
    ["front_box",  [[-16.35, 0.5], [24.25, 41.1]]], // (E) front plate main body [min, max]
    ["front_chamfer", 7.4],             // (E) top-left chamfer
    ["front_lugs",   1],                // front plate carries lugs at both adjusters
    ["pivot_pos",  [17.55, 7.4]],       // (E) third corner, in line with both adjusters
    ["pivot_d",      3.2],              // (E) 1/8 in ball
    ["spring_pos", [[17.55, 32.4], [-7.55, 7.4]]], // (E) spring pins ~12 mm from each adjuster
    ["spring_d",     3.0],              // (E)
    ["mirror_d",    25.4],
    ["mirror_t",     6.0],
    ["adj_range_deg", 4]                // +/-4 deg typ. (Thorlabs catalog spec; not on drawing)
  ]],
  ["KM100T", [
    ["body_w",      49.9],              // 1.97 in (drawing)
    ["body_h",      49.9],              // 1.97 in (drawing)
    ["back_t",      10.2],              // 0.40 in (drawing; its "(10.7 mm)" label is a conversion error)
    ["front_t",     14.2],              // (E) 1.05 in - 0.40 in - gap; drawn as two stacked plates
    ["gap",          2.3],              // (E) scaled from side view
    ["knob_pos",  [[18.25, 44.3], [-19.55, 6.7]]], // (E) scaled: A 0.26 in from +X edge, 1.74 in up; B 1.75 in from +X edge, 0.27 in up
    ["knob_d",      13.5],              // (E) scaled 0.53 in
    ["knob_len",    18.3],              // 1.77 - 1.05 in (derived)
    ["knob_body_d",  6.35],             // 1/4-80 adjuster screws (drawing callout)
    ["bushing_d",    8.5],              // (E)
    ["bushing_t",    0.8],              // (E)
    ["knob_neck_len", 6.9],             // (E)
    ["knob_collar_d", 9.7],             // (E)
    ["knob_collar_len", 3.2],           // (E)
    ["post_hole",  [-0.45, 0, 4.5]],    // #8-32 (M4) clearance, vertical, at optic x (drawing top view, 1.00 in)
    ["post_hole_z",  5.1],              // (E) mid back plate
    ["side_hole",  [0, 0, 0]],          // none: the 2nd clearance hole runs along Z instead
    ["z_hole",     [12.25, 12.7, 4.5]], // [x, y, dia] #8-32 (M4) clearance along Z, 0.50 in from +X extent and 0.50 in up (drawing)
    ["top_clear",  [[11.25, 24.95, 44.3, 5.5, "rounded lug carrying adjuster A; no lock screw"]]],
    ["leg_w",       12.7],              // (E)
    ["lug_r",        5.5],              // (E)
    ["inner_fillet",10.0],              // (E)
    ["optic_pos",  [-0.45, 25.4]],      // 1.00 in from +X edge, 1.00 in up (drawing)
    ["optic_bore_d", 26.29],            // SM1 (1.035-40) internal thread major dia (drawing callout)
    ["optic_bore_depth", 14.2],         // (E) threaded through the front plate
    ["clear_ap_d",  26.29],
    ["sm1_thread",   1],
    ["front_box",  [[-24.75, 1.1], [23.85, 49.7]]], // 1.92 in [48.6] square centred on optic (drawing)
    ["front_chamfer", 6.4],             // (E) top-left chamfer
    ["front_lugs",   0],
    ["pivot_pos",  [18.25, 6.7]],       // (E)
    ["pivot_d",      3.2],              // (E)
    ["spring_pos", [[18.25, 30.6], [-6.55, 6.7]]], // (E) ~13 mm from each adjuster
    ["spring_d",     3.0],              // (E)
    ["mirror_d",    25.4],
    ["mirror_t",     6.0],
    ["adj_range_deg", 4]                // +/-4 deg typ. (catalog; not on drawing)
  ]],
  // Radiant Dyes MDI-2-3025-M6 (lab's mount). PROVISIONAL: from MOUNT_COMPATIBILITY.md 8.3 (drawing scaled at ~12 px/mm,
  // flag E = +/-0.5..1 mm). Regenerate the MDI parts after the caliper list in MDI_VARIANT.md. MIRROR IMAGE of the KM100:
  // the leg (and knob A) is on -X. Keys added for it (all optional, defaults = KM100 behaviour, see mpd()):
  //   handed, bracket, leg_h_bottom, knob_head_len, spring_rear_h / spring_rear_d, adj_pitch, adj_lever
  ["MDI-2-3025-M6", [
    ["handed",      -1],                // leg on -X (KM100 = +1)
    ["bracket",     "MDI"],             // attachment bracket family (attachment_params.scad)
    ["body_w",      47.0],              // (M) datasheet
    ["body_h",      47.0],              // (M)
    ["back_t",      12.0],              // (M) side view "12"
    ["front_t",      8.4],              // (E)
    ["gap",          4.2],              // (E)
    ["knob_pos",  [[-13.5, 41.1], [17.6, 9.6]]], // (E) A on top of the -X leg, B at the +X end of the bottom leg
    ["knob_d",      16.0],              // (E) brass knurled knobs 15.6..16.0 scaled
    ["knob_len",    14.2],              // (E) rear face to knob end at neutral
    ["knob_head_len", 7.9],             // (E) knurled head length
    ["knob_body_d",  5.0],              // (E) exposed screw shank
    ["bushing_d",    0],                // none visible (E)
    ["bushing_t",    0],
    ["knob_neck_len", 6.3],             // (E)
    ["knob_collar_d", 0],
    ["knob_collar_len", 0],
    ["post_hole",  [1.5, 0, 6.0]],      // M6 tapped base (x position E)
    ["post_hole_z",  6.0],              // (E)
    ["side_hole",  [25.0, 6.0, 6.0]],   // (E) M6 on the leg's outer (-X) face, [y, z, dia]
    ["z_hole",     [-13.5, 10.0, 5.0]], // (E) 3rd-screw / pivot position (empty on the MDI-2)
    ["top_clear",  [[-23.5, -5.7, 41.1, 8.0, "flat leg top y=47; knob A overhangs it behind the plate"]]],
    ["leg_w",       17.8],              // (E) vertical (-X) leg width
    ["leg_h_bottom",21.0],              // (E) bottom-leg flat top height (x +11.9..+23.5); lower toward the D22 relief
    ["lug_r",        0],                // no lug: square corner (selects the open-L-with-relief back profile)
    ["inner_fillet", 0],
    ["optic_pos",  [1.5, 25.0]],        // (M) 25 from the leg-side edge, 25 up
    ["optic_bore_d", 25.4],             // (M) 1" front plate 3025
    ["optic_bore_depth", 6.0],          // (E)
    ["clear_ap_d",  22.0],              // (M) back-plate bore D22 (also the inner-corner relief)
    ["sm1_thread",   0],
    ["front_box",  [[-20.5, 3.0], [23.5, 47.0]]], // (E) 44 x 44
    ["front_chamfer", 5.0],             // (E)
    ["front_lugs",   0],
    ["pivot_pos",  [-13.5, 10.0]],      // (E)
    ["pivot_d",      4.0],              // (E)
    ["spring_pos", [[-16.1, 29.1], [7.4, 6.3]]], // (E) spring posts with cross-pins on the REAR face
    ["spring_d",     4.0],              // (E)
    ["spring_rear_h", 2.0],             // (E, UNMEASURED) how far post + cross-pin stand proud of the rear face
    ["spring_rear_d", 6.0],             // (E) keep-out diameter (cross-pin length)
    ["mirror_d",    25.4],
    ["mirror_t",     6.0],
    ["adj_range_deg", 4],               // NOT PUBLISHED: working assumption
    ["adj_pitch",    0.25],             // Model 4 standard 250 um/turn (confirm: 20 threads over 5 mm)
    ["adj_lever",   31.1]               // (E) pivot to adjuster, both axes
  ]]
];

function _row(t)    = MOUNT_DB[search([t], MOUNT_DB, 1, 0)[0]][1];
function mp(t, key) = let(r = _row(t)) r[search([key], r, 1, 0)[0]][1];
// optional key with a default (keys added for the MDI; KM100 rows fall back to the KM100 behaviour)
function mpd(t, key, d) = let(r = _row(t), s = search([key], r, 1, 0)) (len(s) == 0 || s[0] == [] || is_undef(s[0])) ? d : r[s[0]][1];

// Flat variable set required by CONVENTIONS.md (for the selected mount_type)
body_w      = mp(mount_type, "body_w");
body_h      = mp(mount_type, "body_h");
back_t      = mp(mount_type, "back_t");
front_t     = mp(mount_type, "front_t");
gap         = mp(mount_type, "gap");
knob_pos    = mp(mount_type, "knob_pos");     // [[x1,y1],[x2,y2]] adjuster axes on rear face
knob_d      = mp(mount_type, "knob_d");
knob_len    = mp(mount_type, "knob_len");     // protrusion behind rear face (-Z)
knob_body_d = mp(mount_type, "knob_body_d");
post_hole   = mp(mount_type, "post_hole");    // [x, y(=0, bottom edge), dia]; hole axis at z = post_hole_z
post_hole_z = mp(mount_type, "post_hole_z");
top_clear   = mp(mount_type, "top_clear");    // [[x_min, x_max, lug_centre_y, lug_r, note]]
optic_pos   = mp(mount_type, "optic_pos");
leg_w       = mp(mount_type, "leg_w");
// optional (MDI review 2026-10-15); KM100 / KM100T defaults reproduce the v4 geometry exactly
handed        = mpd(mount_type, "handed", 1);          // +1: leg on +X (KM100); -1: mirror image (MDI)
bracket       = mpd(mount_type, "bracket", "KM100");
leg_h_bottom  = mpd(mount_type, "leg_h_bottom", leg_w);
knob_head_len = mpd(mount_type, "knob_head_len", 8.0);
spring_rear_h = mpd(mount_type, "spring_rear_h", 0);
spring_rear_d = mpd(mount_type, "spring_rear_d", 0);
adj_pitch     = mpd(mount_type, "adj_pitch", 25.4/80);
adj_lever     = mpd(mount_type, "adj_lever", 37.1);
