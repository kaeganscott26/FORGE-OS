# FORGE Recovery

FORGE-OS keeps recovery separate from the normal tty1 login path. `forge-recovery.service` is installed as the `autovt@tty2.service` alias, so Ctrl+Alt+F2 requests the recovery environment on demand instead of starting a second recovery greeter at every graphical boot.

The recovery path creates its own greetd socket, D-Bus session, KWin Wayland compositor, PolicyKit agent, recovery log, and full-screen FORGE Recovery UI. Its tuigreet command follows the same package-compatibility contract as the production greeter: boot-critical configuration may only use options provided by the `greetd-tuigreet` package declared in `manifests/arch-packages.txt`.

Diagnostics are available without credentials. The recovery terminal runs as the desktop user. Reading logs, reloading the interface, and inspecting runtime identities do not elevate. A rollback requests PolicyKit only when it changes `/opt/forge`.

Available logs include:

- FORGE application log;
- normal FORGE-OS session log at `~/.local/state/forge/session.log`;
- recovery log at `~/.local/state/forge/recovery.log`.

Rollback verifies the recorded executable and `resources/app.asar` both before and inside the privileged helper, atomically switches `/opt/forge/current`, keeps last-known-good pointing at the verified target, and deletes only the superseded directory beneath `/opt/forge/releases`. It never deletes home directories, projects, `.forge/metadata.sqlite`, workspace memory, or task state.

Repeat installs preserve the existing last-known-good target. A later verified update recreates a new current runtime without colliding with the rolled-back build. After packaging, `tests/runtime-lifecycle.sh` exercises isolated install, repeat install, corrupt-runtime replacement, rollback, cleanup, and update-after-rollback behavior.

## Break-glass console

Graphical recovery is useful only if its own graphical dependencies are healthy. If greetd, tuigreet, KWin, or the recovery UI is failing, switch to another available text console such as Ctrl+Alt+F3 and log in normally. Then run:

```bash
cd ~/FORGE-OS
./scripts/disable-graphical-login.sh
```

That operation disables normal and recovery graphical login, selects `multi-user.target`, restores tty1 and tty2 gettys, and preserves runtimes and user/project data.

To inspect the failure before disabling graphical login:

```bash
systemctl status greetd.service forge-recovery.service
journalctl -u greetd.service -u forge-recovery.service -b --no-pager -n 300
tail -n 300 ~/.local/state/forge/session.log ~/.local/state/forge/recovery.log
cd ~/FORGE-OS && ./tests/verify.sh
```
