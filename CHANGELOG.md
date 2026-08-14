# 📝 Changelog

All notable FORGE-OS changes are recorded here. Active documentation describes only the current production architecture; retired experiments remain discoverable through Git history.

## 🚧 Unreleased

### 🧬 Linux build identity and overlay compatibility

- Bumped the development version to `0.1.3-alpha`.
- Refreshed the Linux-only `file.read` compatibility overlay for the current FORGE source layout while preserving zero-fuzz application.
- Recorded and verified the independent FORGE application version/manifest and FORGE-OS version/commit alongside lockfile, overlay, executable, `app.asar`, and full-payload hashes.
- Made `--use-current-build` reject runtimes produced by a different FORGE-OS revision or version.

### 🪟 Plasma 6 windowing and FORGE program surfaces

- Bumped the development version to `0.1.2-alpha`.
- Added Plasma 6 KWin X11, KRunner, System Settings, Breeze Dark, Kvantum, Qt Wayland, and KDE portal dependencies without changing the verified greetd/`xinit` login command.
- Made KWin the preferred session window manager with startup health detection and an automatic Openbox fallback.
- Added FORGE-discoverable launcher, System Settings, workspace file runner, and authenticated Arch package installer entries.
- Constrained file execution to canonical paths beneath the active FORGE workspace, required the executable bit, avoided shell evaluation, and logged detached program output under the user's FORGE state directory.
- Added PolicyKit-backed package installation with strict Arch package-name validation.
- Updated physical and ISO installers, verification coverage, architecture, security, shell-mode, user, and release documentation.

### 🔎 Session-default regression protection

- Bumped the development version to `0.1.1-alpha`.
- Confirmed that the repository contains no greetd default that launches `/usr/bin/openbox-session` directly.
- Added repository-level verification that greetd launches `/usr/bin/xinit /usr/local/libexec/forge-session-client` and cannot bypass the FORGE session client with a direct Openbox command.
- Classified the Wayland/Hyprland stack notes as future architecture research; the physically verified X11 path remains the production invariant until a separately validated migration is approved.

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
