// attachment_params.scad -- v3 parameters shared by the base block, knob caps and belts.
// Include AFTER the mount variables (mount_params_defaults.scad and/or mount_params.scad).
// Frame: CONVENTIONS.md (origin = bottom-centre of the back-plate rear face, +X right looking at
// the mirror, +Y up, +Z toward the mirror; knobs protrude in -Z). Units: mm.
//
// v2 layout (user review 2026-10-14): two NEMA 11 motors side by side in X, seated in pockets of
// ONE solid base block that rests on the +X-leg lug of the back plate. Shafts point -Z (rearward),
// bodies extend +Z over the top of the mount, so the centre of mass sits over the mount. Both
// belts run in ONE plane just behind the rear face; the knob pulleys sit on the knobs themselves.
// Drivers + controller are in a remote box: only motor leads and the encoder cables come here.
//
// v3 (2026-10-14): the output-side AS5048A encoders (magnet in the knob cap, board on an arm behind
// it) are DROPPED -- the magnet gap changed with the knob's +/-2.6 mm axial walk. Each motor is now a
// NEMA 11 with a FACTORY-FITTED rear incremental encoder (built: StepperOnline 11HS12-1004D-E1000,
// 32 mm body + 18 mm encoder, 1000 PPR = 4000 CPR, differential A/B/Z, 5 V; second choice the
// magnetic 11HS20-0674-ME1K, selectable with motor_type). The encoder
// arm, magnets and boards are gone; the knob caps are just the set-screw clamp + 66T pulley. The
// motor pockets are longer and end in an open-top cable channel for the side-exit connectors.
//
// The BRACKET (block, yoke, rear bar) is fixed geometry designed on the KM100 knob positions
// (DESIGN_KNOB below). Mount-type differences (KM100T knobs up to 0.7 mm off) are taken up by the
// motor tension ramp (motor_s) and the +/-2 mm clamp. Knob caps are printed per mount type (they follow
// knob_d / knob_len of the selected mount).

// ---------------- design reference (KM100, from mount_params.scad table) -----------------------
// v4.2 (2026-10-15): one-piece block, generated per BRACKET FAMILY from the mount row (no split block).
//   bracket = "KM100" (KM100, KM100T: fixed geometry designed on the KM100 knobs, exactly v4.1)
//           = "MDI"   (Radiant Dyes MDI-2-3025-M6, PROVISIONAL from the 8.3 estimates)
//   handed  = +1 / -1: the attachment is built in a DESIGN FRAME in which the leg is always on +X; for handed = -1 every
//             attachment part is mirrored about x = 0 at output (hand()). The knob caps are axisymmetric and are not.
//   dk(p): CONVENTIONS -> design frame.  dknob: the selected mount's knobs in the design frame.
_BM = (bracket == "MDI");
function dk(p) = [handed*p[0], p[1]];
dknob = [dk(knob_pos[0]), dk(knob_pos[1])];
module hand() { if (handed < 0) mirror([1, 0, 0]) children(); else children(); }
DESIGN_KNOB = _BM ? dknob : [[17.55, 44.4], [-19.55, 7.4]];
DESIGN_LUG_TOP = _BM ? body_h : 49.9;    // rest surface: KM100 lug crown over adjuster A; MDI flat leg top

// ---------------- motor with factory rear encoder (selectable) ------------------------------------
// motor_type = "E1000" (BUILT): StepperOnline 11HS12-1004D-E1000 -- NEMA 11, 6 N.cm (same as v2's
//      11HS12), 1.0 A, 2.0 ohm, 1.5 mH; body 32 MAX + encoder 18 +/- 1 = 50 mm; 142 g (datasheet);
//      optical incremental 1000 PPR = 4000 CPR, differential A/B/Z, 4.5..5.5 V. Drawing
//      11HS12-1004D-E1000_Dimension.svg: the connector/cable box (22 wide, 7.8 high) sits on ONE side
//      face, flange-relative z 23..48.5, and BOTH cables (motor 4-wire UL2464, encoder TRVV 4x0.14 x2)
//      leave its SHAFT-side end axially (-Z), 300 mm long.
// motor_type = "ME1K" (second choice): StepperOnline / Oyostepper 11HS20-0674-ME1K -- NEMA 11, 14 N.cm,
//      0.67 A; body 51 MAX + encoder (6.5) = 57.5 mm; magnetic 1000 PPR differential, 3.3..5.5 V;
//      ~210 g (est.); connectors on one side face at z 43.8..55, leads leave radially. Puts the COM
//      ~5 mm in FRONT of the KM100's front face (DESIGN_NOTES v3 section).
// The motor is installed with its connector face UP (+Y): the leads go into the open-top cable channel
// and leave the block's +Z end on top, never down toward the mirror.
motor_type     = "E1000";
_E = (motor_type == "E1000");
motor_w        = 28.2;
motor_body_len = _E ? 32.0 : 51.0;   // stator body, flange face to the encoder housing
motor_enc_len  = _E ? 18.0 : 6.5;    // encoder housing behind the body
motor_len      = motor_body_len + motor_enc_len;   // 50 / 57.5: flange face to the rear end
motor_chamfer  = 2.0;        // 45 deg corner chamfer leg (VERIFY on the real motor; ramp follows it)
motor_pilot_d  = 22.0;
motor_pilot_h  = 2.0;
motor_shaft_d  = 5.0;
motor_shaft_l  = 20.0;       // front shaft length from the flange face (datasheet 20 +/- 0.5; >= 19 needed)
motor_hole_sp  = 23.0;       // 4x M2.5 (not used by the pocket)
// connector / cable box on the +Y face (scaled off the datasheet drawings: VERIFY on the part)
conn_z    = _E ? [23.0, 48.5] : [43.8, 55.0];   // flange-relative Z span
conn_w    = _E ? 22.0 : 25.0;                   // X width
conn_h    = _E ? 7.8  : 3.0;                    // height above the motor's +Y face
lead_exit_rear = _E;                            // E1000: cables leave the box toward -Z, then U-turn up and forward
lead_d    = _E ? 4.0 : 3.5;                     // cable OD
chan_ch   = 4.0;                                // v4: chamfer on the top wall's front edge (cable lead-in)
lead_R    = 7.0;                                // v4: centreline radius of the E1000 cables' U-turn (largest that clears the top wall)
lead_x    = _E ? [-3.5, 2.5] : [0];             // cable X offsets on the box
// mass (g) at mid-body / at the encoder end (E1000: 142 g total on the datasheet, split estimated)
motor_mass_body = _E ? 120 : 190;
motor_mass_enc  = _E ? 22  : 20;
motor_mass      = motor_mass_body + motor_mass_enc;

// ---------------- pulleys / belts ------------------------------------------------------------
motor_teeth  = 16;           // metal GT2 16T, 5 mm bore, for 10 mm belt (wide face, 6 mm belt walks on it)
knob_teeth   = _BM ? [52, 52] : [66, 66];   // printed on the caps. KM100 66/16 = 4.125. MDI 52/16 = 3.25: the knobs are 44.3 apart and
                             // belt B must pass cap A with the motor pair kept over the mount (MDI_VARIANT.md 4); 60T leaves belt B 4-5 mm INSIDE cap A's flange
belt_w       = 6;
belt_L       = _BM ? [140, 200] : [158, 220];   // GT2-6 closed loops [A, B] (stock sizes, nominal mid-ramp)
belt_preload = 0.3;          // centre-distance over zero slack at motor_s = 0
// metal 16T pulley, 10 mm-belt type (VERIFY against the purchased part)
mp_face      = 11.0;         // width between flanges (6 mm belt walks +/-2.5 with the knob)
mp_flange_t  = 1.0;
mp_flange_d  = 15.0;
mp_hub_d     = 13.0;
mp_hub_l     = 6.0;          // v4.1: Spool3D listing 19 mm overall - 11 face - 2x1 flange (was 7.0; VERIFY)
mp_gap       = 1.0;          // v4.1: hub face to pilot boss (was 1.5 flange-to-pilot when hub-out)
mp_len       = mp_hub_l + mp_face + 2*mp_flange_t;
// v4.1 (no-adhesive decision 2026-10-15): mounted HUB-IN (hub toward the motor). Hub-out put the grub ~19.5 mm out on a
// 20 +/- 0.5 shaft (half off the end). Hub-in puts it mp_grub_z = 6.0 from the flange face: 14 mm inside the shaft end,
// on the (filed, E1000 / factory, ME1K) flat. Cost: the motor sits 5.5 mm further forward (+Z) in a 5.5 mm longer tube.
// The grub is reached through an access slot in the tube's top wall (acc_slot_*), belt installed.
mp_hub_in    = true;
d_mp         = mp_hub_in ? motor_pilot_h + mp_gap + mp_hub_l + mp_flange_t + mp_face/2      // 15.5
                         : motor_pilot_h + mp_gap + mp_flange_t + mp_face/2;                // (v4: 10.0 with gap 1.5)
mp_grub_z    = motor_pilot_h + mp_gap + mp_hub_l/2;   // grub axis from the motor flange face (hub-in): 6.0
acc_slot_w   = 5.0;          // top-wall access slot over the 16T grub (x width; covers ramp s +/-1.5 for a 1.5 key)

// ---------------- knob pulley / cap ------------------------------------------------------------
kp_face      = belt_w + 0.6; // 6.6: the knob pulley GUIDES the belt (flanged), the belt walks on the motor pulley
kp_flange_t  = 1.0;
kp_flange_x  = 1.5;          // flange height above the pitch circle (belt back is +1.13)
kp_len       = kp_face + 2*kp_flange_t;           // 8.6
kp_front_z   = _BM ? -ceil((adj_lever*tan(adj_range_deg) + spring_rear_h + 0.5)*10)/10   // MDI: walk 2.17 + spring posts 2.0 (E) + 0.5 = -4.7
                   : -3.2;   // KM100: global z of the pulley front face at neutral knob (2.6 walk + 0.6 to the plate)
z_belt       = kp_front_z - kp_flange_t - kp_face/2;   // -7.5: the single belt plane (both axes)
kx_bore_clr  = 0.6;          // v4 (MJF review): diametral clearance on the knob head. MJF PA12 holds +/-0.3 and bores
                             // print small, so v3's 0.4 could close to ~0.1. The 3 set screws centre the cap. VERIFY knob_d (E) with calipers
                             // and with MIR_fit_coupon_v1 (bores at +0.4/+0.5/+0.6).
kp_add_w     = 0.1;          // v4: GT2 groove-width compensation for the printed 66T. v3 used the FDM value 0.2; MJF grooves
                             // close up less than FDM ones, so 0.1 (tooth tip land 0.41 instead of 0.31). Test-fit a belt on the spare cap.
kx_hub_d     = 26.0;         // set-screw hub (M3 inserts radial)
kx_floor_t   = 1.6;          // v3: thin end wall (axial seat on the knob end); was 3.0 for the magnet pocket
kx_key_d     = 3.2;          // v3: hex-key hole through the end wall (manual override with the drivers off)
kx_screw_dz  = 3.0;          // set-screw axis this far in front of the knob end face (on the knurled head)
// v4.2: SHORT-KNOB GRIP. When the pulley leaves < 5 mm of knurl behind it (MDI: knob 14.2 proud, pulley front at -4.7 to clear
// the spring posts -> pulley rear face 0.9 mm in front of the knob END), the cap grips with 3 INCLINED M3 x 10 cup-point
// set screws: inserts in a rear hub behind the knob end, screws running forward-inward at kx_incl_ang from radial THROUGH
// the pulley web (inside the tooth root) to the middle of the knurled head (kx_incl_zc in front of the knob end).
kx_grip      = (knob_len + kp_front_z - kp_len >= 5) ? "radial" : "inclined";
kx_incl_ang  = 50;           // deg from radial (0 = radial)
kx_incl_zc   = min(4.5, knob_head_len - 2.5);   // contact on the knurl, from the knob end face
kx_incl_L    = 10;           // M3 x 10 cup point; insert flush with a spot face at t = L
kx_rear_t    = 6.5;          // rear hub thickness behind the knob end face
kx_hub_d_incl = 35.0;        // rear hub OD (inserts need r <= 17.4 incl. 1.5 mm wall)

function gt2pd(t) = t*2/PI;
D1 = gt2pd(motor_teeth);
function D2(i) = gt2pd(knob_teeth[i]);
function kp_rf(i) = D2(i)/2 + kp_flange_x;           // knob pulley flange radius

// knob axial travel over the full +/-4 deg range (for clearance checks)
knob_travel = adj_lever * tan(adj_range_deg);       // ~2.6 mm

// ---------------- encoder: on the motor (factory-fitted, rear) -------------------------------------
enc_cpr      = 4000;         // 1000 PPR quadrature, + index (Z), differential, 3.3..5.5 V supply

// ---------------- belt geometry ------------------------------------------------------------------
function belt_len(C, i) = 2*C + PI*(D1 + D2(i))/2 + pow(D2(i) - D1, 2)/(4*C);
function c_for_len(L, i, lo=5, hi=600, n=60) =
    n == 0 ? (lo+hi)/2 :
    belt_len((lo+hi)/2, i) < L ? c_for_len(L, i, (lo+hi)/2, hi, n-1) : c_for_len(L, i, lo, (lo+hi)/2, n-1);

// ---------------- motor positions ----------------------------------------------------------------
// Each motor rides on a 45 deg ramp at the lower INNER corner of its pocket; the two outer-wall set
// screws push it inward, which lifts it (tension). motor_s = slide along the ramp, +/-1.5 mm:
// motor centre = nominal + s*(inward, up).
motor_x0  = _BM ? [8.75, -26.75] : [11.75, -23.75];   // nominal X (design frame; MDI from the layout search in MDI_VARIANT.md)
inward    = [-1, 1];                         // +X/-X direction toward the centre wall
s_range   = 1.5;
function y0_for(i) = let(C = c_for_len(belt_L[i], i) + belt_preload, dx = motor_x0[i] - DESIGN_KNOB[i][0])
                     DESIGN_KNOB[i][1] + sqrt(C*C - dx*dx);
motor_y0  = [y0_for(0), y0_for(1)];          // ~78.4 / ~74.35
// ramp shift needed for the SELECTED mount (knob_pos of mount_type) to reach the same preload
function _C(i, s) = norm([motor_x0[i] + inward[i]*s, motor_y0[i] + s] - dknob[i]);
function s_req(i, lo=-3, hi=3, n=40) = let(Ct = c_for_len(belt_L[i], i) + belt_preload)
    n == 0 ? (lo+hi)/2 : (_C(i, (lo+hi)/2) < Ct ? s_req(i, (lo+hi)/2, hi, n-1) : s_req(i, lo, (lo+hi)/2, n-1));
function motor_xy(i, s) = [motor_x0[i] + inward[i]*s, motor_y0[i] + s];

// ---------------- Z stack ---------------------------------------------------------------------------
z_flange  = z_belt + d_mp;                   // 2.5: motor flange face (nominal slide)
z_slide   = [-0.8, 4.0];                     // allowed slide (rear limit: motor-A pilot vs cap-A flange at full walk)
blk_z0    = 0.0;                             // block rear face (pulley side) -- never behind the rear face
blk_zf    = back_t;                          // full-depth section (down to blk_bot) only over the back plate;
                                             // in front of it the underside steps up to the pocket floors
blk_z1    = z_flange + motor_len;            // 60.0: block front face = motor rear end at nominal slide
z_rib     = z_flange + z_slide[0];           // front stop rib: the flange face lands on it at the -0.8 limit
z_chan    = z_flange + z_slide[0] + conn_z[0] - (lead_exit_rear ? 9.0 : 1.0);   // top wall ends here; open-top
                                             // cable channel from here to blk_z1 (room for the E1000 cables' U-turn)
tie_z     = blk_z1 - 4.5;                    // cable-tie notches (one tie around the front end holds both lead bundles)

// ---------------- base block ------------------------------------------------------------------
pk_clr    = 0.15;                            // per side
pk_half   = motor_w/2 + s_range + pk_clr;    // 15.75: half pocket (float for the ramp)
ramp_K    = motor_w - motor_chamfer + 0.1;   // ramp line u - v = K (u inward, v up, pocket-local)
rib_K     = motor_w - motor_chamfer - 4.0;   // stop rib in the OUTER-TOP corner: -u + v >= rib_K. The motor's
                                             // outer-top chamfer stays on -u + v = 26.2 for every ramp shift s
                                             // (it slides along it), so the rib always overlaps the flange by 4.0;
                                             // the pilot (r 11) stays 4.7 mm clear of the rib
wall      = 4.0;                             // all pocket walls >= 4
boss_h    = 2.0;  boss_d = 9.0;              // set-screw bosses stand proud of the 4 mm walls
blk_bot   = _BM ? 50.0 : 52.5;               // block underside over the front plate (KM100T top 49.7 + 1.1 tilt + margin; MDI 47 + 1.5 + 1.5)
blk_x0    = motor_x0[1] - pk_half - wall;    // -43.5
blk_x1    = motor_x0[0] + pk_half + wall;    // 31.5
blk_top   = [motor_y0[0] + pk_half + wall, motor_y0[1] + pk_half + wall];
sc_z      = [z_flange + 6, z_flange + motor_body_len - 6];   // outer-wall set screws, on the stator body
top_sc_z  = min(z_flange + 21, z_chan - boss_d/2 - 1.5);     // top-wall set screw, behind the cable channel

// ---------------- yoke on the +X leg ----------------------------------------------------------
xR         = body_w/2;               // +X edge of the back plate (24.95)
x_leg_in   = xR - leg_w;             // inner face of the +X leg (12.25)
clamp_clr  = 2.0;                    // nominal gap per side; M4 set screws take up +/-2
cheek_t    = 7.0;
x_co0 = xR + clamp_clr;      x_co1 = x_co0 + cheek_t;      // outer cheek  26.95 .. 33.95
x_ci1 = x_leg_in - clamp_clr; x_ci0 = x_ci1 - cheek_t;     // inner cheek   3.25 .. 10.25
yoke_zmax  = 7.5;                    // contact parts in the L opening: front plate swings back ~4 mm at +/-4 deg
cheek_out_y = _BM ? [44, 18] : [40, 20.5];            // outer-cheek M4 heights (KM100 side X-hole at y 25.4 +/-2.25 stays free: M4 thread edge 0.65 clear)
                                     // v4: lower screw 18 -> 20.5. In v3 its M4 insert (y 18, z 2.35..7.85) and the rear-bar
                                     // M3 bolt insert below it (x 30.45, y 16, z 0..4.5) OVERLAPPED by ~1.7 mm: the second insert
                                     // could not have been installed and the M3 bolt would have run into the M4 insert.
cheek_out_bot = _BM ? 1 : 5;          // MDI: rear-bar bolts sit low (y 4.5 / 10)
cheek_in_y  = _BM ? [42] : [37, 43]; // MDI: one datum screw between the outer pair; the leg's inner face is flat only
                                     // y 34..47 and the cheek must stay above the D22 bore (top y 36)
                                                  // inner-cheek set-screw heights (flat inner face y 22.7..44.3)
// v4: the inner cheek is only yoke_zmax = 7.5 thick in Z, so an M4 insert (hole 5.5) left 1.0 mm walls; the inner (datum)
// screws are now M3 (hole 3.9: 1.8 mm walls) in M3 x 4.3 inserts, M3 x 10 brass-tip set screws. The outer clamp screws stay M4.
cheek_in_m  = 3;
cheek_in_bot = _BM ? 36.2 : 33.5;
cheek_z    = [3.75, 5.1];            // screw axis z: inner (thin) / outer cheek
// rear bar (separate part) behind the leg, below the knob-A pulley
rear_t     = 6.5;                    // flat both faces (prints back-face down, no bosses)
rear_g     = 0.5;                    // stand-off from the rear face (only the screw tips touch)
rear_y     = _BM ? [1.5, 18] : [4, 20];                // v4: was [5, 19]; the M4 inserts (D5.5 at y 8.5 / 15.5) had 0.75 mm walls, now 1.75.
                                     // y 20 stays 1.9 (KM100) / 1.8 (KM100T) below cap A's flange (y 21.9 / 21.8)
rear_screw_pos = _BM ? [[20.5, 6], [20.5, 13.5]] : [[18.6, 8.5], [18.6, 15.5]];   // 2x M4 pushing +Z on the leg rear face
rear_bolt_y    = _BM ? [4.5, 10] : [8.5, 14];                     // 2x M3 x 12 into the outer cheek rear face (v4: was [9, 16], see cheek_out_y;
                                                // walls: 1.55 to the cheek bottom, 1.6 between the inserts, 1.8 to the M4 insert)
// left post + foot (2nd vertical support on the TOP of the bottom leg)
post_x     = [-21, -13];             // outside the clear aperture (x >= -12.45) and the knob-B pulley plane
post_zmax  = 6.0;                    // front plate swings back up to ~5.6 mm at the top-left corner
foot_x     = [-21, -12.5];          // stays left of the clear-aperture shadow (x >= -11.95 at y = 22)
foot_boss  = _BM ? [] : [[-12.5, -10.5], [13.2, 18.5]];   // v4.1: low-set foot insert needs 2.3 mm wall on +X; local boss only below
                                     // y 18.5, where the aperture shadow starts at x >= -10.27
foot_y     = _BM ? [leg_h_bottom + 0.5, leg_h_bottom + 12.8] : [13.2, 25.5];           // foot underside 0.5 above the leg top (y 12.7); screw does the contact
                                     // v4: top raised 22 -> 25.5 so the foot-screw insert (y 20.8..24.8) sits in the z 0..8 foot.
                                     // In v3 it sat in the z 0..6 post and its pocket (z 1.2..6.8) broke through the post's front face.
foot_ins_low = true;                 // v4.1: foot insert at the leg end of the bore (seat 0.9 along the axis from the tip):
foot_seat_t  = 0.9;                  // M3 x 10 brass tip (90418A111, as the inner cheeks), +/-2 mm travel with >= 3.2 mm engaged
foot_m     = 3;                      // v4: foot screw M3 (insert walls 2.05 in z; an M4 insert would leave 1.25). The foot carries
                                     // ~3 N; use an M3 x 16 flat- or brass-tip set screw.
foot_zmax  = 8.0;
foot_tip   = _BM ? [-15.5, leg_h_bottom, 4.0] : [-14.0, 12.7, 4.0];     // M4 set-screw tip on the leg top
foot_ang   = 30;                     // screw axis tilted 30 deg from vertical toward -X (hex key from upper left)

// NEMA 11 outline with 45 deg corner chamfers of leg motor_chamfer (pocket ramp follows it)
module motor_profile_2d() {
    h = motor_w/2; c = motor_chamfer;
    polygon([[-h + c, -h], [h - c, -h], [h, -h + c], [h, h - c], [h - c, h], [-h + c, h], [-h, h - c], [-h, -h + c]]);
}

// ---------------- inserts / screws ---------------------------------------------------------
// v4 (MJF review): inserts as ORDERED (06_Parts_Orders/MASTER_BOM.md): McMaster 94459A130 (M3, 4.3 mm installed length,
// max hole 4.0, drill 22 ga = 3.99) and 94459A150 (M4, 4.7 mm, max hole 5.6, drill 7/32 = 5.56). For MJF PA12 the hole is
// 0.1 under the maker's max (nylon is tough and MJF holes print slightly small; verify with MIR_fit_coupon_v1).
// Pocket depth = insert length + 0.5 (melt room). Every screw passage BEYOND an insert is a CLEARANCE hole: no printed or
// self-tapped thread anywhere (v3 continued each insert with a 2.6 / 3.4 tap-drill hole that a set screw would have had to
// cut its own thread through).
ins3_d = 3.9;  ins3_l = 4.3 + 0.5;   // M3 x 4.3 heat-set insert (94459A130)
ins4_d = 5.5;  ins4_l = 4.7 + 0.5;   // M4 x 4.7 heat-set insert (94459A150)
m3_clr = 3.4;  m4_clr = 4.5;         // clearance past the insert (MJF -0.3 still passes the screw)
m3_tap = 2.6;  m4_tap = 3.4;         // v4: NOT used for any printed hole any more (only the visual set-screw solids)
knob_sweep_d = 20;                   // v1 finger-access rule around each knob (now covered by the cap)

// ---------------- materials (COM estimate) ---------------------------------------------------
rho_pla   = 1.24;                    // g/cm^3
