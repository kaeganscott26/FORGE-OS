# FORGE-OS

FORGE-OS is the Arch Linux integration layer for the separate FORGE application repository. Arch supplies the kernel, systemd, PAM, hardware and system services; FORGE owns the visible desktop.

## Install or update

```bash
cd ~/FORGE-OS
git pull
./scripts/install-forge-os.sh
sudo reboot
```

The installer updates dependencies, builds FORGE from `~/FORGE`, applies the tracked FORGE-OS overlays, installs a content-addressed runtime, installs the complete X11 session, verifies it, enables greetd, and selects `graphical.target`. It never reboots automatically and does not use acceptance marker files.

For recovery or offline maintenance only, `--skip-packages` reuses already installed dependencies and `--use-current-build` reuses `build/latest.env` after proving its source commit equals FORGE HEAD. These options do not bypass payload or production verification.

Normal boot is kernel/systemd → greetd/tuigreet on VT1 → PAM authentication → Xorg/Openbox substrate → FORGE. No console login, shell profile, `.xinitrc`, manual `startx`, or autologin participates in that path.

Press `Ctrl+Alt+F2` for the recovery console. See [Recovery](docs/RECOVERY.md).

## Commands

- `scripts/install-forge-os.sh`: authoritative physical-machine install/update flow.
- `scripts/build-forge.sh`: package FORGE and generate ignored `build/latest.env`.
- `scripts/install-runtime.sh`: install the exact recorded content-addressed runtime.
- `scripts/build-iso.sh`: produce an image with the same runtime/session layout.
- `tests/verify.sh`: enforce production boot, runtime, session, sandbox, and recovery invariants.
- `scripts/disable-graphical-login.sh`: recovery-safe disable operation.
- bootstrap, hardware, desktop-default, and rollback-desktop scripts are focused helpers used by the main flow.

FORGE and FORGE-OS remain independent Git repositories. Generic application fixes belong in `~/FORGE`; OS integration and overlays belong here.
