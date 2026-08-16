# 🧭 Architectural Decisions

This file records durable production decisions. Temporary debugging approaches belong in Git history and the changelog, not in the active architecture.

## 🖥️ Graphical login is the default

`greetd`/`tuigreet` on VT1 provides the FORGE-branded PAM-authenticated login. Acceptance gating and tty1 shell-profile startup are obsolete.

## 🧼 Graphical startup does not source shell profiles

`greetd` sets `source_profile = false`. `/etc/profile`, `~/.profile`, `.bash_profile`, `.bashrc`, and similar shell startup files are not part of the production graphical-session contract.

## 🚀 The canonical post-auth runtime path is explicit

Tuigreet is restricted to the FORGE-owned Wayland directory; its X-session discovery path is intentionally absent.

After successful PAM authentication, the repository default is:

```bash
/usr/local/bin/forge-wayland-session
```

The legacy X11 launcher and desktop entry are removed. XWayland remains only for application compatibility.

## ⚖️ Exactly one component owns the graphical session/compositor

FORGE supports both host-owned and FORGE-owned presentation profiles, but they must not accidentally compete for KWin/session lifecycle.

- **FORGE-owned profile:** `forge-wayland-session` starts and owns KWin; Plasma services run beneath FORGE.
- **Host-owned profile:** Plasma/GNOME/etc. owns the compositor/session and FORGE must launch inside that already-running environment without starting another compositor.

The current reference-machine F2 command:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

is documented as a development override, not a canonical release path, because `startplasma-wayland` and `forge-wayland-session` can both attempt KWin/session ownership. A future first-class Plasma-hosted launcher should hand off to FORGE without starting KWin twice.

See [Runtime & Session Architecture](../session/README.md).

## ⌨️ Login-screen runtime selection is a supported development/recovery tool

Pressing **F2** in `tuigreet` may select a complete alternate session command for that login. This allows compatibility testing without rebuilding the packaged FORGE runtime.

Stable ISO acceptance still requires the canonical session to launch without an override.

## 📦 Runtime releases are content-addressed

A FORGE source commit alone cannot identify an overlaid application. Release identity therefore incorporates the source commit, ordered path-independent overlay identity, and full payload identity. The build record also pins the lockfile, executable, and `app.asar` hashes.

## 🪟 Plasma augments FORGE instead of replacing it in native shell mode

KWin Wayland provides composition, effects, and decorations. `plasmashell` runs underneath FORGE for wallpaper and optional panels, but first-session initialization removes its stock panel. The canonical session avoids `startplasma-wayland`, preventing a conventional Plasma desktop from becoming the primary environment. FORGE remains the foreground shell and users opt into panels with `forge-panel-manager`.

A separately selected Plasma-hosted profile may instead keep Plasma's own shell/session surfaces authoritative.

## 🟡 Electron XWayland is a rendering fallback, not a session generation

`FORGE_USE_XWAYLAND=1` keeps KWin/session ownership on native Wayland while launching the packaged Electron FORGE window through XWayland. It exists to isolate Electron/Ozone compatibility problems without replacing the compositor architecture.

## 🎛️ Shell UI must be runtime-profile aware

Standalone FORGE, host-owned Linux desktop use, and native FORGE-OS shell mode should not expose identical OS-facing UI.

The target architecture is an explicit runtime-profile capability contract so package management, application launcher, panel, settings, power/session, and other shell-only surfaces are enabled intentionally rather than inferred solely from Linux/KDE/Wayland environment variables.

## 🏷️ Exported builds receive explicit source identity

FORGE-OS packages a `git archive` of FORGE rather than the live checkout. `FORGE_BUILD_COMMIT` is passed explicitly during packaging so FORGE cannot accidentally discover the enclosing FORGE-OS Git repository and embed the wrong commit.

## 🗃️ User state does not live in Git

Desktop/MIME rollback data and other machine-specific state belong under the user's XDG state directory, not beneath tracked repository paths.

## 🛟 Recovery remains independent

`getty@tty2.service` remains enabled and outside the graphical session. The graphical-disable script switches back to `multi-user.target` and restores tty1/tty2 console login.

## 🔄 FORGE-OS updates use the authoritative installer

Inside `FORGE_OS_SESSION=1`, FORGE's update action launches the installed `forge-os-update` helper in a visible terminal. The helper accepts no renderer-supplied repository or command, permits only clean `main` checkouts that can fast-forward to their configured `origin/main`, and delegates installation to `scripts/install-forge-linux.sh`. Standalone FORGE installations retain their existing Electron updater.

## 🔀 FORGE and FORGE-OS remain separate repositories

Generic application features and fixes belong upstream in FORGE. Boot, session, Arch integration, hardware configuration, distribution packaging, recovery, and ISO release behavior belong in FORGE-OS.

## 🔗 Related documentation

- [Runtime & Session Architecture](../session/README.md)
- [Architecture](../ARCHITECTURE.md)
- [Desktop Session](DESKTOP_SESSION.md)
- [Shell Mode](SHELL_MODE.md)
- [Release Checklist](RELEASE_CHECKLIST.md)
