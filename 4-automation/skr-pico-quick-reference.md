# SKR Pico quick reference (mirror box, pin map `SKRP`)

Excerpt of `05_PyBirch_Drivers/firmware/HARDWARE.md` (pin map `SKRP` and §3, "Flashing") and `07_Electronics_Package/SYSTEM_OVERVIEW.md` §3, limited to the one-mount SKR Pico box. Where this file and those sources disagree, the sources take precedence. Not yet tested on hardware.

## 1. Board setup

- **Jumpers:** JP3 fitted (USB powers the logic and the encoders while the 24 V is off). All four DIAG jumpers (X, Y, Z, E0-DIAG) removed; fitted, they connect the drivers to the encoder inputs. BOOT jumper used only for flashing.
- **Motors:** motor X (tilt X, channel A1) in socket X; motor Y (tilt Y, channel A2) in socket Y.
- **24 V:** power screw terminal. The board has no reverse-polarity protection.
- **USB-C:** to the lab PC.

## 2. Encoder wiring

Each endstop socket is a 3-pin XH: pin 1 signal, pin 2 GND, pin 3 5 V. The socket names are crossed relative to the axes.

| Wire | Socket | Pin |
|---|---|---|
| Encoder X: A+, GND, +5 V | Y-STOP | 1, 2, 3 |
| Encoder X: B+ | X-STOP | 1 |
| Encoder Y: A+, GND, +5 V | Z-STOP | 1, 2, 3 |
| Encoder Y: B+ | E0-STOP | 1 |
| A-, B-, Z+, Z- (both encoders) | not used | cut short and insulated |

Splices follow connector pin position, not wire colour (colours vary by seller).

## 3. First boot (before the encoders or the 24 V are connected)

The default pin map drives the encoder input pins as outputs. The sequence below is therefore run with the 24 V off and the encoders unplugged.

1. Flash MicroPython: BOOT jumper fitted, reset, standard `RPI_PICO` UF2 (v1.22 or later) copied to the drive that appears; BOOT jumper removed.
2. All firmware files except `main.py` copied with `mpremote`; pin map written with
   `mpremote exec "open('/motion.cfg','w').write('PINMAP SKRP\n')"`.
3. `main.py` copied, board reset. Expected: `PINMAP?` returns `OK SKRP SKRP`; `AXES?` returns `OK 2`.
4. Encoders and 24 V connected only after step 3 passes.

## 4. Expected behaviour

- USB only: drivers do not respond; `STAT?` shows `DRV=OFF` and moves are refused (`ERR 10`). `DRV=OK` appears about one second after 24 V is applied.
- Motor speed is capped at 300 rpm on this board.
- One full hand turn of a motor shaft changes `A1 ENC?` (or `A2 ENC?`) by about ±4000 counts.
