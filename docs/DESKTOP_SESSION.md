# FORGE Desktop Session

The accepted reference session remains Xorg plus Openbox. `session/xinitrc`
exports the FORGE desktop identity, synchronizes the inherited X11 environment
with D-Bus and the user systemd manager, starts only minimal desktop glue, then
runs Openbox as window-management plumbing and FORGE as the visible workspace.

The staged graphical-login path uses greetd and standard PAM authentication.
It does not implement passwords in FORGE, enable automatic login, or replace
the working `startx` path. Install files with
`scripts/install-graphical-login.sh`, test from a recovery-safe console, and do
not enable the service until the human acceptance record exists.

`forge-xsession` is the greetd-to-Xorg handoff. The installer validates its
shell syntax and verifies that `/usr/local/bin/forge-xsession` is byte-for-byte
identical to the tracked launcher. An immediate return to tuigreet after a
successful PAM login usually means that this handoff exited before Xorg could
start; use the login-loop checks in `RECOVERY.md`, then rerun the installer.

Wayland and labwc are future migration candidates, not part of this milestone.
