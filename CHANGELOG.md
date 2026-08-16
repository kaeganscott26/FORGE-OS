# 📝 Changelog

All notable FORGE-OS changes are recorded here. Active documentation describes only the current production architecture; retired experiments remain discoverable through Git history.

## 🚧 Unreleased

- Prevented unavailable `power-profiles-daemon` hardware support or a transient `powerprofilesctl` DBus failure from aborting an otherwise valid FORGE-OS update.

### 🧭 Runtime/session configuration map

- Added a front-page runtime matrix to `README.md` so the supported FORGE presentation modes and their FORGE-OS session generations are visible without digging through historical notes.
- Documented the standalone FORGE application runtime as distinct from FORGE-OS shell mode: macOS, Windows, and ordinary Linux desktop sessions do not expose `FORGE_OS_SESSION` / `FORGE_SHELL_MODE` OS surfaces.
- Recorded the `0.1.1-alpha` X11/Openbox session line as historical: greetd authenticated into `/usr/bin/xinit /usr/local/libexec/forge-session-client` with Openbox as the lightweight window-management substrate.
- Recorded the `0.1.2-alpha`–`0.1.3-alpha` Plasma 6 / KWin X11 bridge as historical: Plasma/KWin supplied richer desktop services while the verified X11/xinit chain and Openbox fallback remained in place.
- Recorded `0.2.0-alpha` onward as the native KWin Wayland FORGE shell generation; current `0.2.1-alpha` uses greetd → `forge-wayland-session` → KWin Wayland → Plasma services → `forge-session` → the content-addressed FORGE runtime.
- Documented `FORGE_USE_XWAYLAND=1` as the current `0.2.x` compatibility option for launching the packaged Electron FORGE window through XWayland while retaining the native KWin Wayland FORGE-OS session.
- Clarified that `forge-panel-manager [edge]` changes the visible Plasma panel configuration without creating a different session generation; the initial `0.2.x` shell remains panel-free unless the user opts into a Plasma panel.

### 🔄 Integrated FORGE-OS updates

- Bumped the development version to `0.2.1-alpha`.
- Added `/usr/local/bin/forge-os-update`, a visible normal-user update workflow that verifies clean `main` checkouts, rejects divergence, fast-forwards the trusted FORGE and FORGE-OS origins, and invokes the authoritative installer.
- Added a zero-fuzz FORGE overlay so **Check for updates** launches the authenticated OS updater inside `FORGE_OS_SESSION=1`; standalone FORGE builds retain Electron Updater behavior.
- Added Konsole as the fixed update-terminal host and included the updater in physical and ISO installations and verification.
- Updated architecture, build-state, contribution, decision, user, recovery, security, shell-mode, release, implementation-gap, and Dev Notes documentation for the new update contract.

### 🌐 Native Wayland session architecture

- Bumped the development version to `0.2.0-alpha` for the session-stack architecture change.
- Replaced the Xorg/xinit/KWin X11/Openbox production stack with a FORGE-owned KWin Wayland session.
- Changed greetd and the session desktop entry to default to `/usr/local/bin/forge-wayland-session`.
- Kept XWayland solely for compatibility with legacy applications and made Electron use native Wayland by default.
- Started Plasma wallpaper, decoration, animation, portal, and panel services underneath FORGE without invoking the conventional `startplasma-wayland` desktop.
- Added one-time removal of Plasma's stock panel plus `forge-panel-manager` for opt-in, persistent, customizable panels.
- Removed the remaining XFCE-era Thunar, notification, clipboard, and PolicyKit shell packages; Dolphin and the KDE PolicyKit agent now own those desktop roles.
- Updated package manifests, installers, ISO construction, verification, recovery, architecture, user, security, and release documentation.

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
