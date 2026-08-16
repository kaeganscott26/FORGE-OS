# Architectural decisions

1. FORGE owns the visible workspace; Arch/KWin/Plasma/system services remain infrastructure.
2. The canonical public command string is `startplasma-wayland forge-wayland-session forge-wayland-client`, in that order, with unchanged installed command paths.
3. A narrow FORGE dispatcher interprets only that exact profile. Exactly one KWin process owns the session.
4. Plasma provides composition visuals, portals, wallpaper, and optional user panels beneath FORGE; the stock panel is removed once.
5. XWayland is application compatibility, not a production X11 login architecture.
6. Runtime versions are deliberate product/build numbers. Commits are provenance; content manifests and hashes decide whether a build can be reused or rolled back.
7. FORGE Explorer, Applications, System, Workspace Intelligence, and Recovery are native FORGE surfaces. Mature OS services remain typed backends.
8. Pacman stays the Arch authority and default path owner. Apt/Kali are container-isolated and Nix is store/profile-isolated.
9. Workspace files, `.forge` memory/tasks, and user configuration persist across runtime replacement. Cleanup targets only superseded immutable runtime directories.
10. Ctrl+Alt+F2 activates a separate graphical recovery environment on demand. Diagnostics are pre-authenticated; mutations are not.
11. Shared source/UI behavior is identical across Linux, Windows, and macOS; platform-only OS integration remains isolated. Deterministic metadata records a comparable shared runtime hash, while native executables retain platform-specific hashes.
12. Stable publication requires source gates, native packages, ISO boot/hardware acceptance, provenance, signing/channel policy, and remote hash verification. A green local build is insufficient.
