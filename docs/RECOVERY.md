# Recovery

`Ctrl+Alt+F2` opens the explicitly enabled tty2 getty. Authenticate normally. This path remains available even when greetd, Xorg, Openbox, or FORGE fails.

Inspect the chain:

```bash
systemctl status greetd.service
journalctl -u greetd.service -b --no-pager -n 200
tail -n 200 ~/.local/state/forge/session.log
~/FORGE-OS/tests/verify.sh
```

Disable graphical login without removing data or recovery access:

```bash
cd ~/FORGE-OS
./scripts/disable-graphical-login.sh
```

After repair, reinstall and re-enable the complete chain with `./scripts/install-forge-os.sh`. Neither operation reboots. Never disable `getty@tty2.service`; it is the supported escape hatch.
