# User manual

## Update and install

From the normal user account:

```bash
git -C ~/FORGE pull --ff-only
git -C ~/FORGE-OS pull --ff-only
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
```

The installer checks that both repositories are clean `main` checkouts matching `origin/main`, installs/updates declared Arch dependencies, rebuilds FORGE, installs the exact recorded runtime, installs the graphical session, verifies the complete chain, and enables graphical boot. It does not reboot automatically.

Then reboot manually:

```bash
sudo reboot
```

## Normal startup

The machine should show the FORGE-branded tuigreet login directly. Enter an ordinary Linux username and password. PAM opens the FORGE graphical session without a tty1 shell login or manual `startx`.

The production login path does not source shell profiles. Tuigreet's default X11 `startx` wrapper is disabled and its session discovery is restricted to FORGE-owned directories, so `forge-xsession` owns the single Xorg startup boundary.

FORGE provides the desktop shell, integrated terminal, workspace navigation, files, Git, tasks, browser, application launch, settings, and session actions. The default startup workspace is the user's home directory, so a FORGE-OS source checkout is not required on an eventual distributed image.

## Recovery

Press `Ctrl+Alt+F2` at any time to reach tty2. If the graphical login/session is broken, inspect `~/.local/state/forge/session.log` and `journalctl -u greetd.service -b`, or run:

```bash
cd ~/FORGE-OS
./scripts/disable-graphical-login.sh
```

That returns the machine to console-oriented `multi-user.target` with tty1 and tty2 login available. Re-run `./scripts/install-forge-linux.sh` after repairing the issue.

There is no supported acceptance file, tty1 profile autostart, `.xinitrc`, manual `startx`, or autologin setup.
