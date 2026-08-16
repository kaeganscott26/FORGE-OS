# 📝 Changelog

All notable FORGE-OS changes are recorded here. Active documentation describes the current architecture; retired experiments remain discoverable through Git history.

## 🚧 Unreleased

### 🔴 Package bootstrap manifest blocker

- Repository audit found that [`scripts/bootstrap-arch.sh`](scripts/bootstrap-arch.sh) expects `manifests/arch-packages.txt`, but that file is absent from the current tree.
- The existing `manifests/arch-packages.sh` is not consumed by the bootstrap path and is not currently a valid substitute for the missing line-oriented manifest.
- Documented the impact in `README.md`, `BUILD_STATE.md`, `docs/USER_MANUAL.md`, `docs/IMPLEMENTATION_GAPS.md`, and `docs/RELEASE_CHECKLIST.md`.
- Marked clean fresh installation/package bootstrap as a release blocker until the package source of truth is restored or the bootstrap/ISO/test contract is intentionally changed together.
- Clarified that `--skip-packages` is only appropriate when all required dependencies are already installed.

### 🧱 Runtime/session architecture normalization and documentation audit

- Added [`session/README.md`](session/README.md) as the authoritative runtime/session architecture guide with session families, ownership rules, login commands, compatibility behavior, UI expectations, diagnostics, and links to related documentation.
- Formalized the invariant that **exactly one top-level component owns the graphical session/compositor**.
- Classified the canonical direct `/usr/local/bin/forge-wayland-session` path as **FORGE-owned** and conventional desktop profiles as **host-owned**.
- Documented the current reference-machine Plasma wrapper as a development override because `startplasma-wayland` and `forge-wayland-session` can both attempt KWin/session ownership.
- Defined the target for a future first-class Plasma-hosted profile: launch FORGE inside an already-owned Plasma session without creating a second compositor/session owner.
- Clarified that `FORGE_USE_XWAYLAND=1` changes Electron rendering only while KWin/session ownership remains native Wayland.
- Added explicit runtime-profile UI expectations for standalone FORGE, Plasma-hosted FORGE, and native FORGE-OS shell mode.
- Added runtime-profile capability modeling as an architecture direction so shell-only UI is not inferred solely from generic Linux/KDE/Wayland state.
- Refreshed `README.md`, `ARCHITECTURE.md`, `BUILD_STATE.md`, `CONTRIBUTING.md`, `docs/README.md`, `docs/DESKTOP_SESSION.md`, `docs/DECISIONS.md`, `docs/USER_MANUAL.md`, `docs/SHELL_MODE.md`, `docs/SECURITY_MODEL.md`, `docs/RECOVERY.md`, `docs/IMPLEMENTATION_GAPS.md`, `docs/RELEASE_CHECKLIST.md`, `Dev_Notes/Forge_updates.md`, `Dev_Notes/Wayland_Stack.md`, and `Dev_Notes/knownUxBugs.md` to the current `0.2.1-alpha` state.
- Recorded current UX gaps: external-window package installation, delayed FORGE application discovery after installs, runtime-profile UI ownership, Wayland/KDE theming/panel/settings polish, and external-window behavior.
- Added release gates for package bootstrap, application discovery refresh, portal/notification behavior, single-compositor ownership, and canonical login without F2.
- Removed superseded `Dev_Notes/install_wayland_stacks.sh`, stale crash-era `Dev_Notes/repo_status_update`, and empty `docs/md` placeholder.

### ⌨️ Login-screen runtime selection

- Documented the FORGE-branded greetd/tuigreet **F2** workflow for manually selecting a graphical session command before authentication.
- Current canonical selector: `/usr/local/bin/forge-wayland-session`.
- Current reference-machine Plasma development override: `/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session`.
- Historical X11 selector: `/usr/bin/xinit /usr/local/libexec/forge-session-client`.
- Clarified that session commands change how the same installed FORGE runtime is hosted; they are not separate FORGE application builds.
- Preserved `Ctrl+Alt+F2` as the independent recovery path.

### 🔄 Integrated FORGE-OS updates

- Prevented unavailable `power-profiles-daemon` hardware support or transient `powerprofilesctl` D-Bus failure from aborting an otherwise valid update.
- `forge-os-update` remains the visible normal-user update workflow for FORGE-OS shell mode.
- Update flow verifies trusted clean `main` repositories, rejects divergence, uses fast-forward-only pulls, invokes the authoritative installer, and never reboots automatically.

## `0.2.1-alpha` — Integrated updater and current shell iteration

- Added `/usr/local/bin/forge-os-update` and routed FORGE's **Check for updates** action to it inside `FORGE_OS_SESSION=1`.
- Added Konsole as the visible update-terminal host.
- Preserved standalone Electron updater behavior outside FORGE-OS shell mode.
- Continued native KWin Wayland shell development and repository/runtime identity verification.

## `0.2.0-alpha` — Native Wayland architecture

- Replaced the Xorg/xinit/KWin X11/Openbox production stack with a FORGE-owned KWin Wayland session.
- Changed greetd and the session desktop entry to default to `/usr/local/bin/forge-wayland-session`.
- Kept XWayland for legacy application compatibility and made Electron native Wayland the default.
- Started Plasma wallpaper, decoration, animation, portal, and panel services beneath FORGE without invoking conventional `startplasma-wayland` in the canonical path.
- Added one-time removal of Plasma's stock panel plus `forge-panel-manager` for opt-in persistent panels.
- Removed remaining XFCE-era shell dependencies from the current production model.

## `0.1.3-alpha` — Build identity hardening

- Refreshed the Linux-only `file.read` compatibility overlay.
- Recorded independent FORGE application/version/commit and FORGE-OS version/commit identities.
- Added lockfile, overlay, executable, `app.asar`, full-payload, and runtime hashes.
- Made `--use-current-build` reject runtimes produced by a different FORGE-OS revision/version.

## `0.1.2-alpha` — Plasma 6 / KWin X11 bridge

- Added Plasma 6/KWin X11, KRunner, System Settings, Breeze/Kvantum, Qt Wayland libraries, and KDE portal dependencies while the login chain remained X11/xinit.
- Used KWin X11 with an Openbox fallback.
- Added launcher, System Settings, workspace file runner, and PolicyKit-backed package installer surfaces.
- Added workspace-contained executable launch rules and strict package-name validation.

## `0.1.1-alpha` — X11 session regression protection

- Verified the historical `/usr/bin/xinit /usr/local/libexec/forge-session-client` post-authentication chain.
- Prevented greetd from bypassing the FORGE session client with a direct Openbox command.
- Preserved the X11/Openbox session as the then-production invariant before the later Wayland migration.

## 🧱 Existing hardening retained

- PAM-authenticated graphical login through greetd/tuigreet.
- `source_profile = false` for graphical startup.
- Normal-user FORGE execution; no root FORGE process.
- Content-addressed runtime installation under `/opt/forge`.
- Root-owned Electron `chrome-sandbox` mode `4755`.
- Zero-fuzz overlay application and explicit packaged source identity.
- Machine-generated user state kept outside Git.
- tty2 recovery preserved.
- Physical and ISO layouts intended to share the same runtime/session/recovery model.

## 🗄️ Retired experimental approaches

Acceptance-marker gating, tty1 profile autostart, manual `startx`, `.xinitrc`, direct Openbox production startup, and other experimental Xorg launch paths are historical only. Current `0.2.x` production documentation centers on the FORGE-owned KWin Wayland session and clearly labels alternate development profiles.
