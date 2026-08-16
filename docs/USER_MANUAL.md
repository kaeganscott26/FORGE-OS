# 👤 FORGE-OS User Manual

This guide covers update, startup, runtime selection, desktop behavior, and recovery for the current FORGE-OS development/reference installation.

For the complete runtime/session matrix, see [`session/README.md`](../session/README.md).

## ⚠️ Current fresh-install status

FORGE-OS is currently `0.2.1-alpha`, and the repository has a known package-bootstrap blocker:

[`scripts/bootstrap-arch.sh`](../scripts/bootstrap-arch.sh) expects:

```text
manifests/arch-packages.txt
```

but that file is currently absent. `manifests/arch-packages.sh` exists, but it is not the file consumed by the authoritative bootstrap path.

Until that mismatch is repaired, **do not treat the current tree as a validated fresh install**. `--skip-packages` is only safe when the machine already has the complete required dependency set.

See [Current Build State](../BUILD_STATE.md) and [Implementation Gaps](IMPLEMENTATION_GAPS.md).

## 🚀 Intended update/install flow

Run from the normal desktop user account:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
```

The installer requires both repositories to be clean, on `main`, and current with `origin/main`. After the package-manifest blocker is repaired, the intended flow installs declared Arch dependencies, rebuilds the exact FORGE revision, installs the content-addressed runtime and graphical session, verifies the production chain, enables greetd, and selects graphical boot.

The installer never reboots automatically.

## 🔐 Normal startup

A healthy installed system boots directly to the FORGE-branded login on VT1.

Canonical graphical runtime command:

```bash
/usr/local/bin/forge-wayland-session
```

The canonical `0.2.x` path is native KWin Wayland with FORGE as the visible shell. No tty1 shell login, manual `startx`, `.xinitrc`, acceptance marker, shell-profile autostart, or autologin is part of the production path.

## ⌨️ Choosing a runtime from the login screen

At the FORGE-branded `tuigreet` screen:

1. Press **F2**.
2. Type or paste the complete executable command for the runtime configuration you want.
3. Return to the credential prompt and authenticate normally.
4. `greetd` starts that command for the login.

Known configurations:

```bash
# Canonical repository-owned KWin Wayland FORGE shell
/usr/local/bin/forge-wayland-session

# Current reference-machine Plasma-hosted development override
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session

# Historical X11 generations; only when retired components are deliberately installed
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

### ⚠️ Plasma wrapper ownership note

The Plasma wrapper is useful for development, but it is not equivalent to the canonical direct session. `startplasma-wayland` normally establishes Plasma/KWin ownership while `forge-wayland-session` is also designed to start KWin.

Until FORGE-OS gains a dedicated Plasma-hosted handoff launcher, the wrapper can create duplicate session/compositor ownership and should be treated as a reference/development profile rather than the stable ISO default.

The canonical direct session must work without F2 before a release is considered stable.

These commands select how the same installed FORGE runtime is hosted; they are not separate FORGE application builds. Standalone FORGE is normally launched from an already-running macOS, Windows, or Linux desktop.

If a selected command fails, the graphical session may return to the greeter. `Ctrl+Alt+F2` remains the independent recovery console.

## 🖥️ Desktop behavior

In native FORGE-OS shell mode, FORGE owns the visible workspace experience. Arch remains responsible for system services, package management, hardware, networking, audio, filesystems, and authentication. KWin/Plasma provides compositor, wallpaper, portals, decoration, and optional panel infrastructure underneath FORGE.

The FORGE Applications surface currently exposes helpers including **FORGE App Launcher**, **FORGE System Settings**, **FORGE Panel Manager**, **Open or Run Workspace File**, and **Install Arch Program**.

## 📦 Installing applications — current state

The package helper validates Arch repository package names and delegates privileged installation through PolicyKit/pacman. That backend boundary is intentional.

Current UX gaps:

- package install may open a separate terminal/window;
- a newly installed application may appear in KDE/Qt application discovery before FORGE's Applications UI refreshes;
- FORGE should eventually expose a cleaner `forge install ...` / native package surface while pacman remains the package authority.

Current UX work is tracked in [`Dev_Notes/knownUxBugs.md`](../Dev_Notes/knownUxBugs.md) and [Implementation Gaps](IMPLEMENTATION_GAPS.md).

## 🔄 Updating FORGE-OS

From native FORGE-OS shell mode, **Check for updates** opens the visible source-based updater. It verifies trusted clean `main` repositories, fast-forwards them, and invokes the authoritative installer.

Because the installer currently reaches the missing package-manifest path unless package bootstrap is skipped, update/install verification is not considered cleanly release-ready until that manifest contract is repaired.

The updater never discards local changes or reboots automatically.

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

## 📚 More documentation

- [Runtime & Session Architecture](../session/README.md)
- [Current Build State](../BUILD_STATE.md)
- [Documentation Hub](README.md)
- [Architecture](../ARCHITECTURE.md)
- [Desktop Session](DESKTOP_SESSION.md)
- [Shell Mode](SHELL_MODE.md)
- [Implementation Gaps](IMPLEMENTATION_GAPS.md)
- [Recovery Guide](RECOVERY.md)
- [Release Checklist](RELEASE_CHECKLIST.md)
