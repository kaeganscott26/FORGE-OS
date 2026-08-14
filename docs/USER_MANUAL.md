# 👤 FORGE-OS User Manual

This guide covers the supported update, startup, and recovery workflow for a FORGE-OS development or reference installation.

## 🚀 Update and install

Run from the normal desktop user account:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
```

The installer requires both repositories to be clean, on `main`, and current with `origin/main`. It installs declared Arch dependencies, rebuilds the exact FORGE source revision, installs the recorded content-addressed runtime, installs the graphical session, verifies the production chain, enables greetd, and selects graphical boot.

The installer never reboots automatically.

Reboot manually when verification succeeds:

```bash
sudo reboot
```

## 🔐 Normal startup

A healthy installation boots directly to the FORGE-branded login on VT1.

1. Enter a normal Linux username and password.
2. PAM verifies the credentials.
3. The greeter launches the verified graphical runtime command:

```bash
/usr/local/bin/forge-wayland-session
```

4. The FORGE desktop/session becomes the visible environment.

No tty1 shell login, manual `startx`, `.xinitrc`, acceptance marker, shell-profile autostart, or autologin is part of the supported production path.

## 🖥️ Desktop behavior

FORGE owns the visible workspace experience. The Arch substrate remains responsible for system services, package management, hardware, networking, audio, filesystems, and authentication.

The graphical session establishes the XDG/D-Bus/FORGE environment used by the integrated terminal and applications launched from FORGE. The default startup workspace is the authenticated user's home directory.

The FORGE Applications menu includes **FORGE App Launcher**, **FORGE System Settings**, **FORGE Panel Manager**, **Open or Run Workspace File**, and **Install Arch Program**. The initial layout has no conventional Plasma panel. Panel Manager adds a top, bottom, left, or right Plasma panel; right-click the new panel to enter Plasma edit mode and customize widgets, size, alignment, visibility, and position. Wallpaper, KWin styles, effects, and animations remain provided by Plasma underneath FORGE.

## 📦 Updating FORGE

From FORGE-OS, select **Check for updates**. A Konsole window opens and performs the update visibly. It checks that `~/FORGE` and `~/FORGE-OS` are clean, on `main`, and able to fast-forward to their configured `origin/main`; updates both; rebuilds FORGE; and runs the authoritative installer. Follow any authentication prompts, review the final verification result, and reboot manually when convenient.

The equivalent terminal workflow remains available:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
```

Do not manually replace `/opt/forge/current` or copy session files into `/usr/local` outside the installer unless you are deliberately performing recovery work.

The update helper refuses dirty, divergent, missing, or non-`main` checkouts. It never discards local changes, changes branches, downgrades revisions, or reboots automatically. Outside a FORGE-OS session, FORGE retains its standalone application-release updater.

## 🛟 Recovery

Press `Ctrl+Alt+F2` to open the independent tty2 recovery console.

Useful diagnostics:

```bash
systemctl status greetd.service
journalctl -u greetd.service -b --no-pager -n 200
tail -n 200 ~/.local/state/forge/session.log
cd ~/FORGE-OS
./tests/verify.sh
```

To disable graphical login while preserving the installed runtime and user data:

```bash
cd ~/FORGE-OS
./scripts/disable-graphical-login.sh
```

See the full [Recovery Guide](RECOVERY.md).

## 📚 More documentation

- [Documentation Hub](README.md)
- [Architecture](../ARCHITECTURE.md)
- [Desktop Session](DESKTOP_SESSION.md)
- [Release Checklist](RELEASE_CHECKLIST.md)
