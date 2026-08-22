# Architectural decisions

1. FORGE owns the visible workspace; Arch/KWin/Plasma/system services remain infrastructure.
2. The canonical installed login command is `/usr/local/bin/forge-wayland-session`; the historical `startplasma-wayland forge-wayland-session forge-wayland-client` dispatcher remains compatibility code, not the greetd/F2/F3 entry point.
3. Exactly one KWin process owns the FORGE session.
4. Plasma provides composition visuals, portals, wallpaper, and optional user panels beneath FORGE; the stock panel is removed once.
5. XWayland is application compatibility, not a production X11 login architecture.
6. Runtime versions are deliberate product/build numbers. Commits are provenance; content manifests and hashes decide whether a build can be reused or rolled back.
7. FORGE owns Explorer, Applications, System routing, Workspace Intelligence, and Recovery surfaces. Explorer's current shipped scope is workspace-contained text/file management; planned package/executable inspection remains a gap. Mature OS services remain typed backends.
8. Pacman stays the Arch authority and default path owner. Apt/Kali are container-isolated and Nix is store/profile-isolated.
9. Workspace files, `.forge` memory/tasks, and user configuration persist across runtime replacement. Cleanup targets only superseded immutable runtime directories.
10. Ctrl+Alt+F2 activates a separate graphical recovery environment on demand. Diagnostics are pre-authenticated; mutations are not.
11. Shared source/UI behavior is intended to match Linux, Windows, and macOS while platform-only OS integration remains isolated. Native-runner parity evidence is required before claiming identical packaged behavior.
12. Stable publication requires source gates, native packages, ISO boot/hardware acceptance, provenance, signing/channel policy, and remote hash verification. A green local build is insufficient.
