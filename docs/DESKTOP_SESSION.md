# 🖥️ Desktop Session

FORGE-OS supports multiple presentation profiles around the same installed FORGE runtime. The **canonical `0.2.x` production profile** is FORGE-owned native Wayland: greetd authenticates the user, the FORGE launcher starts KWin Wayland directly, Plasma supplies visual/services underneath, and FORGE owns the visible desktop experience.

For the complete session matrix, historical profiles, login commands, and compatibility rules, see [`session/README.md`](../session/README.md).

## 🔐 Authentication

`greetd` owns VT1 and runs `tuigreet` as the dedicated `greeter` account. Graphical startup uses `source_profile = false`, so shell profiles are not part of the login contract.

Tuigreet is configured with:

- canonical default command `/usr/local/bin/forge-wayland-session`;
- X sessions disabled with an intentionally absent discovery directory;
- Wayland sessions restricted to `/usr/share/forge-os/wayland-sessions`;
- `--no-xsession-wrapper`, preventing tuigreet from injecting its own `startx` wrapper.

## 🚀 Canonical post-login command

After PAM verifies credentials, the repository default is:

```bash
/usr/local/bin/forge-wayland-session
```

The repository installs a FORGE-owned Wayland desktop entry. There is no current FORGE X11 production entry.

## ⌨️ F2 development/session override

At the FORGE login screen, press **F2** to supply a complete alternate session command for that login.

The current reference machine has used:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

This is a **Plasma-hosted development override**, not the canonical release path. `startplasma-wayland` normally owns Plasma/KWin session startup while `forge-wayland-session` also starts KWin; until that handoff is normalized, the nested profile carries a duplicate compositor/session ownership risk. Stable-release validation must pass the direct default without F2.

Historical X11 builds used:

```bash
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

That command is retained as historical documentation only unless the retired X11 components are deliberately installed.

## 🧩 Canonical session responsibilities

`forge-wayland-session` and `forge-wayland-client`:

1. establish the FORGE/XDG Wayland environment contract;
2. start a D-Bus session when greetd has not supplied one;
3. start and own KWin Wayland with XWayland compatibility and session lifecycle control;
4. validate and publish `WAYLAND_DISPLAY` to D-Bus and systemd activation;
5. start KDE services and `plasmashell` as a background visual/panel layer;
6. remove only Plasma's initial stock panel, preserving user-created layouts afterward;
7. launch `/usr/local/bin/forge-session` with native Electron Wayland flags.

Session-stage output is written under `~/.local/state/forge/session.log`.

## 🌐 Environment contract

The native shell exposes values including:

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

## 🟡 Electron XWayland compatibility

Set `FORGE_USE_XWAYLAND=1` when native Electron/Ozone Wayland behavior is unsuitable. KWin remains Wayland; only the FORGE Electron window changes to its X11/XWayland backend. This is a rendering compatibility option, not a separate compositor/session generation.

## 🎨 Plasma integration

Global Breeze Dark/Kvantum and KWin defaults live under `/etc/xdg`. In the native shell, Plasma renders wallpaper and manages optional panels beneath FORGE. The stock panel is removed during first-session initialization; `forge-panel-manager` can add an edge panel that users customize through Plasma normally.

In a host-owned Plasma profile, Plasma's own panel/settings/session lifecycle should remain authoritative. FORGE should not create duplicate shell surfaces unless that profile explicitly enables them.

## 🔄 Update integration

Because the native shell exports `FORGE_OS_SESSION=1`, FORGE's **Check for updates** action selects the OS-aware path and opens `/usr/local/bin/forge-os-update` in Konsole. The helper validates trusted source origins and clean fast-forward-only `main` histories before invoking the authoritative installer. It does not accept renderer-provided commands, replace session files directly, discard local changes, or reboot automatically.

Outside the FORGE-OS shell contract, FORGE retains its standalone Electron application updater.

## 🚪 Logout and recovery

In the canonical FORGE-owned session, exiting FORGE terminates the `--exit-with-session` chain and returns control to the greeter. Host-owned profiles may delegate logout/session lifecycle to the host desktop instead.

`Ctrl+Alt+F2` remains an independent recovery path outside the graphical chain.

## 🔗 Related documentation

- [Runtime & Session Architecture](../session/README.md)
- [Architecture](../ARCHITECTURE.md)
- [User Manual](USER_MANUAL.md)
- [Shell Mode](SHELL_MODE.md)
- [Recovery](RECOVERY.md)
- [Release Checklist](RELEASE_CHECKLIST.md)
