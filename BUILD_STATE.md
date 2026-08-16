# Current build state

Updated: 2026-08-16
Source version: `0.2.2` (stable candidate worktree; not yet published)

## Implemented

- Normal greetd restored to the last-good pre-Matrix login behavior with direct authenticated handoff to `/usr/local/bin/forge-wayland-session`.
- One FORGE-owned KWin Wayland compositor, XWayland compatibility, D-Bus import, KRunner daemon, Plasma service layer, and the existing FORGE session/client runtime.
- Boot-critical normal, installed-recovery, and live-recovery greetd configurations validated against the Arch `greetd-tuigreet` binary installed from the authoritative package manifest.
- Commit-tolerant, content-addressed runtime identity with commit retained only as provenance; immutable current/last-known-good releases and integrity-checked rollback.
- Authoritative, resolver-tested Arch package manifest; Fish/Starship theme; Wayland/gaming stack; reflector; Flatpak; rootless apt/Kali containers; Nix; explicit sudo dependency for live recovery.
- `forge-app-install` and `forge-install-pkg` commands with familiar operations and native package paths.
- Native Applications and system-settings surfaces; live application rediscovery.
- Native FORGE Explorer inspection, copy/paste, create/rename/delete, executable/package handling, and explicit user/administrator launch boundary.
- Workspace Intelligence in the FORGE-OS top bar, automatic context/memory reindexing, chat-only right panel, audited release capability profile, and packaged/Ollama-local skill parity.
- Native installed-system recovery on demand through tty2 plus a separate ISO-only FORGE Live Recovery GUI.
- Live recovery media detects ArchISO before creating the ephemeral `forge` account, live-only passwordless sudo, live greetd profile, privileged root-shell launcher, or ISO/ZIP installer launcher.
- Live ISO/ZIP bundle loader stages ISO files read-only or ZIP files after path-traversal validation, recognizes explicit installer entry points, and requires literal `INSTALL` confirmation before execution.
- Canonical `./install.sh` and `./update.sh` entry points for normal system maintenance. `bootstrap-forgeos.sh`, `build-forge.sh`, and `install-runtime.sh` remain explicit stages executed by the installer rather than deleted duplicate entry points.
- Code-native splash, KWin translucency/focus/placement polish, deterministic build provenance, shared runtime hashes, and Linux/Windows/macOS package workflows.

## Verification status

- Source CI is required to pass FORGE typecheck, lint, tests, production build, greeter CLI validation, shell/TOML/desktop/unit checks, package resolution, session dispatcher tests, and the live recovery contract.
- Installed-machine verification checks exact repository-installed files, content-addressed runtime identity, greetd direct session path, absence of forced Matrix/background login behavior, service state, recovery autovt alias, and sandbox permissions.

## Still required before stable publication

- Complete the current source/CI run after the restored greeter and live recovery changes.
- Build the new immutable FORGE runtime from the final clean commit.
- Build and inspect AppImage/DEB/ISO artifacts and checksums.
- Boot the ISO in a VM and physical/reference target; exercise live recovery root shell, ISO/ZIP selection, a known installer bundle, GPU, network, audio, portals, external windows, package installation, logout/relogin, suspend/resume, tty2 recovery, rollback, and updater refusal/success paths.
- Produce Windows and macOS packages on native runners and compare version, commit, deterministic build date, and `sharedRuntimeSha256`.
- After the remaining artifact gates pass, commit the synchronized release identities, push, annotate tags, publish stable assets, and verify remote hashes/update feeds.

No unverified build in this worktree is labeled stable merely because source tests pass.
