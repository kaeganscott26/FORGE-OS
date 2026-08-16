# Runtime and session contract

## Normal authenticated profile

The normal greetd profile is intentionally back on the last-good pre-Matrix behavior. After authentication, tuigreet executes:

```text
/usr/local/bin/forge-wayland-session
```

The installer copies that command from `session/forge-wayland-session`. It starts the FORGE-owned KWin Wayland session and then `/usr/local/libexec/forge-wayland-client`.

The desktop/session-selector compatibility entry still uses:

```text
startplasma-wayland forge-wayland-session forge-wayland-client
```

The installed paths remain:

- `/usr/local/bin/startplasma-wayland`
- `/usr/local/bin/forge-wayland-session`
- `/usr/local/libexec/forge-wayland-client`

`/usr/local/bin/startplasma-wayland` is a narrow FORGE dispatcher. With exactly `forge-wayland-session forge-wayland-client`, it exports `FORGE_RUNTIME_CHAIN` and executes the same installed `forge-wayland-session`. Every other invocation executes the unchanged `/usr/bin/startplasma-wayland` vendor command.

## Ownership and process tree

Exactly one component owns KWin in the normal login path:

```text
greetd
  -> packaged tuigreet
  -> /usr/local/bin/forge-wayland-session
  -> dbus-run-session kwin_wayland --xwayland --exit-with-session
  -> /usr/local/libexec/forge-wayland-client
  -> kded6 + krunner --daemon + PolicyKit agent + plasmashell --no-respawn
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded executable>
```

Plasma is the visual/service layer, not a second desktop owner. The one-time initializer removes only the stock Plasma panel; user-created Plasma panels remain configurable.

The session exports `XDG_CURRENT_DESKTOP=FORGE`, `XDG_SESSION_DESKTOP=FORGE`, `XDG_SESSION_TYPE=wayland`, `FORGE_OS_SESSION=1`, `FORGE_SHELL_MODE=1`, `FORGE_OS_VERSION`, and the live Wayland/D-Bus environment. `forge-wayland-client` imports those values plus recovery/live-recovery flags into D-Bus and the systemd user manager.

`FORGE_USE_XWAYLAND=1` changes Electron rendering only. KWin still owns a Wayland session.

## Login controls and greeter compatibility

The production greeter keeps the previous simple behavior: issue text, clock, remembered user, password asterisks, power actions, FORGE-only session discovery, and direct Wayland handoff. Persistent Matrix/background flags and remembered-session changes are intentionally excluded from the normal boot-critical profile.

`manifests/arch-packages.txt` declares Arch's `greetd-tuigreet` package. `tests/greeter-contract.sh` parses the normal, installed-recovery, and live-recovery TOML commands and compares every configured long option with the actual packaged `tuigreet --help` output. This prevents a cosmetic greeter option from taking down authentication again.

Historical Xorg/Openbox/KWin-X11 commands are not installed production profiles. Their implementation history remains in Git and the changelog.

## Standalone and host-integrated FORGE

macOS, Windows, ordinary Linux desktop, and FORGE-OS packages share the same renderer, workspace, Explorer, intelligence, agent-tool, recovery-panel, and task behavior. Linux-only shell integration is gated by `FORGE_OS_SESSION`/`FORGE_SHELL_MODE`. A normal call to the vendor Plasma launcher remains host-owned and never enters the FORGE dispatcher branch.

## Installed-system recovery profile

Ctrl+Alt+F2 requests the graphical recovery unit through the `autovt@tty2.service` alias. It has a separate greetd socket, D-Bus session, KWin compositor, log, and `FORGE_RECOVERY_MODE=1` UI. It is not pulled in by `graphical.target` during normal boot.

If the graphical greeter path is unhealthy, use an available text console such as Ctrl+Alt+F3, log in, and run `~/FORGE-OS/scripts/disable-graphical-login.sh`. That break-glass path disables graphical login, selects `multi-user.target`, and restores tty gettys while preserving FORGE runtimes and user data.

Recovery rollback re-verifies executable and `app.asar` hashes inside the privileged helper; PolicyKit is required only for pointer/removal mutation.

## Live ISO recovery profile

The ISO uses `forge-live-setup.service` before greetd. Only after live-media detection succeeds does it install the live profile and ephemeral privilege policy. The live greetd profile has an initial session:

```text
env FORGE_LIVE_RECOVERY=1 FORGE_RECOVERY_MODE=1 /usr/local/bin/forge-wayland-session
```

The same KWin/FORGE runtime therefore boots with a different application mode instead of a second compositor implementation. FORGE sees the live-recovery flags and covers the ordinary shell with its **FORGE Live Recovery** GUI. The GUI launches two live-only desktop actions:

- `forge-live-root-shell.desktop` -> `konsole --hold -e sudo -i`
- `forge-live-installer.desktop` -> local ISO/ZIP chooser -> `forge-live-install`

`forge-live-install` mounts ISO files read-only or safely extracts ZIP files, rejects archive path traversal, recognizes explicit installer entry points, and asks for the literal confirmation `INSTALL` before executing one as the ephemeral `forge` user. Passwordless sudo is written only for that live account and is never installed by `forge-live-setup` on a normal installed system.

## Verification

`tests/session-dispatcher.sh` is isolated and non-graphical. `tests/greeter-contract.sh` protects the package/CLI boundary. `tests/source-verify.sh` checks scripts, TOML, desktop entries, units, dependencies, the live recovery UI contract, FORGE tests/build, and both repository diffs. `tests/verify.sh` checks installed files, services, runtime/payload hashes, sandbox mode, package state, and recovery state. Physical GPU, focus, portals, suspend, logout, recovery switching, and ISO boot remain hardware acceptance gates.
