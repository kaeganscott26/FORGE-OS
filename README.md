# ⚒️ FORGE-OS

**FORGE-OS is the Arch Linux integration and distribution layer for FORGE.** Arch provides the kernel, systemd, PAM, drivers, package management, networking, audio, filesystems, and hardware services; FORGE owns the visible desktop experience when running in shell mode.

Current development release: **`0.2.1-alpha`**.

> The goal is simple: power on, authenticate, and land directly inside FORGE—while still allowing the same installed FORGE runtime to participate in alternate Linux session profiles when desired.

> ⚠️ **Current fresh-install blocker:** `scripts/bootstrap-arch.sh` expects `manifests/arch-packages.txt`, but that file is currently absent. The repository contains `manifests/arch-packages.sh`, which is not consumed by the bootstrap path. Until the authoritative package manifest is restored or the bootstrap contract is intentionally changed, a normal fresh install that reaches package bootstrap is expected to fail. See [Current Build State](BUILD_STATE.md) and [Implementation Gaps](docs/IMPLEMENTATION_GAPS.md).

## 🧭 Runtime configurations

FORGE intentionally supports more than one presentation mode around the same installed runtime. The workspace/runtime remains the durable product boundary; the surrounding desktop/session can change.

> 📘 **Authoritative session guide:** [`session/README.md`](session/README.md) documents session ownership, known runtime configurations, F2 login commands, compatibility differences, expected UI behavior, and the debugging/recovery ladder.

| Runtime / session | Version line | Status | What it does |
| --- | --- | --- | --- |
| **Standalone FORGE application** | FORGE app version | ✅ Supported outside FORGE-OS | Normal polished FORGE app on macOS, Windows, or an ordinary Linux desktop. Host OS owns desktop/session UX. |
| **FORGE X11 / Openbox** | `0.1.1-alpha` | 🗃️ Historical | Xorg/xinit + Openbox hosted FORGE as the primary workspace. |
| **Plasma 6 / KWin X11** | `0.1.2-alpha`–`0.1.3-alpha` | 🗃️ Historical | Plasma/KWin X11 bridge with Openbox fallback. |
| **FORGE native KWin Wayland shell** | `0.2.0-alpha` onward; current `0.2.1-alpha` | ✅ Canonical default | `greetd → forge-wayland-session → KWin Wayland → Plasma services → forge-session → FORGE`. FORGE owns the visible UX. |
| **Native Wayland + Electron XWayland** | `0.2.x` | ✅ Compatibility option | KWin remains Wayland; only the FORGE Electron window uses XWayland via `FORGE_USE_XWAYLAND=1`. |
| **Plasma-hosted FORGE Wayland** | current development/reference profile | 🧪 Development | Plasma owns the surrounding desktop/session. The current manual wrapper still needs a dedicated handoff to eliminate duplicate KWin/session ownership risk. |

### ⚖️ Session ownership invariant

Exactly **one** top-level component should own the graphical session/compositor:

- **FORGE-owned:** `forge-wayland-session` starts KWin and FORGE becomes the OS UX layer.
- **Host-owned:** Plasma/GNOME/etc. starts and owns the desktop; FORGE should launch inside that already-running session without starting another compositor.

That distinction keeps portals, D-Bus activation, panels, application discovery, focus behavior, and logout semantics predictable.

## ⌨️ Switching runtime/session from the login screen

At the FORGE-branded `tuigreet` login:

1. Press **F2**.
2. Enter the complete session command.
3. Return to the credential prompt.
4. Authenticate normally.
5. `greetd` launches the selected command for that login.

Known commands:

```bash
# Canonical FORGE-owned KWin Wayland shell
/usr/local/bin/forge-wayland-session

# Current reference-machine Plasma-hosted development override
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session

# Historical X11 chain; only when retired X11 components are intentionally installed
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

The Plasma wrapper is **not equivalent** to the canonical direct session. `startplasma-wayland` normally establishes Plasma/KWin while `forge-wayland-session` also starts KWin. Until a dedicated Plasma-hosted handoff exists, treat that wrapper as a useful development/reference configuration with known duplicate-ownership risk.

These commands select how the same installed FORGE runtime is hosted; they are not separate FORGE application builds. `Ctrl+Alt+F2` remains the independent recovery console.

## 🚀 Install/update workflow

The intended authoritative workflow is:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
```

**Current caveat:** the package-bootstrap stage is blocked by the missing `manifests/arch-packages.txt`. Do not present the current tree as a validated fresh install until that is fixed. `--skip-packages` is only appropriate when all required dependencies are already installed.

The installer otherwise enforces clean/current `main` repositories, builds the exact FORGE revision, applies zero-fuzz overlays, records content-addressed runtime identity, installs the session/runtime, verifies installed files, enables greetd, preserves tty2 recovery, and never reboots automatically.

## 🖥️ Canonical production boot path

```text
kernel + systemd
  -> greetd on VT1
  -> FORGE-branded tuigreet
  -> PAM authentication
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland + Plasma visual/service layer
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded FORGE executable>
```

The canonical session starts KWin directly. Plasma supplies effects, decorations, wallpaper, portals, and optional panels underneath FORGE. XWayland exists for legacy applications and as an optional Electron compatibility path.

## 🎛️ Current UX work

Current `0.2.1-alpha` polish priorities include:

- restore the authoritative Arch package manifest;
- create a first-class Plasma-hosted FORGE launcher with unambiguous compositor ownership;
- integrate package installation into the FORGE UI while retaining PolicyKit/pacman underneath;
- refresh/watch XDG app discovery after installs so newly installed apps appear immediately in FORGE Applications;
- formalize runtime-profile capabilities so standalone, host-owned, and native-shell UI do not conflict;
- complete themes, panels, settings, notifications, portals, launcher, and external-window polish.

See [Implementation Gaps](docs/IMPLEMENTATION_GAPS.md) and [Known UX Issues](Dev_Notes/knownUxBugs.md).

## 🧭 Repository guide

| Area | Purpose |
| --- | --- |
| [`config/`](config/) | greetd, portal, and system configuration templates |
| [`manifests/`](manifests/) | Arch package declarations — currently requires repair/alignment with bootstrap |
| [`overlays/`](overlays/) | temporary FORGE compatibility patches |
| [`scripts/`](scripts/) | bootstrap, build, update, install, recovery, and ISO tooling |
| [`session/`](session/) | graphical session launchers, desktop entries, and [runtime/session documentation](session/README.md) |
| [`tests/`](tests/) | production invariant verification |
| [`docs/`](docs/) | user, architecture, recovery, security, and release guides |
| [`Dev_Notes/`](Dev_Notes/) | current development/UX notes only |

## 📚 Documentation

- 🖥️ [Runtime & Session Architecture](session/README.md)
- 🧱 [Architecture](ARCHITECTURE.md)
- ✅ [Current Build State](BUILD_STATE.md)
- 📚 [Documentation Hub](docs/README.md)
- 👤 [User Manual](docs/USER_MANUAL.md)
- 🪟 [Desktop Session](docs/DESKTOP_SESSION.md)
- 🧰 [Shell Mode](docs/SHELL_MODE.md)
- 🛟 [Recovery](docs/RECOVERY.md)
- 📦 [Release Checklist](docs/RELEASE_CHECKLIST.md)
- 🔐 [Security Model](docs/SECURITY_MODEL.md)
- 🧪 [Implementation Gaps](docs/IMPLEMENTATION_GAPS.md)
- 🐞 [Known UX Issues](Dev_Notes/knownUxBugs.md)
- 📝 [Changelog](CHANGELOG.md)

## 🧰 Important commands

- `./scripts/install-forge-linux.sh` — authoritative physical-machine install/update flow; package bootstrap currently blocked until the manifest mismatch is repaired.
- `forge-os-update` — interactive update flow used by FORGE's **Check for updates** action.
- `./scripts/build-forge.sh` — package the exact FORGE commit and generate build identity metadata.
- `./scripts/install-runtime.sh` — install and activate the content-addressed runtime.
- `./scripts/build-iso.sh` — ArchISO production tooling; do not treat as release-ready while the package manifest is broken.
- `./tests/verify.sh` — verify boot, session, runtime, sandbox, recovery, package presence, and source/runtime identity invariants.
- `forge-app-launcher` — current searchable application launcher helper.
- `forge-panel-manager [edge]` — add a customizable Plasma panel.
- `forge-workspace-runner` — open/run a file constrained to the active FORGE workspace.
- `forge-install-program PACKAGE` — current PolicyKit-authenticated package helper; UX consolidation is active work.
- `./scripts/disable-graphical-login.sh` — return safely to console-oriented recovery mode.

## 📦 Release status

FORGE-OS remains **alpha**. A stable release requires the package-manifest blocker to be repaired, the canonical direct Wayland session to pass without F2, `tests/verify.sh` to report zero failures, and the complete [Release Checklist](docs/RELEASE_CHECKLIST.md) to pass on the reference machine plus at least one additional hardware/VM target.

## 🔀 Repository boundary

FORGE and FORGE-OS are intentionally separate repositories. Generic application features and fixes belong in FORGE; Arch integration, boot/session ownership, distribution packaging, hardware configuration, recovery, and ISO construction belong here.
