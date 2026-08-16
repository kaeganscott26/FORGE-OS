# 🌐 FORGE-OS Wayland Stack

## Implemented architecture

FORGE-OS `0.2.1-alpha` uses a canonical **FORGE-owned native Wayland session**:

```text
greetd / tuigreet
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland with XWayland compatibility
  -> Plasma visual, wallpaper, portal, and optional panel services
  -> native-Wayland FORGE
```

KWin is the compositor/window manager. Plasma operates underneath FORGE for decorations, animation, effects, wallpaper, portals, and user-created panels; FORGE remains the visible desktop environment.

The complete runtime/session matrix now lives in [`session/README.md`](../session/README.md).

## Session ownership rule

Exactly one top-level component should own the compositor/session lifecycle.

The direct production command:

```bash
/usr/local/bin/forge-wayland-session
```

is FORGE-owned and starts KWin itself.

The current reference machine has also used this F2 development override:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

That override is useful for testing a Plasma-hosted experience, but it is not yet a normalized production profile because `startplasma-wayland` and `forge-wayland-session` can both attempt to own KWin. A future Plasma-hosted launcher should start FORGE inside the already-running Plasma session without starting another compositor.

## Installed stack

The declared graphical stack includes:

- `wayland`, `kwin`, `plasma-desktop`, and `plasma-workspace`;
- `xorg-xwayland` only for applications that cannot run natively on Wayland;
- `xdg-desktop-portal` with KDE as the preferred backend and GTK fallback;
- `qt6-wayland` and `qt5-wayland` for native Qt clients;
- Breeze Dark, Breeze icons, Kvantum, and KDE GTK configuration;
- Dolphin, System Settings, KDialog, Konsole, and the KDE PolicyKit agent;
- PipeWire and WirePlumber for desktop audio and portal integration.

The retired production stack—Xorg server, xinit, Openbox, KWin X11, the FORGE X-session entry, and XFCE-era shell utilities—is historical. XWayland is not a login or desktop backend.

## FORGE-owned layout

The canonical session starts KWin directly and launches `plasmashell` only as a background service layer. `/usr/local/libexec/forge-plasma-initialize` removes Plasma's stock panel once, preventing a default Linux desktop layout from replacing FORGE.

Users can add an opt-in Plasma panel with:

```bash
forge-panel-manager top
forge-panel-manager bottom
forge-panel-manager left
forge-panel-manager right
```

Added panels are persistent and remain customizable through Plasma edit mode. FORGE continues to own the main application/workspace interface.

## Login and session identity

The repository login default is:

```bash
/usr/local/bin/forge-wayland-session
```

At `tuigreet`, **F2** can select a different complete command for development/recovery. Stable acceptance still requires the repository default to work without F2.

The native shell contract includes:

- `XDG_SESSION_TYPE=wayland`
- `XDG_CURRENT_DESKTOP=FORGE`
- `XDG_SESSION_DESKTOP=FORGE`
- `WAYLAND_DISPLAY`
- `FORGE_OS_SESSION=1`
- `FORGE_SHELL_MODE=1`
- `FORGE_OS_VERSION`

Electron defaults to its native Wayland backend. `FORGE_USE_XWAYLAND=1` is an explicit Electron rendering escape hatch, not a different compositor architecture.

## Runtime-aware UX work

Current development should preserve the distinction between:

- standalone FORGE on an ordinary host desktop;
- Plasma-hosted FORGE where Plasma owns desktop/session lifecycle;
- native FORGE-OS shell mode where FORGE owns the visible system UX.

An explicit runtime-profile capability contract is preferred over inferring every UI surface from generic Linux/KDE/Wayland environment state.

## Integrated updates

Inside the FORGE-OS shell contract, FORGE's **Check for updates** action opens `/usr/local/bin/forge-os-update` in Konsole. The helper pins the official FORGE and FORGE-OS origins, requires clean `main` checkouts, rejects divergence or untrusted remotes, performs fast-forward-only pulls, and invokes `scripts/install-forge-linux.sh`. It never discards local work or reboots automatically.

Standalone FORGE installations outside `FORGE_OS_SESSION=1` retain the normal Electron release updater.

## Validation status

Repository validation covers session defaults, removal of the old X11 production stack, package declarations, installed-file identity, native Electron flags, Plasma background services, panel initialization, updater routing, trusted update origins, runtime hashes, and recovery configuration.

A stable release still requires the physical checks in [`docs/RELEASE_CHECKLIST.md`](../docs/RELEASE_CHECKLIST.md), including cold boot, real GPU behavior, portal/PipeWire operation, wallpaper/panel persistence, application installation/discovery refresh, XWayland compatibility, update installation, logout/relogin, compositor failure, tty2 recovery, and ISO testing.

## Documentation rule

Every FORGE-OS behavior change must update the changelog and all affected active documentation. Obsolete runtime experiments/scripts should be removed or explicitly marked historical rather than left as current instructions.
