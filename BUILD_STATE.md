# ✅ Current Build State

**Updated: 2026-08-14**

FORGE-OS now implements a native KWin Wayland login path. The runtime command is:

```bash
/usr/local/bin/forge-wayland-session
```

## 🟢 Confirmed working

- System boots into the FORGE-branded greetd/tuigreet login flow.
- PAM authentication succeeds.
- The repository and desktop-entry defaults select the FORGE Wayland launcher.
- Xorg, xinit, Openbox, KWin X11, and the FORGE X-session entry are removed.
- KWin Wayland starts Plasma visual/panel services beneath native-Wayland FORGE.
- The stock Plasma panel is removed once; user-created panels remain persistent and customizable.
- The desktop entry and verifier are aligned with the same runtime command.
- FORGE's **Check for updates** action hands FORGE-OS sessions to the authenticated, fast-forward-only OS update workflow.
- tty2 remains the independent recovery console.

## 🧱 Production chain

```text
systemd graphical.target
  -> greetd on VT1
  -> FORGE-branded tuigreet
  -> PAM authentication
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland + Plasma visual/panel services
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded FORGE executable>
```

## 🧪 Validation still required before a stable ISO tag

The repository version is `0.2.1-alpha`. The architecture and integrated updater are implemented and repository-testable, but physical KWin Wayland, GPU, wallpaper, panel, portal, Electron, update, logout, and recovery acceptance is still required before a stable release.

Before publishing an ISO as stable:

- cold boot after pulling and reinstalling the current repository state;
- confirm login requires no F2 command override;
- confirm FORGE remains active after login;
- verify integrated-terminal XDG/D-Bus/FORGE environment variables;
- launch Chromium and Dolphin, plus an XWayland-only application;
- validate networking and audio;
- test logout → greeter → login;
- confirm tty2 recovery;
- invoke **Check for updates**, confirm the authenticated updater refuses dirty/divergent checkouts, and validate a clean fast-forward installation;
- run `tests/verify.sh` with zero failures;
- build the ISO and verify its checksum;
- boot the ISO on the reference machine and at least one additional hardware/VM target.

Use the full [Release Checklist](docs/RELEASE_CHECKLIST.md) as the publication gate.

## 📚 Current documentation

- [README](README.md)
- [Documentation Hub](docs/README.md)
- [Architecture](ARCHITECTURE.md)
- [Desktop Session](docs/DESKTOP_SESSION.md)
- [User Manual](docs/USER_MANUAL.md)
- [Recovery](docs/RECOVERY.md)
- [Release Checklist](docs/RELEASE_CHECKLIST.md)

Historical experimental startup approaches are not part of the current production documentation. Git history and the [Changelog](CHANGELOG.md) preserve that development record.
