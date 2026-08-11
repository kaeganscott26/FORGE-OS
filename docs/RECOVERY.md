# Recovery

FORGE is a user environment above Arch, not a replacement for the console.
Use `Ctrl+Alt+F2` (or another enabled virtual terminal), log in as
`North3rnLight3r`, and inspect:

```sh
systemctl --failed
ps -ef | grep -E 'Xorg|openbox|forge' | grep -v grep
tail -n 200 ~/.local/state/forge/session.log
git -C ~/FORGE status
git -C ~/FORGE-OS status
```

Stop an active X session from a recovery TTY with `pkill -TERM -u "$USER" Xorg`.
Remove the tracked launcher with `~/FORGE-OS/scripts/rollback-session.sh`.
That rollback preserves packaged releases and workspace data.

No login autostart is enabled at the current checkpoint. If enabled after
manual acceptance, run `~/FORGE-OS/scripts/disable-autostart.sh` from a recovery
TTY. A one-user opt-out is also available with
`mkdir -p ~/.config/forge && touch ~/.config/forge/disable-autostart`.

If greetd is later enabled, switch to `Ctrl+Alt+F2`, log in, and run:

```sh
sudo systemctl disable --now greetd.service
~/FORGE-OS/scripts/rollback-graphical-login.sh
```

The rollback removes only the tracked greetd/FORGE session integration. It
preserves `~/.xinitrc`, `/opt/forge`, workspace data, and console gettys.

## Login returns immediately to tuigreet

A successful password followed by an immediate login-screen return means the
selected session command exited. Check the greetd journal and validate that the
installed launcher is both syntactically valid and current:

```sh
journalctl -u greetd.service -b --no-pager -n 100
bash -n /usr/local/bin/forge-xsession
cmp ~/FORGE-OS/session/forge-xsession /usr/local/bin/forge-xsession
```

If the syntax or comparison check fails, reinstall the tracked session files:

```sh
cd ~/FORGE-OS
./scripts/install-session.sh
./scripts/install-graphical-login.sh
sudo systemctl restart greetd.service
```

The restart ends the current greeter, so run it from a recovery TTY. If login
still fails, inspect `~/.local/state/forge/session.log` and keep greetd disabled
while testing the preserved `startx` path.

If the user MIME/default-application configuration needs reverting, run
`~/FORGE-OS/scripts/rollback-user-desktop.sh`. It restores the backup created by
`configure-user-desktop.sh`; it does not guess when no backup exists.
