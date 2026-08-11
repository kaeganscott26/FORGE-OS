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
