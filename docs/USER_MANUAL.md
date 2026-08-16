# User manual

## Login

Authenticate at the normal FORGE login. The production greetd profile uses the restored pre-Matrix behavior and hands directly to:

```text
/usr/local/bin/forge-wayland-session
```

The installer copies that command from the repository session implementation. Persistent Matrix/background configuration is not part of the normal boot path. The FORGE desktop entry remains available as a compatibility/session-selector profile and reaches the same Wayland session.

The login command is validated against the actual `greetd-tuigreet` package installed by the Arch manifest. FORGE-OS does not add undocumented greeter options to the boot path.

## Desktop

Use the top bar for Applications, System, Workspace Intelligence, clock, and Session. System contains Network, Audio, Display, Power, Applications, Updates, Security, Recovery, and Advanced. The right rail remains AI chat. Applications installed with a desktop entry appear automatically after discovery refresh.

FORGE Explorer is the file manager. Open a folder/workspace, then use the tree/context menu or Ctrl/Cmd+C, Ctrl/Cmd+V, Ctrl/Cmd+N, Ctrl/Cmd+Shift+N, F2, and Delete. Text and metadata open in the editor; binaries/packages/executables show inspection details. Run and Run as administrator are separate confirmed actions.

## Install and update

Normal repository maintenance uses two commands only:

```bash
cd ~/FORGE-OS
./install.sh
```

for an install/repair of the current checkout, and:

```bash
cd ~/FORGE-OS
./update.sh
```

for a trusted fast-forward update of both FORGE and FORGE-OS followed by installation. The bootstrap/build/runtime scripts remain part of the repository because `install-forge-linux.sh` executes them as internal stages; they are not separate commands you need to run during a normal install or update.

## Packages

```bash
forge-app-install -S steam
forge-install-pkg -S npm
forge-install-pkg -Syu
forge-install-pkg -Ss browser
forge-install-pkg -Si package
forge-install-pkg -Rns package
```

Initialize compatibility backends once:

```bash
forge-workspace-bootstrap apt
forge-workspace-bootstrap kali
forge-workspace-bootstrap nix
forge-install-pkg --backend kali -S tool-name
forge-install-pkg --backend nix -S package-name
```

Refresh Arch mirrors explicitly with `forge-refresh-mirrors --country 'United States'` or install the tracked list with `forge-refresh-mirrors --tracked`.

## Updates

The native Updates control opens the installed `forge-os-update` command. It refuses dirty, divergent, non-main, or untrusted source trees; otherwise it fast-forwards and invokes the installer. It does not reboot. Standalone FORGE packages use their normal Electron update channel.

## Installed-system recovery

Ctrl+Alt+F2 requests native FORGE Recovery on demand. If that graphical path is itself unhealthy, use another text TTY such as Ctrl+Alt+F3 and run `~/FORGE-OS/scripts/disable-graphical-login.sh` to restore console-first boot without deleting runtimes or user data.

## Live ISO recovery

The FORGE-OS ISO automatically enters **FORGE Live Recovery** through the same Wayland runtime with live-only recovery flags. The recovery screen provides:

- **Open sudo root shell** — opens Konsole as an explicitly privileged shell for the ephemeral live environment.
- **Load / install ISO or ZIP** — selects a local `.iso` or `.zip`, validates/stages it, and runs only a recognized installer entry point after a second `INSTALL` confirmation.
- **Restart** and **Shut down** actions.

Passwordless sudo is granted only to the ephemeral `forge` live account. If `forge-live-setup` runs on an installed system, it exits without creating that account, sudo rule, or live greeter profile.
