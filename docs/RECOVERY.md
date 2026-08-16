# 🛟 Recovery Guide

FORGE-OS keeps a recovery console independent from the graphical stack so a broken greetd/Wayland/Plasma/FORGE session does not lock you out of the machine.

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

If KWin fails before creating `WAYLAND_DISPLAY`, remain on tty2, update/reinstall the tracked session, and inspect the current-boot journal. There is deliberately no automatic Openbox/X11 production fallback; tty2 is the recovery boundary.

## 🧭 Use F2 as a diagnostic session selector

At the FORGE `tuigreet` login screen, **F2** can select a complete alternate session command for one login.

Canonical production command:

```bash
/usr/local/bin/forge-wayland-session
```

Current reference-machine Plasma-hosted development override:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

Use alternate commands to isolate compatibility issues, not as a substitute for repairing the canonical production path. The Plasma wrapper has a known duplicate KWin/session-ownership risk because both the outer Plasma session and inner FORGE launcher can attempt to own the compositor.

Historical X11 commands are not expected to work on a current `0.2.x` install unless the retired components are deliberately reinstalled.

See [`session/README.md`](../session/README.md) for the full compatibility ladder.

## 🧯 Disable graphical login safely

```bash
cd ~/FORGE-OS
./scripts/disable-graphical-login.sh
```

This disables greetd, switches the default target to `multi-user.target`, and enables console login on tty1 and tty2. It does not remove the installed FORGE runtime or user data and does not reboot automatically.

## 🔧 Restore the canonical production session

After repairing or updating the repositories:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
sudo reboot
```

Expected post-authentication command:

```bash
/usr/local/bin/forge-wayland-session
```

If **Check for updates** fails, its Konsole window remains open with the exact error. Resolve dirty, non-`main`, missing, divergent, or untrusted-origin source checkouts from tty2 before retrying. The updater deliberately does not reset, discard, or overwrite local work.

## ⚠️ Recovery invariants

- Keep `getty@tty2.service` enabled.
- Do not introduce permanent autologin.
- Do not reintroduce Xorg, `.xinitrc`, or profile-based graphical autostart as the current production path.
- Do not use permanent Electron `--no-sandbox` as a recovery shortcut.
- Do not promote a nested Plasma/KWin wrapper to stable default until session ownership is unambiguous.
- Run `./tests/verify.sh` after repairing system/session files.

## 🔗 Related documentation

- [Runtime & Session Architecture](../session/README.md)
- [Documentation Hub](README.md)
- [Desktop Session](DESKTOP_SESSION.md)
- [Architecture](../ARCHITECTURE.md)
- [Release Checklist](RELEASE_CHECKLIST.md)
