# Current build state

Updated: 2026-08-16
Source version: `0.2.2` (stable candidate worktree; not yet published)

## Implemented

- Exact canonical login chain: `startplasma-wayland forge-wayland-session forge-wayland-client`.
- One FORGE-owned KWin Wayland compositor, XWayland compatibility, D-Bus import, KRunner daemon, Plasma service layer, persistent matrix login effect, and F2/F3/F4/F5 controls.
- Commit-tolerant, content-addressed runtime identity with commit retained only as provenance; immutable current/last-known-good releases and integrity-checked rollback.
- Authoritative, resolver-tested Arch package manifest; Fish/Starship theme; Wayland/gaming stack; reflector; Flatpak; rootless apt/Kali containers; Nix.
- `forge-app-install` and `forge-install-pkg` commands with familiar operations and native package paths.
- Native Applications and nine system-settings sections; live application rediscovery.
- Native FORGE Explorer inspection, copy/paste, create/rename/delete, executable/package handling, and explicit user/administrator launch boundary. FORGE Explorer is the configured file manager.
- Workspace Intelligence in the FORGE-OS top bar, automatic context/memory reindexing, chat-only right panel, audited release capability profile, and packaged/Ollama-local skill parity.
- Native recovery panel on every platform plus on-demand graphical tty2 recovery on FORGE-OS.
- Code-native splash, KWin translucency/focus/placement polish, deterministic build provenance, shared runtime hashes, and Linux/Windows/macOS package workflows.

## Verified in source

- FORGE typecheck and lint pass.
- 29 FORGE test files pass: 122 passed, 2 intentionally skipped.
- FORGE production build passes.
- FORGE-OS shell/TOML/desktop/unit/package-resolution/session-dispatcher gates pass.
- The authoritative package list resolves through pacman without a transaction.

## Still required before stable publication

- Build the new immutable FORGE runtime from the final clean commit.
- Build and inspect AppImage/DEB/ISO artifacts and checksums.
- Boot the ISO in a VM and physical/reference target; exercise GPU, network, audio, portals, external windows, package installation, logout/relogin, suspend/resume, tty2 recovery, rollback, and updater refusal/success paths.
- Produce Windows and macOS packages on native runners and compare version, commit, deterministic build date, and `sharedRuntimeSha256`.
- After the remaining artifact gates pass, commit the already synchronized release identities, push, annotate the tags, publish stable assets, and verify remote hashes/update feeds.

No unverified build in this worktree is labeled stable merely because source tests pass.
