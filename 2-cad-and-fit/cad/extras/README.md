# Interference checks

Checks that no printed part collides with the mount, the motors or the belts over the full mirror tilt range. Not needed for routine fitting; re-run after any change to a mount dimension in [`mount_params.scad`](../mount_params.scad).

| File | Contents |
|---|---|
| [`checks/clearance_check.scad`](checks/clearance_check.scad) | Check model; includes the source files two levels up |
| [`checks/run_checks.sh`](checks/run_checks.sh) | Runs all 34 cases (KM100 and KM100T) with the OpenSCAD command line; about 20 minutes |
| [`checks/last_results_KM100_KM100T.txt`](checks/last_results_KM100_KM100T.txt) | Last result: all 34 cases CLEAR |

`run_checks.sh` is a POSIX shell script (Git Bash on Windows) and needs Python for the interference report. It calls `openscad` from PATH; the `OPENSCAD` environment variable overrides the binary:

```sh
OPENSCAD=/path/to/openscad sh checks/run_checks.sh
```
