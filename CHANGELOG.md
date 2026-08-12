# 📝 Changelog

All notable FORGE-OS changes are recorded here. Active documentation describes only the current production architecture; retired experiments remain discoverable through Git history.

## 🚧 Unreleased

### 🖥️ Stable runtime/session path

- Verified that successful PAM authentication can launch the FORGE desktop with `/usr/bin/xinit /usr/local/libexec/forge-session-client`.
- Changed greetd/tuigreet's default command to use that verified runtime path directly.
- Aligned `session/forge-xsession` and `session/forge.desktop` with the same command.
- Updated production verification to assert the verified runtime path instead of the previous custom display/Xorg-launch policy.

### 📚 Repository polish

- Added a central documentation hub and repository map.
- Reworked README navigation for users, developers, recovery, architecture, and release workflows.
- Updated architecture, desktop-session, user, recovery, security, decisions, current-state, and release documentation to match the production runtime.
- Converted the ISO release guide into an explicit stable-release gate.
- Removed stale debug-era architecture language from active docs and clarified that historical experiments belong in Git history.
- Kept unresolved work isolated in `docs/IMPLEMENTATION_GAPS.md` instead of mixing it into user-facing guides.

### 🧱 Existing production hardening

- Disabled greetd shell-profile sourcing so graphical startup no longer depends on `/etc/profile` or user profile files.
- Isolated tuigreet to FORGE-owned session directories and disabled its default X11 `startx` wrapper.
- Standardized the authoritative physical-machine installer as `scripts/install-forge-linux.sh`.
- Made FORGE overlay identity independent of checkout paths and changed overlay application to zero-fuzz dry-run + apply.
- Explicitly inject FORGE source identity during exported-source packaging.
- Made runtime/session launch honor recorded executable identity and removed dependency on a `~/FORGE-OS` checkout for normal graphical startup.
- Moved user MIME backup state out of Git and into the user's XDG state directory.
- Preserved tty2 as an independent recovery path.
- Aligned ISO layout with the same runtime/session/recovery model as the physical install.

## 🗓️ 2026-08-11 — Graphical boot/runtime consolidation

- Replaced acceptance-gated and tty1/profile startup with greetd graphical login enabled by default.
- Added content-addressed runtime identity and byte-for-byte payload verification, including `app.asar`.
- Removed manual `startx`/`.xinitrc` production setup and split session installers.
- Corrected Electron sandbox installation, Xorg handoff, session logging, tty2 recovery, and strict production verification.
- Added FORGE-OS shell surfaces, application discovery/launch, system overview, desktop defaults, and ArchISO packaging work.

## 🗄️ Retired experimental approaches

Earlier development temporarily used acceptance-marker gating, tty1 shell/profile autostart, manual `startx`, `.xinitrc`, and multiple experimental Xorg-launch paths. Those approaches are historical only and are not supported by the current architecture.
