# Architecture

The production boot/session chain is intentionally singular:

```text
systemd graphical.target
  -> greetd.service on VT1 (greeter account)
  -> tuigreet
  -> Linux PAM authentication
  -> /usr/local/bin/forge-xsession (authenticated user)
  -> xinit with explicit client and Xorg server paths
  -> /usr/local/libexec/forge-session-client
  -> Openbox + desktop helpers
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded FORGE executable>
```

## Login boundary

`greetd` uses `source_profile = false`; shell profiles are not part of graphical startup. `tuigreet` is restricted to `/usr/share/forge-os/xsessions` and `/usr/share/forge-os/wayland-sessions`, and `--no-xsession-wrapper` prevents its default `startx /usr/bin/env` wrapper from surrounding the repository-owned launcher. `forge-xsession` therefore owns the only X startup boundary.

VT1 belongs to greetd. `getty@tty2.service` is explicitly enabled for `Ctrl+Alt+F2` recovery. Authentication remains PAM-based and there is no autologin.

## X11/FORGE session

`forge-xsession` selects an unused local display and calls `xinit` directly with `/usr/local/libexec/forge-session-client` and `/usr/lib/Xorg`. The client establishes the FORGE/XDG environment, publishes it to D-Bus/systemd activation, starts notification/polkit helpers and Openbox, then invokes `forge-session`. FORGE runs as the authenticated normal user and receives `FORGE_OS_SESSION=1`, `FORGE_SHELL_MODE=1`, `XDG_CURRENT_DESKTOP=FORGE`, and the live X11 environment.

The default FORGE workspace is the authenticated user's home directory, so a distributable installation does not depend on a development checkout existing at `~/FORGE-OS`.

## Runtime identity

FORGE is exported from its exact Git commit before packaging. FORGE-OS passes `FORGE_BUILD_COMMIT` explicitly so the exported build cannot accidentally inherit the surrounding FORGE-OS repository's Git identity. Overlay identity is computed from ordered repository-relative patch names and contents, not absolute machine paths. Patches are dry-run and applied with zero fuzz.

Runtime releases are content-addressed by FORGE source commit, overlay identity, and payload identity. Ignored `build/latest.env` records the source commit, build date, lockfile, overlays, executable, `app.asar`, payload hashes, and relative paths. `/opt/forge/current` is switched only after the installed payload matches that record. Electron's `chrome-sandbox` is root-owned mode `4755`; permanent `--no-sandbox` is not used.

## Repository boundary

FORGE is application source. FORGE-OS owns Arch packages, session/boot configuration, OS-specific overlays, installation, verification, ISO construction, and recovery. Generic FORGE fixes should migrate upstream rather than remaining OS overlays.
