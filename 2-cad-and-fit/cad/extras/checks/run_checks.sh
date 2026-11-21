#!/bin/sh
# v3: runs all clearance checks (both mounts) in parallel; prints CLEAR or the interference bbox.
#   sh checks/run_checks.sh            # all
#   CHECKS="belts" sh checks/run_checks.sh
# Matrix per mount:
#   mount   : tilts at the 4 corners (one case; includes motors at nominal)
#   caps    : t = -1, +1
#   belts   : t = -1, +1  x  s = -1, +1
#   pulleys : t = -1, +1
#   motors  : (s, dz, t) = (-1,-1,+1) (+1,+1,-1) (-1,+1,-1) (+1,-1,+1)
# OpenSCAD binary: "openscad" on PATH by default; override with OPENSCAD=/path/to/openscad
OS="${OPENSCAD:-openscad}"
cd "$(dirname "$0")"
OUT=${OUT:-out}
mkdir -p $OUT
rm -f $OUT/*
CHECKS=${CHECKS:-"mount caps belts pulleys motors screws capmount"}
MOUNTS=${MOUNTS:-"KM100 KM100T"}
run() { # name defs...
  N=$1; shift
  ( "$OS" "$@" -o $OUT/$N.stl clearance_check.scad > $OUT/$N.log 2>&1 ) &
}
for MT in $MOUNTS; do
  M="-D mount_type=\"$MT\""
  for C in $CHECKS; do
    case $C in
      mount)   run ${MT}_mount -D "mount_type=\"$MT\"" -D 'check="mount"' ;;
      caps)    for T in -1 1; do run ${MT}_caps_t$T -D "mount_type=\"$MT\"" -D 'check="caps"' -D t=$T; done ;;
      belts)   for T in -1 1; do for S in -1 1; do run ${MT}_belts_t${T}_s$S -D "mount_type=\"$MT\"" -D 'check="belts"' -D t=$T -D s=$S; done; done ;;
      screws)  for T in -1 1; do run ${MT}_screws_t$T -D "mount_type=\"$MT\"" -D 'check="screws"' -D t=$T; done ;;
      capmount) for T in -1 1; do run ${MT}_capmount_t$T -D "mount_type=\"$MT\"" -D 'check="capmount"' -D t=$T; done ;;
      pulleys) for T in -1 1; do run ${MT}_pulleys_t$T -D "mount_type=\"$MT\"" -D 'check="pulleys"' -D t=$T; done ;;
      motors)  for V in "-1 -1 1" "1 1 -1" "-1 1 -1" "1 -1 1"; do set -- $V
                 run ${MT}_motors_s$1_dz$2_t$3 -D "mount_type=\"$MT\"" -D 'check="motors"' -D s=$1 -D dz=$2 -D t=$3; done ;;
    esac
  done
  wait
done
wait
for f in $OUT/*.log; do
  b=${f%.log}
  if grep -qi "Current top level object is empty" $f; then echo "$(basename $b): CLEAR"
  elif grep -qiE "^ERROR|WARNING" $f; then echo "$(basename $b): ERROR/WARNING -> see $f"
  else
    python -c "
import sys
v=[tuple(map(float,l.split()[1:4])) for l in open('$b.stl') if l.strip().startswith('vertex')]
if not v: print('$(basename $b): no output'); sys.exit()
mn=[min(p[i] for p in v) for i in range(3)]; mx=[max(p[i] for p in v) for i in range(3)]
print('$(basename $b): INTERFERENCE bbox', [round(a,2) for a in mn], [round(a,2) for a in mx])"
  fi
done
