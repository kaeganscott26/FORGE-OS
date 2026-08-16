# ⚒️ FORGE-OS

**FORGE-OS is the Arch Linux integration and distribution layer for FORGE.** Arch provides the kernel, systemd, PAM, drivers, package management, networking, audio, filesystems, and hardware services; FORGE owns the visible desktop experience when running in shell mode.

Current development release: **`0.2.1-alpha`**.

> The goal is simple: power on the machine, authenticate, and land directly inside FORGE without exposing a conventional Linux desktop workflow—while still allowing the same FORGE runtime to participate in alternate Linux session profiles when desired.

## 🧭 Runtime configurations

FORGE intentionally supports more than one presentation mode around the same installed runtime. The workspace/runtime stays the durable product boundary; the surrounding desktop/session can change.

> 📘 **Authoritative session guide:** [`session/README.md`](session/README.md) documents session ownership, every known runtime configuration, F2 login commands, compatibility differences, expected UI behavior, and the debugging/recovery ladder.

| Runtime / session | FORGE-OS version line | Status | What it does |
| --- | --- | --- | --- |
| **Standalone FORGE application** | FORGE app version; not tied to a FORGE-OS session version | ✅ Supported outside FORGE-OS | Runs the normal polished FORGE app on macOS, Windows, or an ordinary Linux desktop. The host OS owns launchers, panels, settings, and session lifecycle. |
| **FORGE X11 / Openbox session** | `0.1.1-alpha` | 🗃️ Historical | Xorg/xinit + Openbox supplied the lightweight desktop/window-management substrate while FORGE remained the primary workspace. |
| **Plasma 6 / KWin X11 session** | `0.1.2-alpha`–`0.1.3-alpha` | 🗃️ Historical | Added Plasma/KWin X11 and KDE services with Openbox fallback while preserving the X11/xinit chain. |
| **FORGE native KWin Wayland shell** | `0.2.0-alpha` onward; current `0.2.1-alpha` | ✅ Canonical default | `greetd → forge-wayland-session → KWin Wayland → Plasma services → forge-session → FORGE`. FORGE owns the visible UX; KDE/Plasma supplies infrastructure underneath it. |
| **FORGE Wayland + Electron XWayland fallback** | `0.2.x` | ✅ Compatibility option | Keeps KWin/session ownership on native Wayland but launches the packaged FORGE Electron window through XWayland using `FORGE_USE_XWAYLAND=1`. |
| **Plasma-hosted FORGE Wayland profile** | current development/reference-machine profile | 🧪 Development | Plasma owns the surrounding desktop/session and FORGE runs within that environment. The current manual wrapper still needs a dedicated handoff path to eliminate duplicate KWin/session ownership risk. |

### ⚖️ Session ownership invariant

Exactly **one** top-level component should own the graphical session/compositor:

- **FORGE-owned:** `forge-wayland-session` starts KWin and FORGE becomes the OS UX layer.
- **Host-owned:** Plasma/GNOME/etc. starts and owns the desktop; FORGE should launch inside that already-running session without starting another compositor.

That distinction is what keeps portals, D-Bus activation, panels, application discovery, focus behavior, and logout semantics predictable.

The native shell is also panel-configurable: `forge-panel-manager [edge]` can add persistent Plasma panels without creating another session generation.

## ⌨️ Switching runtime/session from the login screen

The FORGE-branded greetd/tuigreet login can be used as a manual runtime selector for development, recovery, compatibility testing, or personalization.

1. Boot to the FORGE login screen.
2. Press **F2**.
3. Enter the complete executable command for the session you want.
4. Return to the credential prompt and authenticate normally.
5. `greetd` launches that command for the login.

Known commands:

```bash
# Canonical FORGE-owned KWin Wayland shell
/usr/local/bin/forge-wayland-session

# Current reference-machine Plasma-hosted development override
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session

# Historical X11 chain, only when retired X11 components are intentionally installed
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

The Plasma wrapper is **not equivalent** to the canonical direct session. `startplasma-wayland` normally establishes Plasma/KWin while `forge-wayland-session` also starts KWin. Until a dedicated Plasma-hosted handoff launcher exists, treat that wrapper as a useful development/reference configuration with known duplicate-ownership risk. See [`session/README.md`](session/README.md).

These commands select how the same installed FORGE runtime is hosted; they are not separate FORGE application builds.

> A typo or unavailable session executable will usually return you to the greeter. `Ctrl+Alt+F2` remains the independent recovery console.

## 🚀 Quick start

Keep both repositories current, then run the authoritative installer from the normal desktop user account:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
sudo reboot
```

The installer refuses dirty, non-`main`, or stale checkouts. It builds the exact current FORGE commit, applies tracked FORGE-OS overlays with zero patch fuzz, records source/runtime identities, installs the content-addressed runtime, installs the complete graphical session, verifies the installed system, enables greetd, selects `graphical.target`, and preserves tty2 recovery.

After installation, FORGE's **Check for updates** action recognizes `FORGE_OS_SESSION=1` and opens the authenticated FORGE-OS updater instead of installing a standalone Electron artifact. The updater pins and fast-forwards the official FORGE and FORGE-OS `main` checkouts and runs the same authoritative installer. It refuses dirty, divergent, untrusted-origin, or non-`main` repositories and never reboots automatically.

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

The canonical custom session starts KWin directly instead of launching a conventional Plasma desktop. Plasma supplies effects, decorations, wallpaper, portals, and optional panels underneath FORGE; FORGE remains the visible environment. XWayland exists for legacy applications and as an optional Electron compatibility path.

## 🧭 Repository guide

| Area | Purpose |
| --- | --- |
| [`config/`](config/) | greetd and system configuration templates |
| [`manifests/`](manifests/) | Arch package declarations |
| [`overlays/`](overlays/) | temporary FORGE compatibility patches |
| [`scripts/`](scripts/) | bootstrap, build, update, install, recovery, and ISO tooling |
| [`session/`](session/) | graphical session launchers, desktop entries, and [runtime/session documentation](session/README.md) |
| [`tests/`](tests/) | production invariant verification |
| [`docs/`](docs/) | user, architecture, recovery, security, and release guides |
| [`Dev_Notes/`](Dev_Notes/) | current development/UX notes only |

## 📚 Documentation

Start with the [Documentation Hub](docs/README.md).

- 🖥️ [Runtime & Session Architecture](session/README.md)
- 🧱 [Architecture](ARCHITECTURE.md)
- ✅ [Current Build State](BUILD_STATE.md)
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

- `./scripts/install-forge-linux.sh` — authoritative physical-machine install/update flow.
- `forge-os-update` — interactive update flow used by FORGE's **Check for updates** action.
- `./scripts/build-forge.sh` — package the exact FORGE commit and generate ignored build identity metadata.
- `./scripts/install-runtime.sh` — install and activate the recorded content-addressed runtime.
- `./scripts/build-iso.sh` — produce the ArchISO image using the production session/runtime layout.
- `./tests/verify.sh` — verify boot, session, runtime, sandbox, recovery, and source/runtime identity invariants.
- `forge-app-launcher` — open the current searchable application launcher helper.
- `forge-panel-manager [edge]` — add a Plasma panel that can then be customized normally.
- `forge-workspace-runner` — choose and open/run a file constrained to the active FORGE workspace.
- `forge-install-program PACKAGE` — current PolicyKit-authenticated package helper; UX consolidation toward a FORGE-native install surface is tracked as active work.
- `./scripts/disable-graphical-login.sh` — return safely to console-oriented recovery mode.

## 🛟 Recovery

Press `Ctrl+Alt+F2` for the independent tty2 recovery console. See [Recovery](docs/RECOVERY.md) before changing display-manager or session configuration manually.

## 📦 Release status

The repository is structured for ISO production, but the project version remains whatever is declared in [`VERSION`](VERSION). A stable release should only be tagged after the [Release Checklist](docs/RELEASE_CHECKLIST.md) passes on the reference machine and at least one additional hardware/VM target. The canonical FORGE-owned session must pass without requiring an F2 override.

## 🔀 Repository boundary

FORGE and FORGE-OS are intentionally separate repositories. Generic application features and fixes belong in FORGE; Arch integration, boot/session ownership, distribution packaging, hardware configuration, recovery, and ISO construction belong here.
