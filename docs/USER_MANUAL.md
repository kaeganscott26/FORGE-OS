# User manual

Run `./scripts/install-forge-os.sh` from `~/FORGE-OS`, then reboot manually. Normal startup shows the FORGE-branded tuigreet login. Enter an ordinary Linux username and password; PAM opens the FORGE graphical session directly.

FORGE provides the desktop shell, integrated terminal, workspace navigation, files, Git, tasks, browser, application launch, settings, and session actions. The integrated terminal inherits the active X11, D-Bus, XDG, and FORGE-OS session contract automatically.

There is no supported tty1/profile autostart, manual `startx`, `.xinitrc`, acceptance file, or autologin setup. For a failure, press `Ctrl+Alt+F2` and follow [Recovery](RECOVERY.md).
