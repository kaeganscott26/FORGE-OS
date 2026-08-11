# Changelog

## Unreleased

- Audited the complete FORGE-OS boot, session, configuration, packaging, and documentation tree for path/architecture drift.
- Disabled greetd shell-profile sourcing so graphical startup no longer depends on `/etc/profile` or user profile files.
- Isolated tuigreet to FORGE-owned session directories and disabled its default X11 `startx` wrapper, leaving `forge-xsession` as the only X server startup boundary.
- Renamed the single authoritative physical-machine installer to `scripts/install-forge-linux.sh` and removed the old installer path.
- Made FORGE overlay identity independent of checkout paths and changed overlay application to zero-fuzz dry-run + apply.
- Explicitly inject the FORGE source commit/date during exported-source packaging so the build cannot inherit the surrounding FORGE-OS Git identity.
- Made runtime/session launch honor the recorded executable path and removed the requirement that `~/FORGE-OS` exist as the initial FORGE workspace.
- Moved user MIME backup state out of the Git repository and into the user's XDG state directory.
- Made graphical-login disablement return the machine to an actual tty1/tty2 console recovery state.
- Updated the ISO layout to use the same dedicated session paths, branded issue, display-manager alias, runtime record, graphical default, recovery getty, and core enabled services as the physical install.
- Expanded verification to cover greetd profile sourcing, tuigreet wrapper/session isolation, dedicated desktop entry placement, recorded executable paths, stale repository artifacts, and build-identity contracts.
- Removed stale Codex prompt/debug documents and tracked machine-generated artifacts.

## 2026-08-11 — graphical boot/runtime consolidation

- Replaced acceptance-gated and tty1/profile startup with greetd graphical login enabled by default.
- Added content-addressed runtime identity and byte-for-byte payload verification, including `app.asar`.
- Removed manual `startx`/`.xinitrc` production setup and split session installers.
- Corrected Electron sandbox installation, Xorg handoff, session logging, tty2 recovery, and strict production verification.
- Added FORGE-OS shell surfaces, application discovery/launch, system overview, desktop defaults, and ArchISO packaging work.

## Retired experimental approaches

Earlier development temporarily used acceptance-marker gating, tty1 shell/profile autostart, manual `startx`, and split graphical-session installers. Those approaches are historical only and are not supported by the current architecture.
