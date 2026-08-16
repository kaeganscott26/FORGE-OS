# FORGE Recovery

Press Ctrl+Alt+F2. systemd-logind activates `autovt@tty2.service`, an alias for the native `forge-recovery.service`. Recovery is not a text getty and is not started at boot: it creates a separate greetd socket, D-Bus session, KWin Wayland compositor, PolicyKit agent, recovery log, and full-screen FORGE Recovery UI when tty2 is requested.

Diagnostics are available without credentials. The recovery terminal runs as the desktop user. Reading logs, reloading the interface, and inspecting runtime identities do not elevate. A rollback requests PolicyKit only when it changes `/opt/forge`.

Available logs include:

- FORGE application log;
- normal FORGE-OS session log at `~/.local/state/forge/session.log`;
- recovery log at `~/.local/state/forge/recovery.log`.

Rollback verifies the recorded executable and `resources/app.asar` both before and inside the privileged helper, atomically switches `/opt/forge/current`, keeps last-known-good pointing at the verified target, and deletes only the superseded directory beneath `/opt/forge/releases`. It never deletes home directories, projects, `.forge/metadata.sqlite`, workspace memory, or task state.

Repeat installs preserve the existing last-known-good target. A later verified update recreates a new current runtime without colliding with the rolled-back build. After packaging, `tests/runtime-lifecycle.sh` exercises isolated install, repeat install, corrupt-runtime replacement, rollback, cleanup, and update-after-rollback behavior.

If the graphical recovery compositor itself cannot start, use another console/SSH path and inspect:

```bash
systemctl status greetd.service forge-recovery.service
journalctl -u greetd.service -u forge-recovery.service -b --no-pager -n 300
tail -n 300 ~/.local/state/forge/session.log ~/.local/state/forge/recovery.log
cd ~/FORGE-OS && ./tests/verify.sh
```

`scripts/disable-graphical-login.sh` remains the break-glass operation that disables graphical login and restores console services without removing runtimes or user data.
