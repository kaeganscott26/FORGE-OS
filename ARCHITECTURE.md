# Architecture

The production chain is:

```text
systemd graphical.target
  → greetd.service on VT1 (greeter account)
  → tuigreet
  → Linux PAM authentication
  → /usr/local/bin/forge-xsession (authenticated user)
  → xinit with explicit client and Xorg server paths
  → /usr/local/libexec/forge-session-client
  → Openbox, desktop helpers, and /usr/local/bin/forge-session
  → /opt/forge/current/forge
```

`forge-xsession` invokes `xinit` directly; it never calls `startx` or reads a user `.xinitrc`. Openbox is recoverable window-management plumbing. FORGE detects `FORGE_OS_SESSION=1` and `FORGE_SHELL_MODE=1`, maximizes its primary window, and owns the visible environment.

Runtime releases are content-addressed by FORGE commit, ordered overlay hash, and payload hash. The ignored local `build/latest.env` records portable relative paths plus source, lockfile, overlays, executable, `app.asar`, and full payload identities. `/opt/forge/current` is switched only after the installed payload matches that record. Electron's `chrome-sandbox` is installed root-owned and mode `4755`; `--no-sandbox` is not used.

VT1 belongs to greetd. `getty@tty2.service` is explicitly enabled for `Ctrl+Alt+F2` recovery. Authentication remains PAM-based and there is no autologin.

The repositories stay separate: FORGE is application source; FORGE-OS owns build overlays, Arch packages, boot/session integration, installation, verification, ISO construction, and recovery.
