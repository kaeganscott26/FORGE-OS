# 🛟 Recovery Guide

FORGE-OS keeps a recovery console independent from the graphical stack so a broken greetd/X11/FORGE session does not lock you out of the machine.

## ⌨️ Open the recovery console

Press:

```text
Ctrl + Alt + F2
```

Authenticate normally on tty2. This path does not depend on greetd, X11, Openbox, or FORGE.

## 🔎 Inspect the graphical chain

```bash
systemctl status greetd.service
journalctl -u greetd.service -b --no-pager -n 200
tail -n 200 ~/.local/state/forge/session.log
cd ~/FORGE-OS
./tests/verify.sh
```

For X11-specific failures:

```bash
ls -lt ~/.local/share/xorg/
grep -E '\(EE\)|Fatal|fatal|ERROR|Error|failed|Failed' ~/.local/share/xorg/Xorg.*.log 2>/dev/null
```

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
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

## ⚠️ Recovery invariants

- Keep `getty@tty2.service` enabled.
- Do not introduce permanent autologin.
- Do not reintroduce `.xinitrc` or profile-based graphical autostart into the production path.
- Do not use permanent Electron `--no-sandbox` as a recovery shortcut.
- Run `./tests/verify.sh` after repairing system/session files.

Return to the [Documentation Hub](README.md) or review the [Desktop Session](DESKTOP_SESSION.md) for the normal startup chain.
