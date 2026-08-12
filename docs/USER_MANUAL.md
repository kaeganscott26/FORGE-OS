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
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

4. The FORGE desktop/session becomes the visible environment.

No tty1 shell login, manual `startx`, `.xinitrc`, acceptance marker, shell-profile autostart, or autologin is part of the supported production path.

## 🖥️ Desktop behavior

FORGE owns the visible workspace experience. The Arch substrate remains responsible for system services, package management, hardware, networking, audio, filesystems, and authentication.

The graphical session establishes the XDG/D-Bus/FORGE environment used by the integrated terminal and applications launched from FORGE. The default startup workspace is the authenticated user's home directory.

## 📦 Updating FORGE

FORGE and FORGE-OS are separate repositories. Update both before reinstalling the OS integration layer:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
```

Do not manually replace `/opt/forge/current` or copy session files into `/usr/local` outside the installer unless you are deliberately performing recovery work.

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
