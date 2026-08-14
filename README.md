# ⚒️ FORGE-OS

**FORGE-OS is the Arch Linux integration and distribution layer for FORGE.** Arch provides the kernel, systemd, PAM, drivers, package management, networking, audio, filesystems, and hardware services; FORGE owns the visible desktop experience.

> The goal is simple: power on the machine, authenticate, and land directly inside FORGE without exposing a conventional Linux desktop workflow.

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

## 🖥️ Production boot path

```text
kernel + systemd
  -> greetd on VT1
  -> FORGE-branded tuigreet
  -> PAM authentication
  -> /usr/bin/xinit /usr/local/libexec/forge-session-client
  -> Plasma 6 KWin X11 + desktop helpers (Openbox fallback)
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded FORGE executable>
```

The direct `xinit` command above is the verified post-authentication runtime path. The greeter does not source shell profiles, does not use tuigreet's default `startx` wrapper, and does not depend on `.xinitrc`, tty1 profile autostart, acceptance markers, or autologin.

## 🧭 Repository guide

| Area | Purpose |
| --- | --- |
| [`config/`](config/) | greetd and system configuration templates |
| [`manifests/`](manifests/) | Arch package declarations |
| [`overlays/`](overlays/) | temporary FORGE compatibility patches |
| [`scripts/`](scripts/) | bootstrap, build, install, recovery, and ISO tooling |
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
- `./scripts/build-forge.sh` — package the exact FORGE commit and generate ignored build identity metadata.
- `./scripts/install-runtime.sh` — install and activate the recorded content-addressed runtime.
- `./scripts/build-iso.sh` — produce the ArchISO image using the production session/runtime layout.
- `./tests/verify.sh` — verify boot, session, runtime, sandbox, recovery, and source/runtime identity invariants.
- `forge-app-launcher` — open Plasma's searchable application launcher inside FORGE-OS.
- `forge-workspace-runner` — choose and open or run a file constrained to the active FORGE workspace.
- `forge-install-program PACKAGE` — request PolicyKit authentication and install validated Arch repository package names.
- `./scripts/disable-graphical-login.sh` — return safely to console-oriented recovery mode.

## 🛟 Recovery

Press `Ctrl+Alt+F2` for the independent tty2 recovery console. See [Recovery](docs/RECOVERY.md) before changing display-manager or session configuration manually.

## 📦 Release status

The repository is structured for ISO production, but the project version remains whatever is declared in [`VERSION`](VERSION). A stable release should only be tagged after the [Release Checklist](docs/RELEASE_CHECKLIST.md) passes on the reference machine and at least one additional hardware/VM target.

## 🔀 Repository boundary

FORGE and FORGE-OS are intentionally separate repositories. Generic application features and fixes belong in FORGE; Arch integration, boot/session ownership, distribution packaging, hardware configuration, recovery, and ISO construction belong here.
