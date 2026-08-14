# 🛟 Recovery Guide

FORGE-OS keeps a recovery console independent from the graphical stack so a broken greetd/Wayland/FORGE session does not lock you out of the machine.

## ⌨️ Open the recovery console

Press:

```text
Ctrl + Alt + F2
```

Authenticate normally on tty2. This path does not depend on greetd, KWin, Wayland, Plasma, or FORGE.

## 🔎 Inspect the graphical chain

```bash
systemctl status greetd.service
journalctl -u greetd.service -b --no-pager -n 200
tail -n 200 ~/.local/state/forge/session.log
cd ~/FORGE-OS
./tests/verify.sh
```

For compositor-specific failures:

```bash
journalctl --user -b --no-pager -n 200
grep -E 'ERROR|Error|failed|Failed' ~/.local/state/forge/session.log
```

If KWin fails before creating `WAYLAND_DISPLAY`, remain on tty2, update/reinstall the tracked session, and inspect the current-boot journal. There is deliberately no Openbox/X11 production fallback; tty2 is the recovery boundary.

## 🧯 Disable graphical login safely

```bash
cd ~/FORGE-OS
./scripts/disable-graphical-login.sh
```

This disables greetd, switches the default target to `multi-user.target`, and enables console login on tty1 and tty2. It does not remove the installed FORGE runtime or user data and does not reboot automatically.

## 🔧 Restore the production session

After repairing or updating the repositories:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
sudo reboot
```

The expected post-authentication runtime command is:

```bash
/usr/local/bin/forge-wayland-session
```

If **Check for updates** fails, its Konsole window remains open with the exact error. Resolve dirty, non-`main`, missing, divergent, or untrusted-origin source checkouts from tty2 before retrying. The updater deliberately does not reset, discard, or overwrite local work.

## ⚠️ Recovery invariants

- Keep `getty@tty2.service` enabled.
- Do not introduce permanent autologin.
- Do not reintroduce Xorg, `.xinitrc`, or profile-based graphical autostart into the production path.
- Do not use permanent Electron `--no-sandbox` as a recovery shortcut.
- Run `./tests/verify.sh` after repairing system/session files.

Return to the [Documentation Hub](README.md) or review the [Desktop Session](DESKTOP_SESSION.md) for the normal startup chain.
