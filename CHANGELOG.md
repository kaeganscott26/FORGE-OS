# Changelog

## Unreleased

### Workspace/UI and documentation correction

- Pinned FORGE `f3b7b87`, which removes runtime-only `reason`, `taskContext`, task-creation conversation identity, and task-process IDs from provider schemas, injects execution/audit identity internally, makes enabled bounded browser read/find automatic, and preserves explicit approval for navigation and high-impact tools. Action-log schema v8 retains optional task/step audit linkage.
- Pinned the sibling FORGE runtime containing routed in-app creation dialogs, Home workspace selection, full renderer-button route coverage, and permission-tolerant home traversal. Protected rootless-container overlay directories no longer abort Explorer or model file discovery.
- Preserved the existing typed workspace boundary: Home is the active root, not a global filesystem bypass.
- Corrected active documentation to distinguish implemented source from old planning claims. Automatic watch reindexing, package/executable Explorer inspection, a separate top-bar Intelligence popover, packaged Ollama skill assets, and cross-platform parity workflow/script remain explicit gaps.
- Removed the stale tracked `build/node22-bindir` temporary path and the obsolete duplicated 0.2.2 release/session runbooks.

### Login and maintenance hardening

- Fixed the greetd/tuigreet restart loop caused by an invalid boot-critical command line: removed unsupported `--battery` and `--custom-title` options, removed the mutually-exclusive `--greeting` from the production profile that already uses `--issue`, and quoted the semicolon-delimited theme as one argument.
- Preserved the persistent Matrix background and F4 background selector supported by the current Arch `greetd-tuigreet` package instead of treating the visual effect itself as the failure.
- Fixed the recovery greeter's own mutually-exclusive `--issue` + `--greeting` combination and quoted its theme argument.
- Added `tests/greeter-contract.sh` and CI coverage that install Arch `greetd-tuigreet`, parse both configured command lines, reject mutually-exclusive issue/greeting usage, and verify every configured long option against the packaged binary's `--help` contract.
- Changed graphical recovery from an always-enabled `graphical.target` service to the intended on-demand `autovt@tty2.service` alias, aligning physical installs with the ISO/session architecture and avoiding a second recovery greetd during every normal graphical boot.
- Added executable top-level `./install.sh` and `./update.sh` entry points. Normal users no longer need to choose among bootstrap/build/runtime helper scripts; the wrappers also remove the obsolete always-on recovery target link left by affected installs.

## 0.2.2 — 2026-08-16

### Runtime, login, and desktop

- Made `startplasma-wayland forge-wayland-session forge-wayland-client` the exact canonical greetd/F2/desktop command without changing the three installed command paths.
- Added the narrow FORGE `startplasma-wayland` dispatcher and isolated tests; non-FORGE calls retain vendor Plasma behavior.
- Enforced a one-KWin FORGE-owned Wayland process tree, imported D-Bus/systemd session state, and started KRunner/KDE/PolicyKit/Plasma services beneath FORGE.
- Added persistent Matrix login animation, F2 command, F3 sessions, F4 animation choices, F5 power, a code-native FORGE splash, and KWin focus/placement/blur/translucency/animation polish. The initial greeter command later required parser/CLI hardening recorded above.
- Made Fish the configured shell and added a Dr460nized-inspired Fish/Starship palette.

### Runtime identity, update, and recovery

- Replaced commit-equality reuse with deterministic runtime-source, package, lock, overlay, executable, `app.asar`, and payload manifests. Commits remain provenance; product version/build numbers remain deliberate.
- Kept immutable current/last-known-good releases, pruned superseded releases after activation, and added double-verified privileged rollback.
- Made clean-source updates transactional across FORGE and FORGE-OS: dirty, untrusted, and divergent histories fail closed, and an installer failure restores both pre-update commits.
- Preserved the last-known-good target on repeat activation and added isolated lifecycle coverage for corrupt-runtime replacement, rollback cleanup, and update after rollback.
- Added on-demand graphical Ctrl+Alt+F2 recovery with a separate greetd socket, D-Bus, KWin, full-screen native Recovery UI, application/session/recovery logs, and a user-owned diagnostic terminal.
- Preserved workspace files, XDG state, persistent memory, conversations, and tasks across update and rollback.

### Packages and compatibility

- Replaced the invalid shell manifest with authoritative `manifests/arch-packages.txt` and renamed bootstrap to `bootstrap-forgeos.sh`.
- Added Fish/Starship, full KWin/Plasma/Wayland services, reflector, Flatpak, Podman/Distrobox, Nix, gamescope, GameMode, MangoHud, Wine staging, Winetricks, GOverlay, firmware, and Btrfs/Snapper dependencies.
- Added `forge-app-install` and `forge-install-pkg` with familiar `-S`, `-Syu`, query/search/info/remove/local-package operations, normal pacman paths, and XDG application-cache refresh.
- Isolated Ubuntu/apt and Kali in rootless containers and Nix in its own store/profile; no Debian/Kali repository is mixed into Arch.
- Added explicit ranked/tracked mirror refresh and `install-wayland-stacks.sh` core/plasma/gaming/full profiles.

### Native FORGE UX and agent tooling

- Added native Applications and Network, Audio, Display, Power, Applications, Updates, Security, Recovery, and Advanced system surfaces with fixed main-process actions.
- Made FORGE Explorer the default file manager and added workspace-contained create/copy/paste/rename/delete, metadata/binary/package/executable inspection, and explicit user/administrator launch modes.
- Moved Workspace Intelligence to the FORGE-OS top bar as a separate native popover, resized chat to the right rail, and added automatic open/watch context and memory indexing without an LLM prompt.
- Added a visible full-permissions/full-filesystem-requestable Release Workflow profile while preserving exact-scope approval and fresh approval for destructive/remote writes.
- Added the packaged Ollama/Vulkan runtime, a standard `local-model-tooling/SKILL.md`, full availability-filtered tool parity with hosted models, OpenAI-compatible object-argument handling, and recovery from fabricated optional task UUIDs.
- Added packaged and Ollama-local skill parity for workspace intelligence, Explorer, tools, release, recovery, package management, terminal, and web research.

### Cross-platform and documentation

- Added deterministic build dates, schema-v2 runtime metadata, shared runtime hashes, runtime parity verification, Linux/Windows CI packaging, and metadata/native PTY gates alongside macOS packaging.
- Added cross-platform native Recovery UI and shared splash/runtime behavior while isolating Linux-only system actions.
- Removed obsolete bootstrap/Wayland note scripts, stale mirror implementation notes, resolved UX-bug notes, the temporary handoff, and redundant desktop/Wayland documentation.
- Rewrote active architecture, session, user, security, recovery, build-state, implementation-gap, decision, and release documents to match the implementation.

## 0.2.1-alpha

- Added the trusted clean-source FORGE-OS updater and routed shell-mode update controls through it.
- Preserved the standalone Electron updater outside FORGE-OS shell mode.
- Continued content-addressed runtime and KWin Wayland integration.

## 0.2.0-alpha

- Replaced the Xorg/Openbox production architecture with a FORGE-owned KWin Wayland session and XWayland application compatibility.
- Added Plasma visuals/services beneath FORGE, one-time stock-panel removal, and optional persistent panels.

## 0.1.3-alpha

- Added explicit FORGE/FORGE-OS provenance plus lockfile, overlay, executable, application archive, and payload hashes.

## 0.1.2-alpha

- Introduced the historical Plasma 6/KWin X11 bridge and early launcher/settings/package surfaces.

## 0.1.1-alpha

- Protected the historical X11/Openbox session chain. Those profiles are no longer installed production paths.
# 0.2.4 — Coordinated semantic-context release

- Bundles FORGE 2.4.0-beta with native semantic indexing, governed context packets, and offline lexical fallback.
- Adds guarded generated-build cleanup and a tag-gated fresh ISO workflow with SHA-256 provenance.
