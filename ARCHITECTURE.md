# 🧱 FORGE-OS Architecture

FORGE-OS deliberately keeps the production startup path singular and auditable. Arch Linux owns the operating-system substrate; FORGE owns the visible workspace experience.

## 🚦 Boot and login chain

```text
systemd graphical.target
  -> greetd.service on VT1 (greeter account)
  -> tuigreet
  -> Linux PAM authentication
  -> /usr/bin/xinit /usr/local/libexec/forge-session-client
  -> KWin X11 + Plasma helpers (Openbox fallback)
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded FORGE executable>
```

The direct `xinit` client command is the verified post-authentication runtime path. `session/forge-xsession` remains available as a repository-owned compatibility/recovery entry point and resolves to that same command.

## 🔐 Login boundary

`greetd` uses `source_profile = false`, so graphical startup does not depend on `/etc/profile`, `~/.profile`, or shell-specific initialization.

`tuigreet` is restricted to FORGE-owned X11 and Wayland session directories and is started with `--no-xsession-wrapper`. This prevents an implicit `startx` wrapper from being injected around the FORGE session.

VT1 belongs to greetd. `getty@tty2.service` remains enabled for `Ctrl+Alt+F2` recovery. Authentication is PAM-based; production startup does not use autologin.

## 🖥️ X11 and FORGE session

After authentication, greetd/tuigreet launches:

```bash
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

`forge-session-client` validates the live X environment, establishes the FORGE/XDG session contract, publishes relevant variables to D-Bus/systemd activation, starts notification and polkit helpers, starts Plasma 6 KWin X11 with an automatic Openbox fallback, and invokes `forge-session`. Plasma supplies windowing, settings, theming, portals, and launcher services; FORGE remains the desktop shell.

FORGE runs as the authenticated normal user with values including:

- `XDG_CURRENT_DESKTOP=FORGE`
- `XDG_SESSION_DESKTOP=FORGE`
- `XDG_SESSION_TYPE=x11`
- `FORGE_OS_SESSION=1`
- `FORGE_SHELL_MODE=1`
- the live `DISPLAY`, `XAUTHORITY`, `XDG_RUNTIME_DIR`, and D-Bus environment

The initial FORGE workspace is the authenticated user's home directory. A distributed system does not require a development checkout at `~/FORGE-OS` to launch the desktop.

## 📦 Runtime identity

FORGE is exported from an exact Git commit before packaging. FORGE-OS passes build identity explicitly so the packaged application cannot accidentally inherit the surrounding FORGE-OS repository identity.

Overlay identity is derived from ordered repository-relative patch names and contents. Patches are dry-run and applied with zero fuzz.

Runtime releases are content-addressed by source and payload identity. Ignored `build/latest.env` records the source commit, build date, lockfile hash, overlay hash, executable hash, `app.asar` hash, payload hash, runtime ID, and relative paths. `/opt/forge/current` is switched only after the installed payload matches the build record.

Electron's `chrome-sandbox` remains root-owned mode `4755`; permanent `--no-sandbox` is not part of the production architecture.

## 🧭 Responsibility boundary

### Arch / FORGE-OS owns

- kernel and boot target
- systemd services
- PAM and login orchestration
- graphics/session bootstrap
- package management and system dependencies
- networking, audio, filesystem, and hardware integration
- runtime installation and verification
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
