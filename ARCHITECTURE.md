# 🧱 FORGE-OS Architecture

FORGE-OS deliberately separates the **FORGE workspace/runtime** from the **Linux graphical session that hosts it**. Arch Linux owns the operating-system substrate; FORGE owns the visible workspace experience when running in FORGE-OS shell mode.

## 🧭 Session ownership model

FORGE can participate in more than one presentation profile, but the architecture follows one non-negotiable rule:

> **Exactly one top-level component owns the graphical session and compositor.**

Two session families are supported conceptually:

- **Host-owned** — an existing desktop such as Plasma owns KWin/session lifecycle and FORGE runs inside it.
- **FORGE-owned** — the FORGE session launcher starts KWin itself and FORGE becomes the OS UX/shell.

The same installed FORGE runtime may be used by either family. The surrounding session changes; the workspace/runtime identity does not.

See [`session/README.md`](session/README.md) for the complete runtime/session matrix, login-screen commands, compatibility ladder, and UI expectations.

## 🚦 Canonical boot and login chain

The repository-owned `0.2.x` production path is FORGE-owned:

```text
systemd graphical.target
  -> greetd.service on VT1 (greeter account)
  -> tuigreet
  -> Linux PAM authentication
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland (+ XWayland compatibility)
  -> /usr/local/libexec/forge-wayland-client
  -> KDE support services + plasmashell beneath FORGE
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded FORGE executable>
```

The FORGE-owned launcher starts KWin Wayland directly. It does not require `startplasma-wayland`; this keeps the canonical ISO path from installing a conventional Plasma session above FORGE.

## 🔵 Plasma-hosted development profile

The reference machine has also used the manual `tuigreet` F2 override:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

This is a **host-owned/development configuration**, not the canonical release chain. Because `startplasma-wayland` normally establishes Plasma/KWin ownership while `forge-wayland-session` also starts KWin, the nested command must not be treated as equivalent to the direct FORGE-owned session.

Until that profile receives a dedicated handoff launcher that starts FORGE *inside* an already-owned Plasma session, it remains a useful reference-machine compatibility experiment with a known duplicate-ownership risk.

## 🔐 Login boundary

`greetd` uses `source_profile = false`, so graphical startup does not depend on `/etc/profile`, `~/.profile`, or shell-specific initialization.

`tuigreet` defaults to the FORGE Wayland launcher and discovers only the FORGE-owned Wayland session directory. Its X-session path points to an intentionally absent directory.

VT1 belongs to greetd. `getty@tty2.service` remains enabled for `Ctrl+Alt+F2` recovery. Authentication is PAM-based; production startup does not use autologin.

At the greeter, **F2** may be used for manual session-command selection during development, compatibility testing, or recovery. Stable-release validation still requires the canonical default to boot without an override.

## 🖥️ Wayland and FORGE session

After authentication, the canonical path launches:

```bash
/usr/local/bin/forge-wayland-session
```

The launcher establishes the FORGE/XDG contract and starts KWin with XWayland compatibility and `--exit-with-session` lifecycle control. The Wayland client publishes the live environment, starts KDE services and `plasmashell` beneath FORGE, removes Plasma's stock panel on first migration, and launches FORGE through Electron's native Wayland backend.

FORGE runs as the authenticated normal user with values including:

- `XDG_CURRENT_DESKTOP=FORGE`
- `XDG_SESSION_DESKTOP=FORGE`
- `XDG_SESSION_TYPE=wayland`
- live `WAYLAND_DISPLAY`
- `DISPLAY` only where XWayland compatibility provides it
- `FORGE_OS_SESSION=1`
- `FORGE_SHELL_MODE=1`
- `FORGE_OS_VERSION`
- `XDG_RUNTIME_DIR` and the live D-Bus activation environment

The initial FORGE workspace is the authenticated user's home directory. A distributed system does not require a development checkout at `~/FORGE-OS` to launch the desktop.

## 🟡 Electron XWayland compatibility

The FORGE-owned desktop can remain native Wayland while the packaged Electron window uses XWayland by setting:

```bash
FORGE_USE_XWAYLAND=1
```

This changes Electron/Ozone rendering only; it does not change KWin/session ownership.

## 📦 Runtime identity

FORGE is exported from an exact Git commit before packaging. FORGE-OS passes build identity explicitly so the packaged application cannot accidentally inherit the surrounding FORGE-OS repository identity.

Overlay identity is derived from ordered repository-relative patch names and contents. Patches are dry-run and applied with zero fuzz.

Runtime releases are content-addressed by source and payload identity. Ignored `build/latest.env` independently records the FORGE application version, commit, package manifest and lockfile hashes; the FORGE-OS version, commit, and overlay hash; and the executable, `app.asar`, full payload, runtime ID, build date, and relative paths. `/opt/forge/current` is switched only after the build record still matches FORGE-OS and the installed payload matches every recorded runtime hash.

Electron's `chrome-sandbox` remains root-owned mode `4755`; permanent `--no-sandbox` is not part of the production architecture.

## 🎛️ Runtime-aware UI boundary

OS-facing FORGE UI should follow session capabilities rather than merely detecting Linux/KDE/Wayland:

- **Standalone app:** no FORGE-OS-only launcher, package, panel, power, or system-management surfaces.
- **Plasma-hosted FORGE:** desktop/session ownership remains with Plasma; FORGE system surfaces are optional/delegated and must not duplicate host controls.
- **Native FORGE-OS shell:** FORGE owns the visible launcher/system/workspace UX while KDE/Plasma remains infrastructure underneath.

The long-term implementation direction is an explicit runtime-profile capability contract rather than inferring all behavior from environment variables alone.

## 🔄 Integrated update path

In a FORGE-OS session, FORGE's **Check for updates** action launches `/usr/local/bin/forge-os-update` in Konsole. That normal-user helper verifies both source checkouts are clean and on `main`, fetches the configured trusted origins, rejects divergence, performs fast-forward-only pulls, and invokes `scripts/install-forge-linux.sh`. The installer retains authority over dependency installation, runtime rebuilding, identity verification, session-file installation, and final verification. Standalone FORGE builds continue to use the normal Electron release updater.

Updates remain visible and authenticated; the helper does not accept repository URLs or commands from the renderer and does not reboot the machine.

## 🧭 Responsibility boundary

### Arch / FORGE-OS owns

- kernel and boot target
- systemd services
- PAM and login orchestration
- graphics/session bootstrap
- package management and system dependencies
- networking, audio, filesystem, and hardware integration
- runtime installation and verification
- integrated FORGE-OS update orchestration
- recovery paths
- ISO construction and release validation

### FORGE owns

- desktop/workspace UX in shell mode
- explorer and file interactions
- integrated terminal and shell-mode behavior
- Git/workspace/task/browser surfaces
- application-launch UX
- workspace intelligence and agent-facing capabilities

Generic FORGE fixes should move upstream rather than living permanently as FORGE-OS overlays.

## 📚 Related documentation

- [Runtime & Session Architecture](session/README.md)
- [Documentation Hub](docs/README.md)
- [Desktop Session](docs/DESKTOP_SESSION.md)
- [Shell Mode](docs/SHELL_MODE.md)
- [Security Model](docs/SECURITY_MODEL.md)
- [Recovery](docs/RECOVERY.md)
- [Release Checklist](docs/RELEASE_CHECKLIST.md)
