# 🖥️ Desktop Session

FORGE-OS uses a deliberately minimal graphical chain: greetd authenticates the user, `xinit` starts the X11 client session, Openbox provides the window-management substrate, and FORGE owns the visible desktop experience.

## 🔐 Authentication

`greetd` owns VT1 and runs `tuigreet` as the dedicated `greeter` account. Graphical startup uses `source_profile = false`, so shell profiles are not part of the login contract.

Tuigreet is configured with:

- the verified default command `/usr/bin/xinit /usr/local/libexec/forge-session-client`;
- X sessions restricted to `/usr/share/forge-os/xsessions`;
- Wayland sessions restricted to `/usr/share/forge-os/wayland-sessions`;
- `--no-xsession-wrapper`, preventing tuigreet from injecting its own `startx` wrapper.

## 🚀 Verified post-login command

After PAM verifies the user's credentials, the production runtime command is:

```bash
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

`session/forge-xsession` is retained as a repository-owned compatibility/recovery launcher and resolves to the same direct command.

## 🧩 Session client responsibilities

`forge-session-client`:

1. sources standard `/etc/X11/xinit/xinitrc.d` hooks when available;
2. establishes the FORGE/XDG environment contract;
3. validates that a live `DISPLAY` exists;
4. publishes relevant session variables to D-Bus/systemd activation;
5. updates XDG user directories;
6. starts notification and polkit helpers when installed;
7. starts Openbox;
8. launches `/usr/local/bin/forge-session`.

Session-stage output is written under `~/.local/state/forge/session.log`.

## 🌐 Environment contract

The graphical session exposes values including:

- `DISPLAY`
- `XAUTHORITY` when applicable
- `XDG_RUNTIME_DIR`
- `DBUS_SESSION_BUS_ADDRESS`
- `XDG_CURRENT_DESKTOP=FORGE`
- `XDG_SESSION_DESKTOP=FORGE`
- `XDG_SESSION_TYPE=x11`
- `FORGE_OS_SESSION=1`
- `FORGE_SHELL_MODE=1`
- `FORGE_OS_VERSION`

FORGE inherits this environment so its integrated terminal and launched applications behave as members of the same desktop session.

## 📦 Runtime handoff

`forge-session` resolves the installed content-addressed runtime through `/opt/forge/current`, prefers the executable path recorded in `.forge-runtime.env`, and opens the authenticated user's home directory as the default workspace.

A distributed installation therefore does not require a FORGE-OS development checkout to remain present after installation.

## 🚪 Logout and recovery

When FORGE exits, the session ends and control returns to the greeter. `Ctrl+Alt+F2` remains an independent recovery path outside the graphical chain.

See [Recovery](RECOVERY.md) for diagnostics and [Architecture](../ARCHITECTURE.md) for the full system boundary.
