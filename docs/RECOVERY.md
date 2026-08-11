# Recovery

`Ctrl+Alt+F2` opens the explicitly enabled tty2 getty. Authenticate normally. This path remains independent of greetd, Xorg, Openbox, and FORGE.

Inspect the graphical chain:

```bash
systemctl status greetd.service
journalctl -u greetd.service -b --no-pager -n 200
tail -n 200 ~/.local/state/forge/session.log
~/FORGE-OS/tests/verify.sh
```

For X-specific failures, also inspect:

```bash
ls -lt ~/.local/share/xorg/
grep -E '\(EE\)|Fatal|fatal|ERROR|Error|failed|Failed' ~/.local/share/xorg/Xorg.*.log 2>/dev/null
```

Disable graphical login without removing the installed runtime or user data:

```bash
cd ~/FORGE-OS
./scripts/disable-graphical-login.sh
```

That operation disables greetd, sets `multi-user.target`, and enables console login on tty1 and tty2. It does not reboot.

After repair, update both repositories and reinstall the complete graphical chain:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
```

Never disable `getty@tty2.service`; it is the supported escape hatch.
