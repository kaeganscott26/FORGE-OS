# Current build state

Updated: 2026-08-16
Source version: `0.2.3-test.1` (test ISO candidate; not stable)
Pinned FORGE source: `a893810bb3df42059ee48f517b2723a4a4c29ab1`

## Implemented

- Canonical installed login path: `greetd -> /usr/local/bin/tuigreet -> /usr/local/bin/forge-wayland-session`.
- F2/default and visible F3 FORGE entry use the same Wayland path; stale remembered-session state cannot override it.
- Canonical `tuigreet/tuigreet` 0.11.0 is pinned to commit `6fb15fffb794c6bd357164347d8b6d9e0aa92bbc` and built with its lockfile. Matrix is default; F4 exposes the background selector including DOOM fire.
- One KWin Wayland compositor with XWayland compatibility, D-Bus/KRunner/PolicyKit/Plasma service integration, and the content-addressed FORGE runtime.
- Responsive FORGE-OS top bar with Applications/System plus Network, Audio, Display, Power, Applications, Storage, Appearance, Updates, Security, Recovery, and Advanced without covering the normal FORGE header.
- Session Lock/Logout/Restart/Shutdown use detached OS helpers; restart/shutdown use non-blocking systemd power actions.
- Native KDE/KCM/KDialog surfaces use the FORGE dark/green system palette and run as normal windows under KWin Wayland.
- Advanced Maintenance Center provides service controls, authenticated root shell, verification, current-build repair, update/reinstall, full pre-update system rollback, runtime-only rollback, and console recovery.
- Runtime rollback is reversible and never deletes the runtime being left.
- Updates create a root-owned `/var/lib/forge-os/checkpoints/previous` checkpoint with FORGE/FORGE-OS source provenance, active runtime identity, file SHA-256 manifest, and symlink manifest. Full rollback verifies that checkpoint before restoring FORGE-owned greetd/session/service/theme/helper integration plus the checkpoint runtime.
- Normal install/update retain bootstrap, hardware/service configuration, FORGE build, runtime install, and user desktop configuration as explicit installer stages behind `./install.sh` and `./update.sh`.
- Interactive Fish pacman mutations route through `forge-install-pkg`; GUI installs route `forge-install-program -> forge-app-install -> forge-install-pkg`; installer bootstrap uses absolute `/usr/bin/pacman`.
- Official Arch + multilib, tracked HTTPS mirror baseline, Reflector, Chaotic-AUR, and `yay` are configured by the install path.
- Authoritative service policy is stored in `manifests/system-services.tsv`; required system/timer/global-user units are persistently enabled.
- Installed graphical recovery remains on-demand through tty2; console recovery remains independent of the graphical stack.
- Live ISO enters the same KWin/FORGE Wayland stack with a locked ephemeral `forge` account and live-only passwordless sudo.
- FORGE-OS Setup automatically opens once per live boot as themed KDE/Qt windows inside the KWin session.
- Guided Setup provides KDE Partition Manager, Network settings, root recovery shell, ISO/ZIP bundle loading, target/user/hostname/timezone selection, and checkbox-driven optional services.
- Clean install is mount-targeted and never partitions/formats disks. It uses pacstrap, UUID fstab, the exact ISO FORGE runtime, the canonical greetd/Wayland path, systemd-boot on UEFI, Advanced/recovery helpers, and a first-boot required-service verifier.
- The installed target never inherits the live passwordless-sudo policy.
- FORGE source used for the ISO is pinned through `FORGE_REF`, preventing a moving FORGE `main` from changing the image after source verification.

## Verification gates

The GitHub source contract must pass, on the same pinned FORGE source used for the image:

- canonical tuigreet 0.11.0 build/version/Matrix/F4/DOOM checks;
- greeter config contract;
- Guided Setup/clean-install contract;
- Advanced/admin/checkpoint/rollback contract;
- shell syntax, TOML, desktop-entry and systemd-unit checks;
- official package resolution and service policy checks;
- FORGE typecheck, lint, tests, and production build;
- runtime-source and repository diff checks.

The ISO workflow must then build the immutable FORGE Linux runtime, construct ArchISO in a privileged Linux build environment, verify critical executable modes and hashes inside the SquashFS, and publish exactly one versioned x86_64 ISO as a GitHub **prerelease/test build** with SHA-256 checksum.

## Hardware acceptance still required

`0.2.3-test.1` is deliberately not stable. After the CI-built ISO exists it still needs real boot/install testing for:

- UEFI USB boot and automatic Guided Setup launch;
- disk partition/mount workflow and clean installation;
- installed first boot through greetd/Matrix into `/usr/local/bin/forge-wayland-session`;
- KWin/Plasma/FORGE geometry, scaling, native settings theming, and external application windows;
- NetworkManager, PipeWire/WirePlumber, Bluetooth, Ollama, firewall, mirrors and package routing;
- all top-bar surfaces and Session actions;
- tty2 graphical recovery and independent text-console recovery;
- update checkpoint creation, full system rollback, reversible runtime rollback, and repair/update paths;
- suspend/resume and hardware-specific GPU/audio/input behavior.

No source-green or ISO-built artifact is called stable until those physical/runtime acceptance gates pass.
