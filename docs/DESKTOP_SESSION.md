# Desktop session

greetd owns VT1 and runs tuigreet as the dedicated `greeter` account. `source_profile = false`, so graphical startup does not source system or user shell profiles.

Tuigreet is configured with:

- default command `/usr/local/bin/forge-xsession`;
- X session directory `/usr/share/forge-os/xsessions`;
- Wayland session directory `/usr/share/forge-os/wayland-sessions`;
- `--no-xsession-wrapper`, preventing the default `startx /usr/bin/env` wrapper.

After PAM authentication, `/usr/local/bin/forge-xsession` runs as the authenticated user. It selects an unused X display and invokes `/usr/bin/xinit` with the repository-owned client `/usr/local/libexec/forge-session-client` and Arch's public X server entry point `/usr/bin/X`.

The session must not invoke `/usr/lib/Xorg` directly. On Arch, `/usr/bin/X` resolves through the distribution Xorg launcher/wrapper policy and can use the setuid `Xorg.wrap` helper when the active VT/DRM device requires elevated setup rights. Bypassing that launcher was reproduced on the reference AMD laptop as `amdgpu_query_info(ACCEL_WORKING) failed (-13)` followed by `AddScreen/ScreenInit failed for driver 0`, while the standard Arch X startup path worked.

The client validates `DISPLAY`, publishes the XDG/FORGE environment to D-Bus/systemd activation, starts notification and polkit helpers, starts Openbox, and launches `/usr/local/bin/forge-session`. Session stages and failures are written to `~/.local/state/forge/session.log`.

`forge-session` resolves the content-addressed runtime through `/opt/forge/current`, prefers the executable path recorded in `.forge-runtime.env`, and opens the authenticated user's home directory by default. A development checkout at `~/FORGE-OS` is not required for the graphical session to survive.

Required session values include the live `DISPLAY`, applicable `XAUTHORITY`, `XDG_RUNTIME_DIR`, `DBUS_SESSION_BUS_ADDRESS`, `XDG_CURRENT_DESKTOP=FORGE`, `XDG_SESSION_TYPE=x11`, `FORGE_OS_SESSION=1`, `FORGE_SHELL_MODE=1`, and installed `FORGE_OS_VERSION`. `DISPLAY` is selected at runtime and is never hard-coded.

Exiting FORGE ends the X client/session and returns to the greeter. `Ctrl+Alt+F2` remains outside this chain as the recovery console.
