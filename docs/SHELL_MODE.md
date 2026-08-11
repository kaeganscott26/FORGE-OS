# FORGE-OS Shell Mode

The session exports `FORGE_OS_SESSION=1`, `FORGE_SHELL_MODE=1`, and the FORGE
desktop identity. FORGE reads that context in its Electron main process and
exposes typed, allowlisted OS IPC only when shell mode is active. Normal macOS,
Windows, and ordinary Linux app sessions do not show OS surfaces.

The first shell surface provides a locale-aware clock, XDG desktop-application
discovery and launch, System Overview, and fixed session actions. Desktop
launches resolve an ID from main-process discovery, tokenize `Exec` without a
shell, discard desktop field codes, and never accept renderer command strings.

Settings are staged by capability: Overview is implemented; Network, Audio,
Display, Power, Applications, Storage, Appearance, Updates, Security, Recovery,
and Advanced are visible architecture destinations. Theme coordination begins
with FORGE Dark, FORGE Light, and System/Custom; GTK, icon, cursor, terminal,
login, and wallpaper coordination remain future work.
