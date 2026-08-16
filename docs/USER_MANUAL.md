# 👤 FORGE-OS User Manual

This guide covers the supported update, startup, runtime selection, desktop behavior, and recovery workflow for a FORGE-OS development or reference installation.

For the complete runtime/session matrix, see [`session/README.md`](../session/README.md).

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
3. The greeter launches the canonical graphical runtime command:

```bash
/usr/local/bin/forge-wayland-session
```

4. The FORGE desktop/session becomes the visible environment.

No tty1 shell login, manual `startx`, `.xinitrc`, acceptance marker, shell-profile autostart, or autologin is part of the current production path.

## ⌨️ Choosing a runtime from the login screen

FORGE-OS intentionally preserves manual session selection for development, recovery, compatibility testing, and personalization.

At the FORGE-branded login screen:

1. Press **F2**.
2. Type or paste the complete executable command for the runtime configuration you want.
3. Return to the credential prompt and authenticate normally.
4. `greetd` starts the selected command for that login.

Known configurations:

```bash
# Canonical repository-owned KWin Wayland FORGE shell
/usr/local/bin/forge-wayland-session
```

```bash
# Current reference-machine Plasma-hosted development override
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

```bash
# Historical X11 session generations; only usable when retired components are installed
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

### ⚠️ Plasma wrapper ownership note

The Plasma wrapper is useful for development, but it is not currently equivalent to the canonical direct session. `startplasma-wayland` normally establishes Plasma/KWin ownership while `forge-wayland-session` is also designed to start KWin.

Until FORGE-OS gains a dedicated Plasma-hosted handoff launcher, the wrapper can create duplicate session/compositor ownership and should be treated as an experimental/reference-machine profile rather than the stable ISO default.

The canonical direct session must work without F2 before a release is considered stable.

These commands select how the same installed FORGE runtime is hosted; they are not separate FORGE application builds. Standalone FORGE is normally launched from an already-running macOS, Windows, or Linux desktop.

Always use exact absolute executable paths that exist on the machine. If a selected command fails, the graphical session may return to the greeter. `Ctrl+Alt+F2` remains the independent recovery console.

## 🖥️ Desktop behavior

In native FORGE-OS shell mode, FORGE owns the visible workspace experience. Arch remains responsible for system services, package management, hardware, networking, audio, filesystems, and authentication. KWin/Plasma provides compositor, wallpaper, portal, decoration, and optional panel infrastructure underneath FORGE.

The graphical session establishes the XDG/D-Bus/FORGE environment used by the integrated terminal and applications launched from FORGE. The default startup workspace is the authenticated user's home directory.

The FORGE Applications surface currently exposes helpers including **FORGE App Launcher**, **FORGE System Settings**, **FORGE Panel Manager**, **Open or Run Workspace File**, and **Install Arch Program**. The initial native-shell layout has no conventional Plasma panel. Panel Manager can add a top, bottom, left, or right Plasma panel, which can then be customized in Plasma edit mode.

## 📦 Installing applications — current state

The current package-install helper validates Arch repository package names and delegates privileged installation through PolicyKit/pacman. The backend security boundary is intentional.

The user experience is still being consolidated:

- package install may open a separate terminal/window;
- a newly installed application may appear in KDE/Qt application discovery before FORGE's Applications UI refreshes;
- FORGE is expected to gain a more integrated package UI/command namespace while keeping pacman as the package authority.

Current UX gaps are tracked in [`Dev_Notes/knownUxBugs.md`](../Dev_Notes/knownUxBugs.md) and [Implementation Gaps](IMPLEMENTATION_GAPS.md).

## 🔄 Updating FORGE-OS

From native FORGE-OS shell mode, select **Check for updates**. A Konsole window opens and performs the update visibly. It checks that `~/FORGE` and `~/FORGE-OS` are clean, on `main`, and able to fast-forward to their configured `origin/main`; updates both; rebuilds FORGE; and runs the authoritative installer.

Equivalent terminal workflow:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
```

Do not manually replace `/opt/forge/current` or copy session files into `/usr/local` outside the installer unless deliberately performing recovery work.

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

- [Runtime & Session Architecture](../session/README.md)
- [Documentation Hub](README.md)
- [Architecture](../ARCHITECTURE.md)
- [Desktop Session](DESKTOP_SESSION.md)
- [Shell Mode](SHELL_MODE.md)
- [Implementation Gaps](IMPLEMENTATION_GAPS.md)
- [Release Checklist](RELEASE_CHECKLIST.md)
