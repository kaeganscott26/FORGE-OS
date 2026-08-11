# FORGE-OS

FORGE-OS is the Arch Linux integration layer for the separate FORGE application repository. Arch supplies the kernel, systemd, PAM, drivers, package management, networking, audio, filesystems, and hardware services; FORGE owns the visible desktop experience.

## Install or update the physical test machine

Keep both repositories current, then run the one authoritative installer:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
sudo reboot
```

The installer refuses dirty, non-`main`, or stale checkouts. It builds the exact current FORGE commit, applies the tracked FORGE-OS overlays with zero patch fuzz, records source/lock/overlay/executable/`app.asar`/payload identities, installs a content-addressed runtime, installs the complete X11 session, verifies the installed files, enables greetd, selects `graphical.target`, and preserves tty2 recovery. It never reboots automatically.

`--skip-packages` skips the pacman bootstrap when the declared packages are already installed. `--use-current-build` reuses `build/latest.env` only when its FORGE source commit still equals current FORGE `main`. Neither option bypasses source freshness or runtime verification.

## Normal boot

```text
kernel/systemd
  -> greetd on VT1
  -> FORGE-branded tuigreet
  -> PAM authentication
  -> /usr/local/bin/forge-xsession
  -> xinit + Xorg
  -> /usr/local/libexec/forge-session-client
  -> Openbox substrate
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded executable>
```

The greeter does not source `/etc/profile` or `~/.profile`. Its X11 session wrapper is explicitly disabled, and it only discovers the FORGE-owned session directory, so tuigreet cannot inject an extra `startx` around `forge-xsession`. There is no tty1 shell login, profile autostart, `.xinitrc`, acceptance marker, manual `startx`, or autologin in the production path.

Press `Ctrl+Alt+F2` for the independent recovery console. See [Recovery](docs/RECOVERY.md).

## Repository commands

- `scripts/install-forge-linux.sh` — authoritative physical-machine install/update flow.
- `scripts/build-forge.sh` — package the exact FORGE commit and generate ignored `build/latest.env`.
- `scripts/install-runtime.sh` — install and activate the exact recorded content-addressed runtime.
- `scripts/build-iso.sh` — build an ArchISO using the same session/runtime layout.
- `tests/verify.sh` — enforce production boot, session, runtime, sandbox, and recovery invariants.
- `scripts/disable-graphical-login.sh` — switch safely back to console recovery mode.
- `scripts/bootstrap-arch.sh`, `configure-hardware.sh`, `configure-user-desktop.sh`, and `rollback-user-desktop.sh` are focused helpers used by the main flow.

FORGE and FORGE-OS remain independent repositories. Generic application fixes belong in `~/FORGE`; OS integration and packaging belong here.
