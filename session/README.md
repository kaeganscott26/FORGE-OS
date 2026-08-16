# Runtime and session contract

## Stable FORGE-owned profile

The canonical authenticated session command is exactly:

```text
startplasma-wayland forge-wayland-session forge-wayland-client
```

The command names and their order are a public FORGE-OS contract. The installed paths remain:

- `/usr/local/bin/startplasma-wayland`
- `/usr/local/bin/forge-wayland-session`
- `/usr/local/libexec/forge-wayland-client`

The first path is a narrow FORGE dispatcher. With exactly `forge-wayland-session forge-wayland-client`, it exports `FORGE_RUNTIME_CHAIN` and executes the FORGE-owned session. With any other arguments it executes the unchanged `/usr/bin/startplasma-wayland` vendor command. The dispatcher test proves both branches without launching a compositor.

## Ownership and process tree

Exactly one component owns KWin:

```text
greetd
  -> packaged tuigreet
  -> FORGE startplasma-wayland dispatcher
  -> forge-wayland-session
  -> dbus-run-session kwin_wayland --xwayland --exit-with-session
  -> forge-wayland-client
  -> kded6 + krunner --daemon + PolicyKit agent + plasmashell --no-respawn
  -> forge-session
  -> /opt/forge/current/<recorded executable>
```

Plasma is the visual/service layer, not a second desktop owner. The one-time initializer removes only the stock Plasma panel; user-created Plasma panels remain configurable.

The session exports `XDG_CURRENT_DESKTOP=FORGE`, `XDG_SESSION_DESKTOP=FORGE`, `XDG_SESSION_TYPE=wayland`, `FORGE_OS_SESSION=1`, `FORGE_SHELL_MODE=1`, `FORGE_OS_VERSION`, and the live Wayland/D-Bus environment. `forge-wayland-client` imports that environment into D-Bus and the systemd user manager and starts KRunner on every profile.

`FORGE_USE_XWAYLAND=1` changes Electron rendering only. KWin still owns a Wayland session.

## Login controls and greeter compatibility

- F2 selects or edits the full command for one login. The default remains the exact canonical string above.
- F3 selects the isolated FORGE Wayland desktop entry.
- F5 opens shutdown/restart controls.

`manifests/arch-packages.txt` currently declares Arch's `greetd-tuigreet` package. Production and recovery greetd configuration must therefore use only options supported by that packaged implementation. Matrix/DOOM background animation options belong to a separate maintained tuigreet fork and are not allowed in the boot-critical static configuration unless FORGE-OS deliberately changes and validates its packaged greeter. `tests/greeter-contract.sh` enforces that boundary.

Historical Xorg/Openbox/KWin-X11 commands are not installed production profiles. Their implementation history remains in Git and the changelog.

## Standalone and host-integrated FORGE

macOS, Windows, ordinary Linux desktop, and FORGE-OS packages share the same renderer, workspace, Explorer, intelligence, agent-tool, recovery-panel, and task behavior. Linux-only shell integration is gated by `FORGE_OS_SESSION`/`FORGE_SHELL_MODE`. A normal call to the vendor Plasma launcher remains host-owned and never enters the FORGE dispatcher branch.

## Recovery profile

The current graphical recovery profile has a separate greetd socket, D-Bus session, KWin compositor, log, and `FORGE_RECOVERY_MODE=1` UI on tty2. Its tuigreet configuration follows the same packaged-greeter compatibility rule as the normal login.

If the graphical greeter path is unhealthy, recovery must not depend on repeatedly retrying the same broken command. Use an available text console such as Ctrl+Alt+F3, log in, and run `~/FORGE-OS/scripts/disable-graphical-login.sh`. That break-glass path disables greetd/recovery services, selects `multi-user.target`, and restores tty1/tty2 gettys while preserving FORGE runtimes and user data.

Recovery rollback re-verifies executable and `app.asar` hashes inside the privileged helper; PolicyKit is required only for pointer/removal mutation.

## Verification

`tests/session-dispatcher.sh` is isolated and non-graphical. `tests/greeter-contract.sh` protects the package/CLI boundary that can otherwise make greetd restart a failed greeter indefinitely. `tests/source-verify.sh` checks scripts, TOML, desktop entries, units, dependencies, FORGE tests/build, and both repository diffs. `tests/verify.sh` checks installed files, services, runtime/payload hashes, sandbox mode, package state, and recovery state. Physical GPU, focus, portals, suspend, logout, recovery switching, and ISO boot remain hardware acceptance gates.
