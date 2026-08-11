# Desktop session

greetd owns VT1 and runs tuigreet as the dedicated `greeter` account. After PAM authentication, greetd runs `/usr/local/bin/forge-xsession` as the authenticated user. That launcher exports the FORGE-OS contract and invokes `/usr/bin/xinit` with the repository-owned client `/usr/local/libexec/forge-session-client` and `/usr/lib/Xorg` explicitly.

The client publishes the environment to D-Bus/systemd user activation, starts notification and polkit helpers, starts Openbox, and launches FORGE. It logs session stages and failures to `~/.local/state/forge/session.log`. Exiting FORGE ends the X session and returns to the greeter.

Required values include the real `DISPLAY`, applicable `XAUTHORITY`, `XDG_RUNTIME_DIR`, `DBUS_SESSION_BUS_ADDRESS`, `XDG_CURRENT_DESKTOP=FORGE`, `XDG_SESSION_TYPE=x11`, `FORGE_OS_SESSION=1`, `FORGE_SHELL_MODE=1`, and the installed `FORGE_OS_VERSION`. `DISPLAY` is established by Xorg and is never hard-coded.
