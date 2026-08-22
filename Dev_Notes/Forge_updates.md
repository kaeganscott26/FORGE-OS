# FORGE-OS implementation notes — 2026-08-21

This file is the concise source-status handoff. Active user instructions live in `README.md` and `docs/USER_MANUAL.md`; release acceptance lives in `BUILD_STATE.md` and `docs/RELEASE_CHECKLIST.md`. Old 0.2.2 session plans and duplicate release runbooks were removed because they contradicted the current `0.2.3-test.1` source.

## Confirmed implemented in source

- The installed login/session contract is `greetd -> forge-wayland-session -> KWin Wayland -> forge-wayland-client -> forge-session`, with the legacy `startplasma-wayland` dispatcher retained only for compatibility.
- The package/service manifests, Arch package frontends, mirror refresh, Fish/Starship configuration, native KDE system surfaces, Applications launcher, live setup, recovery, content-addressed runtime, checkpoint/rollback, and transactional updater exist and are covered by source contracts.
- The shared FORGE renderer exposes every FORGE and FORGE-OS button through a click or form-submit route. Eleven quick system surfaces and four session actions map to fixed installed `.desktop` launchers and fixed helper commands.
- New file/folder, rename, goals, metadata tasks, persistent tasks, release workflows, task pause, and conversation rename use routed in-app dialogs. New files are created through typed IPC and activate the editor.
- FORGE-OS starts FORGE with `$HOME` as the default workspace. The shared runtime also exposes a Home control on macOS, Windows, and Linux. Explorer loads folders on demand; bounded discovery skips protected/container-backed subtrees such as `.local/share/containers/storage/overlay`, so an `EACCES` subtree no longer breaks the whole home workspace.
- Ollama and other loopback providers receive every currently available FORGE tool-registry definition through the normal policy/approval/audit route. Stable aliases and invalid optional task-UUID reconciliation are implemented in FORGE source.
- `./install.sh` repairs/installs the current checkout. `./update.sh` validates both trusted repositories, preserves `.obsidian`, checkpoints FORGE-OS integration, fast-forwards, installs the pinned runtime, and restores source state after failure.

## Confirmed not implemented or not yet accepted

- Automatic filesystem-watch memory reindexing is not wired; **Reindex** remains a user action. The workspace watcher class exists but is not started by the desktop runtime.
- The current Explorer edits and manages workspace files but does not implement the older planned package/executable metadata inspector or user/administrator launch modes.
- Workspace Intelligence remains in the shared right-side panel; the previously claimed separate FORGE-OS top-bar popover does not exist.
- FORGE-OS contains optional copy hooks for packaged Ollama skill assets, but the sibling FORGE package currently supplies no `local-model-tooling/SKILL.md` resource. Tool access works through the live registry, not a packaged skill file.
- No `package-cross-platform.yml` workflow or `verify-runtime-parity.mjs` script exists in current FORGE source. Native Windows/Linux package acceptance and cross-platform parity evidence therefore remain release work.
- Clean disposable installation, ISO VM/physical boot, guided partition/format behavior, reference-hardware acceptance, signing, stable tags/releases, and remote checksum/update-feed verification remain incomplete. See `docs/IMPLEMENTATION_GAPS.md` and `docs/RELEASE_CHECKLIST.md`.

Garuda-inspired behavior uses reviewable Arch packages and a Dr460nized-inspired theme. Host package policy remains explicit; Kali/Ubuntu apt stay in rootless Distrobox environments and Nix remains isolated from pacman.
