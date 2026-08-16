# ⚒️ FORGE-OS

**FORGE-OS is the Arch Linux integration and distribution layer for FORGE.** Arch provides the kernel, systemd, PAM, drivers, package management, networking, audio, filesystems, and hardware services; FORGE owns the visible desktop experience.

Current development release: **`0.2.1-alpha`**.

> The goal is simple: power on the machine, authenticate, and land directly inside FORGE without exposing a conventional Linux desktop workflow.

## 🧭 Runtime configurations

FORGE is intentionally able to run in more than one Linux presentation mode. The workspace/runtime stays the durable product boundary; the surrounding desktop/session can change depending on whether FORGE is being used as a normal application, as a Linux desktop application, or as the FORGE-OS shell.

| Runtime / session | FORGE-OS version line | Status | What it does |
| --- | --- | --- | --- |
| **Standalone FORGE application** | FORGE app version; not tied to a FORGE-OS session version | ✅ Supported outside FORGE-OS | Runs the normal polished FORGE application on macOS, Windows, or an ordinary Linux desktop. `FORGE_OS_SESSION` / shell-only surfaces are absent; the host OS owns launchers, panels, settings, and desktop behavior. |
| **FORGE X11 / Openbox session** | `0.1.1-alpha` session line | 🗃️ Historical | greetd authenticated into the verified `/usr/bin/xinit /usr/local/libexec/forge-session-client` chain. Openbox supplied the lightweight desktop/window-management substrate while FORGE remained the primary workspace. Retained in Git history, not the current production session. |
| **Plasma 6 / KWin X11 session** | `0.1.2-alpha`–`0.1.3-alpha` | 🗃️ Historical | Added Plasma 6/KWin X11, KDE helpers, System Settings, application surfaces, and an automatic Openbox fallback while preserving the X11/xinit login chain. This was the bridge between the original X11 runtime and native Wayland. |
| **FORGE native KWin Wayland shell** | `0.2.0-alpha` onward; current `0.2.1-alpha` | ✅ Current default | greetd → `forge-wayland-session` → KWin Wayland → Plasma visual/service layer → `forge-session` → FORGE. FORGE owns the visible UX; Plasma supplies composition, effects, wallpaper, portals, optional panels, and Linux desktop interoperability underneath it. |
| **FORGE Wayland session + Electron XWayland fallback** | `0.2.x` | ✅ Current compatibility option | Keeps the current KWin Wayland FORGE-OS session but launches the packaged FORGE Electron window through XWayland by setting `FORGE_USE_XWAYLAND=1`. Intended for compatibility/testing when native Electron Wayland behavior is unsuitable. |

The current shell is also **panel-configurable**: the stock Plasma panel is removed during first-session initialization, while `forge-panel-manager [edge]` can add persistent Plasma panels when a user wants conventional clock, tray, launcher, or status widgets. This changes the desktop presentation without changing the underlying `0.2.x` Wayland session.

The production session contract exports `FORGE_OS_SESSION=1` and `FORGE_SHELL_MODE=1`. Outside that contract, FORGE behaves as the standalone application and does not expose FORGE-OS-only system surfaces.

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

After this release is installed, FORGE's **Check for updates** action recognizes `FORGE_OS_SESSION=1` and opens the authenticated FORGE-OS updater instead of installing a standalone Electron artifact. The updater pins and fast-forwards the official FORGE and FORGE-OS `main` checkouts and runs this same authoritative installer. It refuses dirty, divergent, untrusted-origin, or non-`main` repositories and never reboots automatically.

## 🖥️ Production boot path

```text
kernel + systemd
  -> greetd on VT1
  -> FORGE-branded tuigreet
  -> PAM authentication
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland + Plasma visual/panel services
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded FORGE executable>
```

The custom session starts KWin directly instead of launching a conventional Plasma desktop. Plasma supplies effects, decorations, wallpaper and optional panels underneath FORGE; FORGE remains the visible environment. XWayland exists only for legacy applications.

## 🧭 Repository guide

| Area | Purpose |
| --- | --- |
| [`config/`](config/) | greetd and system configuration templates |
| [`manifests/`](manifests/) | Arch package declarations |
| [`overlays/`](overlays/) | temporary FORGE compatibility patches |
| [`scripts/`](scripts/) | bootstrap, build, update, install, recovery, and ISO tooling |
| [`session/`](session/) | graphical session launchers and desktop entry |
| [`tests/`](tests/) | production invariant verification |
| [`docs/`](docs/) | user, architecture, recovery, security, and release guides |

## 📚 Documentation

Start with the [Documentation Hub](docs/README.md).

- 🧱 [Architecture](ARCHITECTURE.md)
- 👤 [User Manual](docs/USER_MANUAL.md)
- 🖥️ [Desktop Session](docs/DESKTOP_SESSION.md)
- 🛟 [Recovery](docs/RECOVERY.md)
- 📦 [Release Checklist](docs/RELEASE_CHECKLIST.md)
- 🔐 [Security Model](docs/SECURITY_MODEL.md)
- 🧪 [Implementation Gaps](docs/IMPLEMENTATION_GAPS.md)
- 📝 [Changelog](CHANGELOG.md)

## 🧰 Important commands

- `./scripts/install-forge-linux.sh` — authoritative physical-machine install/update flow.
- `forge-os-update` — interactive update flow used by FORGE's **Check for updates** action.
- `./scripts/build-forge.sh` — package the exact FORGE commit and generate ignored build identity metadata.
- `./scripts/install-runtime.sh` — install and activate the recorded content-addressed runtime.
- `./scripts/build-iso.sh` — produce the ArchISO image using the production session/runtime layout.
- `./tests/verify.sh` — verify boot, session, runtime, sandbox, recovery, and source/runtime identity invariants.
- `forge-app-launcher` — open Plasma's searchable application launcher inside FORGE-OS.
- `forge-panel-manager [edge]` — add a Plasma panel that can then be customized normally.
- `forge-workspace-runner` — choose and open or run a file constrained to the active FORGE workspace.
- `forge-install-program PACKAGE` — request PolicyKit authentication and install validated Arch repository package names.
- `./scripts/disable-graphical-login.sh` — return safely to console-oriented recovery mode.

## 🛟 Recovery

Press `Ctrl+Alt+F2` for the independent tty2 recovery console. See [Recovery](docs/RECOVERY.md) before changing display-manager or session configuration manually.

## 📦 Release status

The repository is structured for ISO production, but the project version remains whatever is declared in [`VERSION`](VERSION). A stable release should only be tagged after the [Release Checklist](docs/RELEASE_CHECKLIST.md) passes on the reference machine and at least one additional hardware/VM target.

## 🔀 Repository boundary

FORGE and FORGE-OS are intentionally separate repositories. Generic application features and fixes belong in FORGE; Arch integration, boot/session ownership, distribution packaging, hardware configuration, recovery, and ISO construction belong here.
