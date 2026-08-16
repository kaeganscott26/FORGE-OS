# FORGE-OS

FORGE-OS is the Arch-based integration layer that makes FORGE the visible workspace, desktop, Explorer, settings, recovery, and update experience. Arch, systemd, KWin, Plasma services, NetworkManager, PipeWire, PolicyKit, pacman, and the native package databases remain the operating-system substrate; they do not become the primary UI.

Current stable candidate: `0.2.2`. Publication remains gated by [release acceptance](docs/RELEASE_CHECKLIST.md).

## Login contract

Normal boot is intentionally simple and deterministic:

```text
greetd on tty1
  -> /usr/local/bin/tuigreet
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland + XWayland compatibility
  -> /usr/local/libexec/forge-wayland-client
  -> D-Bus, KRunner, KDE services, PolicyKit, Plasma visuals
  -> /usr/local/bin/forge-session
  -> content-addressed FORGE runtime
```

F2 defaults to `/usr/local/bin/forge-wayland-session`, and the visible F3 FORGE session entry points to that same installed path. Old X11/session-client paths are removed from the installed production profile, while the historical `startplasma-wayland` dispatcher remains only as compatibility implementation.

The login UI uses the actively maintained NotAShelf tuigreet rolling fork because its current development line contains the background API required by FORGE-OS. Matrix is the default background; F4 opens the live background selector, including the classic DOOM fire effect. The installer deliberately does not enable session remembering, so an experimental old command cannot silently replace the canonical F2 path. `tests/greeter-contract.sh` validates every configured greeter option against the actual installed binary before greetd is enabled.

## Install and update

Normal maintenance keeps two repository entry points:

```bash
cd ~/FORGE-OS
./install.sh
```

and:

```bash
cd ~/FORGE-OS
./update.sh
```

The bootstrap/build/runtime scripts are intentionally retained because `scripts/install-forge-linux.sh` executes them as explicit stages. A normal install provisions official Arch packages, multilib, the reviewed mirror baseline, Reflector, Chaotic-AUR, `yay`, the rolling maintained tuigreet fork, hardware/services, the FORGE runtime, Wayland/greetd/recovery files, user configuration, and final installed-machine verification. Required system services and user audio services are enabled persistently across reboot.

## Packages and repositories

Interactive Arch package commands inside FORGE's Fish environment route through `forge-install-pkg`; GUI program installation routes `forge-install-program -> forge-app-install -> forge-install-pkg`. Internal bootstrap code uses absolute `/usr/bin/pacman` so the wrapper cannot recurse.

```bash
forge-app-install -S steam
forge-install-pkg -S npm
forge-install-pkg -Syu
forge-install-pkg -Ss package-name
forge-install-pkg -Rns package-name
```

Official Arch repositories remain the system package base. `multilib` is enabled explicitly. Chaotic-AUR is added as a binary community repository, and `yay` provides the ordinary AUR workflow. Apt/Ubuntu and Kali remain isolated in rootless Distrobox/Podman containers; Nix uses its own store and profile.

The installer first establishes the tracked HTTPS Arch mirror list, then Reflector ranks current HTTPS mirrors. `reflector.timer` keeps the official Arch mirror list fresh after reboot; third-party repositories retain their own mirrorlist packages.

## FORGE-OS top bar

The FORGE-OS bar reserves its own shell space above the normal FORGE application header, so Releases, GitHub, Settings, workspace controls, and other normal FORGE controls are no longer covered.

Applications and System remain the primary left-side controls. The center system strip exposes launchable controls for **Network, Audio, Display, Power, Applications, Storage, Appearance, Updates, Security, Recovery, and Advanced**. The strip uses responsive font sizing and horizontal overflow instead of overlapping text or modules. Time and Session remain on the right.

Session actions are detached OS helpers rather than fragile synchronous Electron power calls. Lock, logout, restart, and shutdown therefore survive the FORGE process/session being terminated as part of the requested action.

## Persistent services

The installer enables the required system services and maintenance timers, including NetworkManager, Bluetooth, irqbalance, time sync, CUPS, Ollama, power-profile support where available, fstrim, and Reflector. PipeWire, PipeWire Pulse, and WirePlumber are globally enabled for user sessions and started immediately when a user systemd manager is available.

## Installed-system recovery

Ctrl+Alt+F2 requests the separate FORGE Recovery profile through the on-demand `autovt@tty2.service` alias. If the graphical stack itself is unhealthy, switch to another TTY such as Ctrl+Alt+F3 and run:

```bash
cd ~/FORGE-OS
./scripts/disable-graphical-login.sh
```

That restores console-first access while preserving installed runtimes and user/project data.

## Live ISO recovery and provisioning

The ISO has a separate live-only profile. `forge-live-setup.service` detects ArchISO before making privileged live changes. It creates the ephemeral `forge` account with its password locked, grants passwordless sudo only inside that live environment, enters the same Wayland runtime with live-recovery flags, and opens FORGE's full-screen **Live Recovery** GUI.

Live Recovery exposes **Recovery Root Shell** and **Load / Install ISO or ZIP**. ISO files are mounted read-only; ZIP paths are checked before extraction; only recognized installer entry points are eligible for automatic execution; and the user must type `INSTALL` before a bundle installer runs.

## Build and validate

```bash
./tests/greeter-contract.sh
./tests/source-verify.sh
./scripts/build-forge.sh ~/FORGE
./scripts/build-iso.sh
```

Source verification checks the current greeter, top-bar, session-control, package-routing, mirror/repository, service, live-recovery, FORGE typecheck/lint/test/build, and runtime contracts. `tests/verify.sh` validates the installed machine. ISO publication additionally requires VM/physical hardware acceptance and artifact provenance from [the release checklist](docs/RELEASE_CHECKLIST.md).

## Documentation

- [Architecture](ARCHITECTURE.md)
- [Runtime/session contract](session/README.md)
- [User manual](docs/USER_MANUAL.md)
- [Recovery](docs/RECOVERY.md)
- [Security model](docs/SECURITY_MODEL.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)
- [Changelog](CHANGELOG.md)
