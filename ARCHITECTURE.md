# 🧱 FORGE-OS Architecture

FORGE-OS deliberately keeps the production startup path singular and auditable. Arch Linux owns the operating-system substrate; FORGE owns the visible workspace experience.

## 🚦 Boot and login chain

```text
systemd graphical.target
  -> greetd.service on VT1 (greeter account)
  -> tuigreet
  -> Linux PAM authentication
  -> /usr/local/bin/forge-wayland-session
  -> KWin Wayland + Plasma visual/panel services
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded FORGE executable>
```

The FORGE-owned launcher starts KWin Wayland directly. It does not call `startplasma-wayland`, so the conventional Plasma desktop layout does not replace FORGE.

## 🔐 Login boundary

`greetd` uses `source_profile = false`, so graphical startup does not depend on `/etc/profile`, `~/.profile`, or shell-specific initialization.

`tuigreet` defaults to the FORGE Wayland launcher and discovers only the FORGE-owned Wayland session directory. Its X-session path points to an intentionally absent directory.

VT1 belongs to greetd. `getty@tty2.service` remains enabled for `Ctrl+Alt+F2` recovery. Authentication is PAM-based; production startup does not use autologin.

## 🖥️ Wayland and FORGE session

After authentication, greetd/tuigreet launches:

```bash
/usr/local/bin/forge-wayland-session
```

The launcher establishes the FORGE/XDG contract and starts KWin with XWayland compatibility and exit-with-session lifecycle control. The Wayland client publishes the live environment, starts KDE services and `plasmashell` beneath FORGE, removes Plasma's stock panel on first migration, and launches FORGE natively through Electron's Wayland backend. Users add optional panels with `forge-panel-manager`; subsequent Plasma panel configuration is preserved.

FORGE runs as the authenticated normal user with values including:

- `XDG_CURRENT_DESKTOP=FORGE`
- `XDG_SESSION_DESKTOP=FORGE`
- `XDG_SESSION_TYPE=wayland`
- live `WAYLAND_DISPLAY` (and `DISPLAY` only for XWayland clients)
- `FORGE_OS_SESSION=1`
- `FORGE_SHELL_MODE=1`
- the live `DISPLAY`, `XAUTHORITY`, `XDG_RUNTIME_DIR`, and D-Bus environment

The initial FORGE workspace is the authenticated user's home directory. A distributed system does not require a development checkout at `~/FORGE-OS` to launch the desktop.

## 📦 Runtime identity

FORGE is exported from an exact Git commit before packaging. FORGE-OS passes build identity explicitly so the packaged application cannot accidentally inherit the surrounding FORGE-OS repository identity.

Overlay identity is derived from ordered repository-relative patch names and contents. Patches are dry-run and applied with zero fuzz.

Runtime releases are content-addressed by source and payload identity. Ignored `build/latest.env` independently records the FORGE application version, commit, package manifest and lockfile hashes; the FORGE-OS version, commit, and overlay hash; and the executable, `app.asar`, full payload, runtime ID, build date, and relative paths. `/opt/forge/current` is switched only after the build record still matches FORGE-OS and the installed payload matches every recorded runtime hash.

Electron's `chrome-sandbox` remains root-owned mode `4755`; permanent `--no-sandbox` is not part of the production architecture.

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

- desktop/workspace UX
- explorer and file interactions
- integrated terminal and shell-mode behavior
- Git/workspace/task/browser surfaces
- application-launch UX
- workspace intelligence and agent-facing capabilities

Generic FORGE fixes should move upstream rather than living permanently as FORGE-OS overlays.

## 📚 Related documentation

- [Documentation Hub](docs/README.md)
- [Desktop Session](docs/DESKTOP_SESSION.md)
- [Security Model](docs/SECURITY_MODEL.md)
- [Recovery](docs/RECOVERY.md)
- [Release Checklist](docs/RELEASE_CHECKLIST.md)
