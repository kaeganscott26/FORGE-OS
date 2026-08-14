# 🧰 FORGE-OS Shell Mode

FORGE-OS exposes operating-system surfaces to FORGE only when the application is running inside the FORGE-OS session contract.

## 🔐 Session contract

The graphical session exports:

- `FORGE_OS_SESSION=1`
- `FORGE_SHELL_MODE=1`
- the FORGE XDG desktop identity

FORGE reads that context in its Electron main process and exposes typed, allowlisted OS IPC only while shell mode is active. Normal macOS, Windows, and ordinary Linux application sessions do not expose FORGE-OS-only surfaces.

## 🖥️ Current shell surfaces

The initial shell layer includes:

- locale-aware clock;
- XDG desktop-application discovery and launch;
- searchable Plasma application launcher and System Settings entries;
- a FORGE panel manager for opt-in, persistent Plasma panels;
- workspace-constrained document opening and executable launching;
- authenticated Arch repository package installation;
- a visible, authenticated FORGE-OS update handoff;
- System Overview;
- fixed session actions.

Application launches resolve a discovered desktop ID in the main process, tokenize `Exec` without invoking a shell, discard desktop field codes, and never accept arbitrary renderer command strings.

## 🧭 Planned settings surface

Settings are staged by capability. System Overview and the source-based FORGE-OS update handoff are implemented; Network, Audio, Display, Power, Applications, Storage, Appearance, a signed artifact update channel, Security, Recovery, and Advanced remain architecture destinations as FORGE grows into the complete desktop UX.

Theme coordination uses system-wide Breeze Dark, Breeze icons, Kvantum, KWin blur/decoration defaults, and Plasma wallpaper services. FORGE stays foreground while user-created Plasma panels remain configurable and persistent.

Executable launch accepts one existing path, resolves it canonically beneath `FORGE_WORKSPACE`, and invokes it without a shell only when its executable bit is already set. Program installation validates Arch package names and delegates `/usr/bin/pacman` privilege elevation to PolicyKit; it does not accept command strings or install arbitrary downloaded files.

When `FORGE_OS_SESSION=1`, **Check for updates** launches the fixed `forge-os-update` helper in Konsole. The helper verifies and fast-forwards the trusted source checkouts before invoking the authoritative installer. Outside FORGE-OS, the existing standalone Electron updater behavior is unchanged.

## 📚 Related documentation

- [Architecture](../ARCHITECTURE.md)
- [Security Model](SECURITY_MODEL.md)
- [Desktop Session](DESKTOP_SESSION.md)
- [Implementation Gaps](IMPLEMENTATION_GAPS.md)
