# ✅ Current Build State

**Updated: 2026-08-15**

FORGE-OS `0.2.1-alpha` implements a native KWin Wayland shell with a separately documented Plasma-hosted development profile.

Canonical repository runtime command:

```bash
/usr/local/bin/forge-wayland-session
```

Current reference-machine F2 development override:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

The two commands are **not equivalent session ownership models**. The direct command is FORGE-owned and starts KWin itself. The Plasma wrapper is host-owned in intent and currently carries a duplicate-KWin/session-ownership risk because it hands off to a launcher that is also designed to start KWin. See [`session/README.md`](session/README.md).

## 🟢 Confirmed repository state

- System integration targets the FORGE-branded greetd/tuigreet login flow.
- PAM authentication is the production authentication boundary.
- The repository and desktop-entry defaults select the direct FORGE Wayland launcher.
- Xorg/xinit/Openbox/KWin X11 are historical rather than current `0.2.x` production dependencies.
- KWin Wayland starts Plasma visual/panel services beneath native-Wayland FORGE in the canonical profile.
- The stock Plasma panel is removed once; user-created panels remain persistent and customizable.
- `FORGE_USE_XWAYLAND=1` provides an Electron-rendering compatibility fallback without changing the Wayland compositor architecture.
- FORGE's **Check for updates** action hands FORGE-OS sessions to the authenticated, fast-forward-only OS update workflow.
- tty2 remains the independent recovery console.
- F2 login-screen selection provides a deliberate development/recovery mechanism for alternate session commands.

## 🔴 Current fresh-install blocker: package manifest mismatch

The authoritative installer calls [`scripts/bootstrap-arch.sh`](scripts/bootstrap-arch.sh) unless `--skip-packages` is supplied.

`bootstrap-arch.sh` currently expects:

```text
manifests/arch-packages.txt
```

but that file is not present in the current repository. The repository instead contains `manifests/arch-packages.sh`, which is **not** consumed by `bootstrap-arch.sh` and is not currently a valid replacement for the missing line-oriented package manifest.

Impact:

- a normal fresh install/update path that reaches package bootstrap is expected to fail before package installation;
- `--skip-packages` can only be used safely on a machine where all required dependencies are already installed;
- documentation must not claim a clean fresh install is fully validated until the authoritative package manifest is restored and the installer/verifier pass together.

This is tracked in [Implementation Gaps](docs/IMPLEMENTATION_GAPS.md). The session/runtime architecture can still be evaluated independently from this packaging defect, but it is a release blocker.

## 🧱 Canonical production chain

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

## 🧪 Active UX/runtime gaps

The OS architecture is functional, but current polish work remains:

- restore and validate the authoritative package manifest used by `bootstrap-arch.sh`;
- normalize a first-class **Plasma-hosted FORGE** profile so it launches FORGE inside an already-owned Plasma/KWin session instead of risking duplicate compositor ownership;
- make FORGE application discovery refresh immediately after package installation so newly installed `.desktop` applications appear in the FORGE Applications surface without relying on a separate KDE/Qt launcher;
- replace the current external-terminal package-install UX with an integrated FORGE-facing install flow while retaining PolicyKit/pacman as the privileged backend;
- consolidate runtime-profile capability detection so shell-only UI is explicitly enabled by profile rather than inferred from loose Wayland/KDE environment state;
- finish theme, panel, settings, notification, launcher, portal, and external-window behavior polish across the native shell profile.

These are tracked in [Implementation Gaps](docs/IMPLEMENTATION_GAPS.md) and [Known UX Bugs](Dev_Notes/knownUxBugs.md).

## 🧪 Validation still required before a stable ISO tag

The architecture and integrated updater are implemented and repository-testable, but physical KWin Wayland, GPU, wallpaper, panel, portal, Electron, update, logout, package bootstrap, and recovery acceptance is still required before a stable release.

Before publishing an ISO as stable:

- restore `manifests/arch-packages.txt` (or intentionally change the bootstrap contract) and prove a clean package bootstrap;
- cold boot after pulling and reinstalling the current repository state;
- confirm login requires no F2 command override for the canonical profile;
- confirm FORGE remains active after login;
- verify integrated-terminal XDG/D-Bus/FORGE environment variables;
- launch Chromium and Dolphin, plus an XWayland-only application;
- validate networking and audio;
- test logout → greeter → login;
- confirm tty2 recovery;
- test application installation followed by immediate FORGE launcher discovery;
- invoke **Check for updates**, confirm the authenticated updater refuses dirty/divergent checkouts, and validate a clean fast-forward installation;
- run `tests/verify.sh` with zero failures;
- build the ISO and verify its checksum;
- boot the ISO on the reference machine and at least one additional hardware/VM target.

Use the full [Release Checklist](docs/RELEASE_CHECKLIST.md) as the publication gate.

## 📚 Current documentation

- [README](README.md)
- [Runtime & Session Architecture](session/README.md)
- [Documentation Hub](docs/README.md)
- [Architecture](ARCHITECTURE.md)
- [Desktop Session](docs/DESKTOP_SESSION.md)
- [User Manual](docs/USER_MANUAL.md)
- [Shell Mode](docs/SHELL_MODE.md)
- [Implementation Gaps](docs/IMPLEMENTATION_GAPS.md)
- [Recovery](docs/RECOVERY.md)
- [Release Checklist](docs/RELEASE_CHECKLIST.md)

Historical startup approaches are preserved in Git history and the [Changelog](CHANGELOG.md), not presented as current production defaults.
