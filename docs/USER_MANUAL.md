# User manual

## Login

Authenticate at the FORGE matrix login. The default command is `startplasma-wayland forge-wayland-session forge-wayland-client`. F2 edits a full command for one login, F3 shows sessions, F4 changes the background animation, and F5 shows power actions.

## Desktop

Use the top bar for Applications, System, Workspace Intelligence, clock, and Session. System contains Network, Audio, Display, Power, Applications, Updates, Security, Recovery, and Advanced. The right rail remains AI chat. Applications installed with a desktop entry appear automatically after discovery refresh.

FORGE Explorer is the file manager. Open a folder/workspace, then use the tree/context menu or Ctrl/Cmd+C, Ctrl/Cmd+V, Ctrl/Cmd+N, Ctrl/Cmd+Shift+N, F2, and Delete. Text and metadata open in the editor; binaries/packages/executables show inspection details. Run and Run as administrator are separate confirmed actions.

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

The native Updates control opens `forge-os-update`. It refuses dirty, divergent, non-main, or untrusted source trees; otherwise it fast-forwards and invokes the installer. It does not reboot. Standalone FORGE packages use their normal Electron update channel.

## Recovery

Ctrl+Alt+F2 opens native FORGE Recovery. Inspect the three logs or open the diagnostic terminal. Rollback is available only when a distinct verified last-known-good runtime exists and requests authorization only for the activation/removal step.
