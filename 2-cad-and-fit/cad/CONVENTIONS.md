# CAD conventions

Units: millimetres. OpenSCAD 2021.01 (command line: `openscad` on PATH).

## Coordinate frame

Shared by the mount models, the attachment and the assembly.

- Origin: bottom centre of the rear face of the stationary (back) plate.
- +X: to the right, viewed from the front (mirror side).
- +Y: up.
- +Z: from the back plate toward the front (mirror) plate. The adjuster knobs protrude in -Z.
- Back plate occupies z in [0, back_t]; air gap; front plate z in [back_t + gap, back_t + gap + front_t].

## Shared parameters

`mount_params.scad` holds the mount dimensions. The attachment files use the same variable names with their own defaults (`mount_params_defaults.scad`), and `mount_params.scad` is included last so its values take precedence.

| Variable | Meaning |
|---|---|
| `mount_type` | `"KM100"`, `"KM100T"` or `"MDI-2-3025-M6"` |
| `body_w`, `body_h` | Back-plate width and height |
| `back_t` | Back-plate thickness (z) |
| `front_t` | Front-plate thickness |
| `gap` | Nominal plate gap at neutral adjustment |
| `knob_pos` | `[[x1,y1],[x2,y2]]`: adjuster axis positions on the back-plate rear face |
| `knob_d`, `knob_len` | Adjuster knob diameter and protrusion in -Z |
| `knob_body_d` | Diameter of the adjuster bushing between knob and plate, if any |
| `post_hole` | `[x, y, dia]`: mounting hole on the bottom edge |
| `top_clear` | Features on the top edge of the back plate (lock screw, etc.) |

## Rendering

STLs are exported with `--render`; preview PNGs with `--preview`.
