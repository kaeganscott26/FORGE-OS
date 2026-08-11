# 📘 FORGE-OS User Manual

## 🚀 Overview

FORGE-OS is the Linux integration and boot environment for the cross-platform [FORGE application](https://github.com/kaeganscott26/FORGE). Linux provides the kernel, drivers, storage, networking, authentication, and services; FORGE provides the visible workspace UI.

## 🧰 Install on Arch Linux

1. Back up important files and keep a recovery TTY available.
2. Clone FORGE and FORGE-OS side-by-side in your home directory.
3. Run `./scripts/enable-forge-os.sh` from FORGE-OS.
4. Run `startx` and complete [Acceptance](ACCEPTANCE.md).
5. Create `build/acceptance.env` with `PACKAGED_RUNTIME_ACCEPTED=yes` and `build/graphical-login-acceptance.env` with `GRAPHICAL_LOGIN_ACCEPTED=yes`.
6. Run `./scripts/enable-graphical-login.sh`, then reboot manually.

The next boot presents the FORGE-OS login screen and launches FORGE after authentication.

## ⚙️ Configuration and features

- Set the session user in `config/session.env`.
- Set `FORGE_WORKSPACE` to change the default `~/FORGE-OS` workspace.
- Set `FORGE_RUNTIME_ROOT` to change `/opt/forge/current`.
- Configure browser/file-manager defaults with `scripts/configure-user-desktop.sh`.
- Enable the performance profile and core hardware services with `scripts/configure-hardware.sh`.
- Temporarily bypass console autostart with `~/.config/forge/disable-autostart`.

FORGE includes workspace navigation, files, Git, tasks, durable workspace memory, terminals, configurable AI providers, desktop app discovery, browser/file-manager launch, system overview, settings, and controlled session actions. Xorg/Openbox is the recoverable substrate; greetd/tuigreet provides PAM login; DBus/systemd activation carries graphical environment values to UI helpers.

## 🛟 Recovery

Press `Ctrl+Alt+F2`, log in, and run `sudo systemctl disable --now greetd.service`. See [Recovery](RECOVERY.md) for rollback commands and log locations.

## 💿 ISO

Run `./scripts/build-forge.sh ~/FORGE`, then `./scripts/build-iso.sh`. The ISO and checksums appear under `build/iso/`. Test boot, login, networking, audio, GPU acceleration, suspend/resume, installation, and TTY recovery before release.
