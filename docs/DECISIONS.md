# 🧭 Architectural Decisions

This file records durable production decisions. Temporary debugging approaches belong in Git history and the changelog, not in the active architecture.

## 🖥️ Graphical login is the default

`greetd`/`tuigreet` on VT1 provides the FORGE-branded PAM-authenticated login. Acceptance gating and tty1 shell-profile startup are obsolete.

## 🧼 Graphical startup does not source shell profiles

`greetd` sets `source_profile = false`. `/etc/profile`, `~/.profile`, `.bash_profile`, `.bashrc`, and similar shell startup files are not part of the production graphical-session contract.

## 🚀 The post-auth runtime path is explicit

Tuigreet is restricted to the FORGE-owned Wayland directory; its X-session discovery path is intentionally absent.

After successful PAM authentication, the production command is:

```bash
/usr/local/bin/forge-wayland-session
```

The legacy X11 launcher and desktop entry are removed. XWayland remains only for application compatibility.

## 📦 Runtime releases are content-addressed

A FORGE source commit alone cannot identify an overlaid application. Release identity therefore incorporates the source commit, ordered path-independent overlay identity, and full payload identity. The build record also pins the lockfile, executable, and `app.asar` hashes.

## 🪟 Plasma augments FORGE instead of replacing it

KWin Wayland provides composition, effects, and decorations. `plasmashell` runs underneath FORGE for wallpaper and optional panels, but first-session initialization removes its stock panel. The session deliberately avoids `startplasma-wayland`, preventing a conventional Plasma desktop from becoming the primary environment. FORGE remains the foreground shell and users opt into panels with `forge-panel-manager`.

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

See the [Architecture](../ARCHITECTURE.md), [Desktop Session](DESKTOP_SESSION.md), and [Release Checklist](RELEASE_CHECKLIST.md).
