# FORGE-OS implementation notes — 2026-08-16

The authoritative runtime is now the exact `startplasma-wayland forge-wayland-session forge-wayland-client` chain implemented by the FORGE-owned dispatcher. The package manifest, familiar FORGE package commands, explicit mirror refresh, Fish/Starship theme, native settings/Explorer/Applications/Workspace Intelligence, automatic indexing, graphical recovery, content-addressed rollback, splash/theming, Ollama skill parity, and cross-platform package metadata are implemented in source.

Garuda-inspired behavior uses reviewable Arch packages and a Dr460nized-inspired theme; the OS does not silently trust or mix a Garuda/Chaotic repository. Kali and Ubuntu apt remain rootless Distrobox environments, and Nix remains isolated from pacman.

The remaining work is release evidence: clean disposable installation, immutable runtime/package production from the final commit, ISO build and boot, physical/VM acceptance, native Windows/macOS artifacts, signing/channel provenance, and remote checksum/update-feed verification. See `BUILD_STATE.md` and `docs/RELEASE_CHECKLIST.md`.
