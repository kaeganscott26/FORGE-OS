# ⚒️ FORGE-OS Updates

## Current status

The current development version is **`0.2.1-alpha`**.

FORGE-OS now has a canonical FORGE-owned KWin Wayland shell plus documented alternate presentation profiles around the same installed FORGE runtime.

The authoritative runtime/session guide is [`session/README.md`](../session/README.md).

## 🔴 Current release blocker

[`scripts/bootstrap-arch.sh`](../scripts/bootstrap-arch.sh) currently expects:

```text
manifests/arch-packages.txt
```

That file is absent from the current repository. `manifests/arch-packages.sh` exists but is not consumed by the bootstrap path.

Until the package source of truth is repaired and a clean bootstrap passes, the current tree should **not** be described as a validated fresh install or release-ready ISO. `--skip-packages` is only appropriate on a machine that already has the complete dependency set.

See [`BUILD_STATE.md`](../BUILD_STATE.md) and [`docs/IMPLEMENTATION_GAPS.md`](../docs/IMPLEMENTATION_GAPS.md).

## Canonical production path

```text
greetd / tuigreet
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland (+ XWayland compatibility)
  -> KDE/Plasma visual and service layer beneath FORGE
  -> /usr/local/bin/forge-session
  -> content-addressed FORGE runtime
```

FORGE owns the visible shell. Arch/systemd/KWin/Plasma/PolicyKit/pacman/NetworkManager/PipeWire remain the underlying system infrastructure.

## Runtime/session profiles

Current documentation distinguishes:

- standalone FORGE application mode on macOS, Windows, or an ordinary Linux desktop;
- canonical native FORGE-OS KWin Wayland shell mode;
- native KWin Wayland with Electron rendered through XWayland using `FORGE_USE_XWAYLAND=1`;
- Plasma-hosted FORGE as a development/reference-machine profile;
- historical `0.1.x` X11/Openbox and KWin X11 profiles;
- tty2 recovery.

### Session ownership rule

Exactly one top-level component should own the compositor/session lifecycle.

Canonical command:

```bash
/usr/local/bin/forge-wayland-session
```

Reference-machine development override:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

The wrapper is not the stable default because `startplasma-wayland` and `forge-wayland-session` can both attempt KWin/session ownership. A dedicated Plasma-hosted launcher should eventually run FORGE inside an already-owned Plasma session without starting KWin twice.

## Login-screen switching

At the FORGE `tuigreet` login screen:

1. press **F2**;
2. enter the full session command;
3. return to credentials;
4. authenticate normally.

The selected command affects how FORGE is hosted for that login; it does not create a different FORGE application build.

## Current user-facing features

- native KWin Wayland shell with XWayland compatibility;
- Plasma wallpaper/effects/decoration infrastructure beneath FORGE;
- optional persistent Plasma panels through `forge-panel-manager`;
- FORGE Applications surfaces;
- workspace-constrained file launching;
- PolicyKit-backed Arch repository package installation;
- System Settings integration;
- content-addressed runtime identity and payload verification;
- independent FORGE and FORGE-OS version/commit recording;
- source-based **Check for updates** path using trusted fast-forward-only repositories;
- tty2 recovery;
- ArchISO build tooling, currently blocked from release validation by the package-manifest mismatch.

## Active UX work

Current polish priorities are:

1. restore/normalize the authoritative package manifest;
2. create a first-class Plasma-hosted FORGE launcher with unambiguous session ownership;
3. integrate package installation into FORGE rather than opening an external helper terminal/window;
4. refresh/watch XDG application discovery after installs so newly installed apps immediately appear in FORGE Applications;
5. move toward a stable `forge install ...` user-facing command namespace while leaving pacman as the backend package authority;
6. make shell-only UI explicitly runtime-profile aware;
7. finish theming, panels, settings, notifications, portals, launcher, and external-window polish.

See [`knownUxBugs.md`](knownUxBugs.md) and [`docs/IMPLEMENTATION_GAPS.md`](../docs/IMPLEMENTATION_GAPS.md).

## Updates

Inside native FORGE-OS shell mode, **Check for updates** launches `/usr/local/bin/forge-os-update` in Konsole. It validates trusted origins, clean `main` checkouts, and fast-forward-only history before invoking the authoritative installer. Because the installer currently reaches the missing package-manifest path unless packages are explicitly skipped, a clean end-to-end update is not release-ready until the manifest contract is repaired.

Standalone FORGE retains its normal Electron updater outside the FORGE-OS shell contract.

## Validation

A stable release still requires all physical/ISO gates in [`docs/RELEASE_CHECKLIST.md`](../docs/RELEASE_CHECKLIST.md), including:

- clean package bootstrap from the authoritative manifest;
- direct canonical login without an F2 override;
- real GPU/compositor behavior;
- native Electron and Electron-XWayland compatibility;
- portal/PipeWire behavior;
- panel/wallpaper persistence;
- application install + FORGE launcher refresh;
- logout/relogin and compositor-failure recovery;
- tty2 recovery;
- multi-hardware/VM ISO validation.

## Documentation rule

Active documentation must describe the current architecture and clearly label development/historical profiles. Superseded scripts and stale crash-status notes should be removed rather than left as instructions for future agents or users.
