# 🧰 FORGE-OS Shell Mode

FORGE-OS exposes operating-system surfaces to FORGE only when the application is running inside a FORGE-OS shell contract.

The same FORGE runtime may also run as a standalone application or inside a host-owned Linux desktop. Those profiles should not expose the same OS-facing controls by default.

See [`session/README.md`](../session/README.md) for the runtime/session matrix.

## 🔐 Native shell contract

The canonical FORGE-owned Wayland session exports:

- `FORGE_OS_SESSION=1`
- `FORGE_SHELL_MODE=1`
- `XDG_CURRENT_DESKTOP=FORGE`
- `XDG_SESSION_DESKTOP=FORGE`
- `XDG_SESSION_TYPE=wayland`

FORGE reads that context in its Electron main process and exposes typed, allowlisted OS IPC only while shell mode is active. Normal macOS, Windows, and ordinary Linux application sessions do not expose FORGE-OS-only surfaces.

## ⚖️ Runtime-profile boundary

Environment flags remain the current implementation contract, but the architecture now distinguishes three UI classes:

- **Standalone FORGE:** host OS owns launchers, package UI, panels, settings, power, and session lifecycle.
- **Host-owned Linux desktop / Plasma-hosted FORGE:** host desktop owns compositor/session lifecycle; FORGE system surfaces are optional/delegated and must not duplicate host controls.
- **Native FORGE-OS shell:** FORGE owns the visible launcher/system/workspace UX while KWin/Plasma/system services remain infrastructure underneath.

A future explicit runtime-profile capability object should make these distinctions first-class rather than inferring them only from Linux/KDE/Wayland environment state.

## 🖥️ Current shell surfaces

The current native shell layer includes:

- locale-aware clock;
- XDG desktop-application discovery and launch;
- searchable Plasma application launcher and System Settings entries;
- FORGE panel manager for opt-in, persistent Plasma panels;
- workspace-constrained document opening and executable launching;
- authenticated Arch repository package installation;
- visible authenticated FORGE-OS update handoff;
- System Overview;
- fixed session actions.

Application launches resolve a discovered desktop ID in the main process, tokenize `Exec` without invoking a shell, discard desktop field codes, and never accept arbitrary renderer command strings.

## 📦 Current package/app UX limitation

The package-install backend intentionally validates package names and delegates `/usr/bin/pacman` privilege elevation to PolicyKit. The current user-facing flow still opens an external terminal/window, and newly installed applications may appear in KDE/Qt discovery before FORGE's Applications surface refreshes.

The planned consolidation is to keep pacman/PolicyKit as the backend while exposing install/search/remove/update through a FORGE-native surface and refreshing/watching XDG application directories after package transactions.

See [Implementation Gaps](IMPLEMENTATION_GAPS.md) and [`Dev_Notes/knownUxBugs.md`](../Dev_Notes/knownUxBugs.md).

## 🧭 Planned settings surface

Settings are staged by capability. System Overview and the source-based FORGE-OS update handoff are implemented; Network, Audio, Display, Power, Applications, Storage, Appearance, signed artifact updates, Security, Recovery, and Advanced remain architecture destinations as FORGE grows into the complete desktop UX.

Theme coordination uses system-wide Breeze Dark, Breeze icons, Kvantum, KWin blur/decoration defaults, and Plasma wallpaper services. FORGE stays foreground while user-created Plasma panels remain configurable and persistent.

Executable launch accepts one existing path, resolves it canonically beneath `FORGE_WORKSPACE`, and invokes it without a shell only when its executable bit is already set. Program installation validates Arch package names and does not accept arbitrary downloaded files or command strings.

When `FORGE_OS_SESSION=1`, **Check for updates** launches the fixed `forge-os-update` helper in Konsole. The helper verifies and fast-forwards trusted source checkouts before invoking the authoritative installer. Outside FORGE-OS shell mode, the existing standalone Electron updater behavior is unchanged.

## 🔗 Related documentation

- [Runtime & Session Architecture](../session/README.md)
- [Architecture](../ARCHITECTURE.md)
- [Security Model](SECURITY_MODEL.md)
- [Desktop Session](DESKTOP_SESSION.md)
- [Implementation Gaps](IMPLEMENTATION_GAPS.md)
