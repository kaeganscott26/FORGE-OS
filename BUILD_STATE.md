# Current build state

Updated: 2026-08-16
Source version: `0.2.2` (stable candidate worktree; not yet published)

## Implemented

- Normal greetd authenticates directly into `/usr/local/bin/forge-wayland-session`; F2 and the visible F3 FORGE entry use the same path and stale remembered-session state is cleared during installation.
- Matrix is the default login background and F4 opens the maintained tuigreet background selector, including the DOOM fire effect.
- FORGE-OS tracks the maintained rolling NotAShelf tuigreet source while that background API is ahead of the current tagged binary release; Rust is part of the official build/install manifest.
- One FORGE-owned KWin Wayland compositor with XWayland compatibility, D-Bus/KRunner/PolicyKit/Plasma service integration, and content-addressed FORGE runtime selection.
- The FORGE-OS top bar now reserves its own screen space rather than covering the ordinary FORGE header. Applications/System remain primary controls; Network, Audio, Display, Power, Applications, Storage, Appearance, Updates, Security, Recovery, and Advanced are launchable responsive quick actions.
- Session Lock/Logout/Restart/Shutdown use detached OS helpers so terminating FORGE or the login session cannot break the action's own synchronous IPC response.
- Official Arch manifest includes the complete Wayland/KDE/system surface stack plus Rust, Reflector, package tooling, recovery dependencies, and service dependencies.
- Bootstrap enables multilib, tracked HTTPS mirrors, Reflector ranking, Chaotic-AUR, `yay`, and the rolling maintained tuigreet fork.
- Interactive Fish `pacman` routes through `forge-install-pkg`; GUI installation routes `forge-install-program -> forge-app-install -> forge-install-pkg`; installer internals use absolute `/usr/bin/pacman` to avoid recursion.
- NetworkManager, Bluetooth, irqbalance, time sync, CUPS, Ollama, trim, Reflector, and supported power/firmware maintenance services/timers are persistently enabled. PipeWire/PipeWire Pulse/WirePlumber are globally enabled for user sessions.
- Native installed-system recovery remains on-demand through tty2.
- ISO-only FORGE Live Recovery uses the same Wayland runtime with live flags, a locked ephemeral account, live-only passwordless sudo, root-shell launcher, and guarded ISO/ZIP installer workflow.
- `bootstrap-forgeos.sh`, `build-forge.sh`, `install-runtime.sh`, hardware configuration, and user configuration remain explicit installer stages rather than being deleted as duplicate scripts.
- Deterministic runtime provenance, executable/app.asar/payload hashes, chrome-sandbox permissions, rollback, cross-platform FORGE packaging, and ISO executable-mode verification remain intact.

## Verification status

- GitHub source CI now builds the rolling maintained tuigreet source directly and verifies its Matrix/F4/DOOM CLI before running the FORGE-OS source contract.
- The complete source contract must pass shell/TOML/desktop/unit checks, official package resolution, greeter CLI validation, top-bar/session/package/service assertions, FORGE typecheck, lint, tests, and production build.
- Installed-machine verification checks package/repository state, mirrors, rolling greeter package, runtime identity/hashes, exact installed files, F2/F3 paths, Matrix/F4 behavior, service/timer enablement, recovery alias, and Electron sandbox permissions.

## Still required before stable publication

- Get the current GitHub source-contract run fully green after the rolling greeter transition.
- Pull both repositories on the Arch target and run the authoritative installer against the final clean commits.
- Verify the top-bar geometry at the target display scale, all eleven system-surface launchers, and all four Session actions on the real machine.
- Reboot and confirm greetd, Matrix/F4, direct Wayland handoff, NetworkManager/audio/Bluetooth/Ollama, Reflector, recovery, and package wrapper behavior persist.
- Build the new immutable FORGE runtime and FORGE-OS ISO; test the ISO in a VM and on reference hardware, including Live Recovery root shell and ISO/ZIP installation.
- Complete remaining Linux artifact, Windows, and macOS parity/release gates before publishing stable tags/assets.

No unverified build is labeled stable merely because its source changes are committed.
