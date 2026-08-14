# FORGE-OS Updates

## Current status

The current development version is `0.2.1-alpha`.

FORGE-OS now implements a custom native KWin Wayland session. Plasma supplies composition, styles, animations, wallpaper, portals, and optional panels beneath FORGE; FORGE remains the visible user interface.

## Newest updates

Recent additions include:

- KWin Wayland as the compositor, with XWayland only for legacy applications.
- A FORGE-owned session launcher rather than a conventional Plasma desktop session.
- An initially panel-free Plasma layer and a FORGE Panel Manager for opt-in panels.
- Removal of the retired XFCE/X11 shell utilities, with Dolphin and KDE services supplying background desktop integration.
- Breeze Dark and Kvantum visual defaults.
- Plasma System Settings integration.
- A searchable application launcher.
- A workspace-constrained file runner.
- A PolicyKit-authenticated Arch package installer.
- KDE portal integration with a GTK fallback.
- Stronger content-addressed runtime identity verification.
- Independent FORGE and FORGE-OS version and commit recording.
- Lockfile, overlay, executable, `app.asar`, and complete runtime payload hashes.
- Protection against activating stale builds produced from another FORGE-OS revision.
- A refreshed zero-fuzz compatibility overlay for current FORGE source.
- A FORGE-OS-aware **Check for updates** action that opens the visible authenticated updater, fast-forwards both trusted repositories, and runs the authoritative installer.

## Using the new features

Open the searchable Plasma application launcher from FORGE:

```bash
forge-app-launcher
```

Choose a file from the active FORGE workspace and open or execute it:

```bash
forge-workspace-runner
```

Install a validated package from the Arch repositories through PolicyKit:

```bash
forge-install-program PACKAGE
```

For example:

```bash
forge-install-program firefox
```

Open Plasma System Settings:

```bash
systemsettings
```

The package installer validates package names and requests PolicyKit authorization. FORGE itself continues to run as the authenticated normal user rather than as root.

## Install or update FORGE-OS

From FORGE, select **Check for updates** and follow the visible update terminal. The updater pins the official repository origins, refuses dirty, divergent, untrusted, missing, or non-`main` checkouts, and never reboots automatically.

Keep both repositories current and use the authoritative installer:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
sudo reboot
```

After installation, verify the production invariants:

```bash
cd ~/FORGE-OS
./tests/verify.sh
```

## Wayland session status

The repository session default is now native Wayland:

The production path is:

```text
greetd
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland with XWayland compatibility
  -> Plasma visual/panel services beneath FORGE
  -> FORGE
```

The launcher deliberately does not use `startplasma-wayland`: that would impose the conventional Plasma desktop. It starts KWin directly, runs `plasmashell` only as the wallpaper/panel service layer, removes the stock panel once, and launches FORGE natively.

Confirm the supported session type from a FORGE terminal:

```bash
echo "$XDG_SESSION_TYPE"
```

Expected output:

```text
wayland
```

### Wayland acceptance requirements

A stable release still requires physical validation of:

1. The dedicated FORGE Wayland client operating without a required `DISPLAY`.
2. The FORGE-owned Wayland desktop entry and greetd default.
3. KWin Wayland startup without a conventional Plasma desktop layout.
4. Correct live session variables, including:
   - `XDG_SESSION_TYPE=wayland`
   - `WAYLAND_DISPLAY`
   - `XDG_CURRENT_DESKTOP=FORGE`
   - `XDG_SESSION_DESKTOP=FORGE`
   - `FORGE_OS_SESSION=1`
   - `FORGE_SHELL_MODE=1`
5. Electron native-Wayland testing, with XWayland fallback where appropriate.
6. KDE portal and PipeWire validation.
7. Logout, compositor-crash, and tty2 recovery testing.
8. Separate Wayland verification and physical acceptance tests.
9. tty2 recovery when the Wayland compositor cannot start.
10. Updated documentation and release gates.

The architecture is implemented; items involving actual GPU/session behavior remain physical release gates.

## Recovery and diagnostics

The independent recovery console remains available at:

```text
Ctrl+Alt+F2
```

Useful diagnostics are:

```bash
systemctl status greetd.service
journalctl -u greetd.service -b --no-pager -n 200
tail -n 200 ~/.local/state/forge/session.log
cd ~/FORGE-OS
./tests/verify.sh
```

A permission error while scanning this root-owned ArchISO staging path does not by itself indicate a FORGE-OS runtime failure:

```text
build/archiso-work/x86_64/airootfs/root
```
