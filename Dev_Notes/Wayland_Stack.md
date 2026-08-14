# FORGE-OS Wayland Stack

## Implemented architecture

FORGE-OS `0.2.1-alpha` uses a FORGE-owned native Wayland session:

```text
greetd / tuigreet
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland with XWayland compatibility
  -> Plasma visual, wallpaper, portal, and optional panel services
  -> native-Wayland FORGE
```

The production session deliberately does not use SDDM, Hyprland, an Xorg login session, or `startplasma-wayland`. KWin is the compositor and window manager. Plasma operates underneath FORGE for decorations, animation, effects, wallpaper, and user-created panels; FORGE remains the visible desktop environment.

## Installed stack

The declared graphical stack includes:

- `wayland`, `kwin`, `plasma-desktop`, and `plasma-workspace`;
- `xorg-xwayland` only for applications that cannot run natively on Wayland;
- `xdg-desktop-portal` with KDE as the preferred backend and GTK fallback;
- `qt6-wayland` and `qt5-wayland` for native Qt clients;
- Breeze Dark, Breeze icons, Kvantum, and KDE GTK configuration;
- Dolphin, System Settings, KDialog, Konsole, and the KDE PolicyKit agent;
- PipeWire and WirePlumber for desktop audio and portal integration.

The retired production stack—Xorg server, xinit, Openbox, KWin X11, the FORGE X-session entry, and XFCE-era shell utilities—is removed. XWayland is not a login or desktop backend.

## FORGE-owned layout

The session starts KWin directly and launches `plasmashell` only as a background service layer. `/usr/local/libexec/forge-plasma-initialize` removes Plasma's stock panel once, preventing a default Linux desktop layout from replacing FORGE.

Users can add an opt-in Plasma panel with:

```bash
forge-panel-manager top
forge-panel-manager bottom
forge-panel-manager left
forge-panel-manager right
```

Added panels are persistent and remain customizable through Plasma edit mode. FORGE continues to own the main application and workspace interface.

## Login and session identity

The login screen defaults to:

```bash
/usr/local/bin/forge-wayland-session
```

The live session contract includes:

- `XDG_SESSION_TYPE=wayland`
- `XDG_CURRENT_DESKTOP=FORGE`
- `XDG_SESSION_DESKTOP=FORGE`
- `WAYLAND_DISPLAY`
- `FORGE_OS_SESSION=1`
- `FORGE_SHELL_MODE=1`
- `FORGE_OS_VERSION`

Electron defaults to its native Wayland backend. `FORGE_USE_XWAYLAND=1` is an explicit compatibility escape hatch, not the production default.

## Integrated updates

Inside the FORGE-OS session, FORGE's **Check for updates** action opens `/usr/local/bin/forge-os-update` in Konsole. The helper pins the official FORGE and FORGE-OS origins, requires clean `main` checkouts, rejects divergence or untrusted remotes, performs fast-forward-only pulls, and invokes `scripts/install-forge-linux.sh`. It never discards local work or reboots automatically.

Standalone FORGE installations outside `FORGE_OS_SESSION=1` retain the normal Electron release updater.

## Validation status

Repository validation covers session defaults, removal of the X11 production stack, package declarations, installed-file identity, native Electron flags, Plasma background services, panel initialization, updater routing, trusted update origins, runtime hashes, and recovery configuration.

A stable release still requires the physical checks in [`docs/RELEASE_CHECKLIST.md`](../docs/RELEASE_CHECKLIST.md), including cold boot, real GPU behavior, portal and PipeWire operation, wallpaper and panel persistence, XWayland application compatibility, update installation, logout/relogin, compositor failure, tty2 recovery, and ISO testing.

## Documentation rule

Every FORGE-OS behavior change must update the changelog and all affected active documentation. Version increments follow the repository sequence; architecture work moved the project to `0.2.0-alpha`, and the integrated updater moved it to `0.2.1-alpha`.
