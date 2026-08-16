# User manual

## Login

Authenticate at the FORGE login. The default authenticated command is `startplasma-wayland forge-wayland-session forge-wayland-client`. F2 edits a full command for one login, F3 shows sessions, and F5 shows power actions.

The production greeter intentionally uses the stock `greetd-tuigreet` feature set declared by the Arch package manifest. Experimental Matrix/DOOM backgrounds are not boot-critical features unless FORGE-OS deliberately packages and validates an enhanced greeter implementation.

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

for a trusted fast-forward update of both FORGE and FORGE-OS followed by installation. Do not manually source `build/latest.env` or run bootstrap/build/runtime helper scripts during a normal update.

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

## Recovery

Ctrl+Alt+F2 requests the native FORGE Recovery profile on demand. If that graphical path is itself unhealthy, use another text TTY such as Ctrl+Alt+F3 and run `~/FORGE-OS/scripts/disable-graphical-login.sh` to restore console-first boot without deleting runtimes or user data.
