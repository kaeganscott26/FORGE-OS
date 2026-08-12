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
- System Overview;
- fixed session actions.

Application launches resolve a discovered desktop ID in the main process, tokenize `Exec` without invoking a shell, discard desktop field codes, and never accept arbitrary renderer command strings.

## 🧭 Planned settings surface

Settings are staged by capability. System Overview is implemented; Network, Audio, Display, Power, Applications, Storage, Appearance, Updates, Security, Recovery, and Advanced remain architecture destinations as FORGE grows into the complete desktop UX.

Theme coordination begins with FORGE Dark, FORGE Light, and System/Custom. GTK, icon, cursor, terminal, login, and wallpaper coordination remain future integration work.

## 📚 Related documentation

- [Architecture](../ARCHITECTURE.md)
- [Security Model](SECURITY_MODEL.md)
- [Desktop Session](DESKTOP_SESSION.md)
- [Implementation Gaps](IMPLEMENTATION_GAPS.md)
