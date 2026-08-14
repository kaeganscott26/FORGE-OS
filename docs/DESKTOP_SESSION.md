# 🖥️ Desktop Session

FORGE-OS uses a controlled native-Wayland chain: greetd authenticates the user, the FORGE launcher starts KWin Wayland directly, Plasma supplies visual services underneath, and FORGE owns the visible desktop experience.

## 🔐 Authentication

`greetd` owns VT1 and runs `tuigreet` as the dedicated `greeter` account. Graphical startup uses `source_profile = false`, so shell profiles are not part of the login contract.

Tuigreet is configured with:

- the default command `/usr/local/bin/forge-wayland-session`;
- X sessions disabled with an intentionally absent discovery directory;
- Wayland sessions restricted to `/usr/share/forge-os/wayland-sessions`;
- `--no-xsession-wrapper`, preventing tuigreet from injecting its own `startx` wrapper.

## 🚀 Verified post-login command

After PAM verifies the user's credentials, the production runtime command is:

```bash
/usr/local/bin/forge-wayland-session
```

The repository also installs a FORGE-owned Wayland desktop entry. There is no FORGE X11 entry.

## 🧩 Session client responsibilities

`forge-wayland-session` and `forge-wayland-client`:

1. establish the FORGE/XDG Wayland environment contract;
2. start a D-Bus session when greetd has not supplied one;
3. start KWin Wayland with XWayland compatibility and session lifecycle control;
4. validate and publish `WAYLAND_DISPLAY` to D-Bus and systemd activation;
5. start KDE services and `plasmashell` as a background visual/panel layer;
6. remove only Plasma's initial stock panel, preserving user-created layouts afterward;
7. launch `/usr/local/bin/forge-session` with native Electron Wayland flags.

Session-stage output is written under `~/.local/state/forge/session.log`.

## 🌐 Environment contract

The graphical session exposes values including:

- `WAYLAND_DISPLAY`
- `DISPLAY` for XWayland compatibility when available
- `XAUTHORITY` when applicable
- `XDG_RUNTIME_DIR`
- `DBUS_SESSION_BUS_ADDRESS`
- `XDG_CURRENT_DESKTOP=FORGE`
- `XDG_SESSION_DESKTOP=FORGE`
- `XDG_SESSION_TYPE=wayland`
- `FORGE_OS_SESSION=1`
- `FORGE_SHELL_MODE=1`
- `FORGE_OS_VERSION`

FORGE inherits this environment so its integrated terminal and launched applications behave as members of the same desktop session.

## 📦 Runtime handoff

`forge-session` resolves the installed content-addressed runtime through `/opt/forge/current`, prefers the executable path recorded in `.forge-runtime.env`, and opens the authenticated user's home directory as the default workspace.

A distributed installation therefore does not require a FORGE-OS development checkout to remain present after installation.

## Plasma integration

Global Breeze Dark/Kvantum and KWin defaults live under `/etc/xdg`. Plasma renders wallpaper and manages optional panels, but the stock panel is removed during first-session initialization so no conventional desktop layout is imposed. `forge-panel-manager` adds an edge panel with standard Plasma widgets; users then customize that panel through Plasma normally. FORGE remains the primary interface.

## 🔄 Update integration

Because the session exports `FORGE_OS_SESSION=1`, FORGE's **Check for updates** action selects the OS-aware path and opens `/usr/local/bin/forge-os-update` in Konsole. The helper validates the official source origins and clean fast-forward-only `main` histories before invoking the authoritative installer. It does not accept renderer-provided commands, replace the session files directly, discard local changes, or reboot automatically.

Outside the FORGE-OS session contract, FORGE retains its standalone Electron application updater.

## 🚪 Logout and recovery

When FORGE exits, the session ends and control returns to the greeter. `Ctrl+Alt+F2` remains an independent recovery path outside the graphical chain.

See [Recovery](RECOVERY.md) for diagnostics and [Architecture](../ARCHITECTURE.md) for the full system boundary.
