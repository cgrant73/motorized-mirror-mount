// mount_params_defaults.scad
// Attachment agent's defaults for the Thorlabs KM100 / KM100T, using the shared
// variable names from CONVENTIONS.md. The mount agent's mount_params.scad is the
// authority: an assembly should `include <mount_params_defaults.scad>` FIRST and
// `include <mount_params.scad>` AFTER it (in OpenSCAD the last assignment wins).
//
// Frame (CONVENTIONS.md): origin = bottom-centre of back-plate rear face,
// +X right (viewed from the mirror side), +Y up, +Z toward the front (mirror) plate.
// Back plate z in [0, back_t]; knobs protrude in -Z.
//
// Sources: Thorlabs drawings in ../reference_drawings/
//   KM100  6628-E0W rev C : 1.97" (49.9) square envelope, back plate 0.40" (10.2),
//          front plate 0.33" (8.4), 0.83" (21.1) plate stack, 1.51" (38.4) to knob ends,
//          adjusters 0.29" (7.4) from the edges at 1.75" (44.4/44.5) -> pivot-to-adjuster 37.1 mm,
//          optic centre 1.00" from the +X edge and the bottom.
//   KM100T 6634-E01 rev D : 1.97" envelope, 1.92" (48.6) square front plate, 1.05" stack,
//          1.77" (44.9) to knob ends.
// The back plate is an L (one leg up the +X edge carrying adjuster A, one leg along the
// bottom carrying adjuster B); its only "top edge" is the rounded lug around adjuster A.
// (E) = estimated by scaling the drawing.

// v4.2 (MDI variant, 2026-10-15): the defaults now come straight from MOUNT_DB in mount_params.scad, so a new
// mount_type (e.g. "MDI-2-3025-M6") works in every part file. The KM100 / KM100T values are identical to the
// hand-written v3 defaults this replaced (checked: same STLs).
include <mount_params.scad>
pivot_pos     = mp(mount_type, "pivot_pos");
knob_collar_d = mp(mount_type, "knob_collar_d");
bushing_d     = mp(mount_type, "bushing_d");
lug_r         = mp(mount_type, "lug_r");
side_hole     = mp(mount_type, "side_hole");
z_hole        = mp(mount_type, "z_hole");
adj_range_deg = mp(mount_type, "adj_range_deg");
// knob_head_len, adj_pitch, adj_lever, handed, bracket, leg_h_bottom, spring_rear_*: flat in mount_params.scad
