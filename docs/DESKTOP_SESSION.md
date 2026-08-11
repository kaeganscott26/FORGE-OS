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

Wayland and labwc are future migration candidates, not part of this milestone.
