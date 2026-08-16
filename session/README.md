# Runtime and session contract

## Normal authenticated profile

The normal authenticated command is one installed path:

```text
/usr/local/bin/forge-wayland-session
```

Both the greeter F2 default and the visible F3 FORGE desktop entry use that path. The installer copies it from `session/forge-wayland-session`; historical X11/session-client entries are removed from production installation.

A compatibility dispatcher remains at `/usr/local/bin/startplasma-wayland` for old FORGE command chains and vendor Plasma calls, but it is not the normal user-visible login path.

## Ownership and process tree

Exactly one component owns KWin:

```text
greetd
  -> /usr/local/bin/tuigreet
  -> /usr/local/bin/forge-wayland-session
  -> dbus-run-session kwin_wayland --xwayland --exit-with-session
  -> /usr/local/libexec/forge-wayland-client
  -> kded6 + krunner + PolicyKit agent + plasmashell
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded executable>
```

Plasma remains the visual/service layer under FORGE rather than a second desktop owner. `forge-wayland-session` exports FORGE desktop/session identity, and `forge-wayland-client` imports Wayland, D-Bus, FORGE, and recovery flags into the user service environment.

## Login UI

FORGE-OS uses the rolling maintained NotAShelf tuigreet fork while the background feature set remains ahead of the latest tagged binary release. The required contract is validated from the installed binary itself before greetd is enabled.

- **Matrix is the default background.**
- **F2** edits the command, defaulting to `/usr/local/bin/forge-wayland-session`.
- **F3** opens the isolated FORGE Wayland session list; the FORGE entry resolves to the same installed path.
- **F4** opens live background selection, including Matrix, None, and the classic DOOM fire effect.
- **F5** opens the configured power menu.

The config remembers the last username but does not use `--remember-session`, so an old experimental command cannot persistently replace the canonical runtime. The installer also clears stale tuigreet cache files before re-enabling the login path.

## FORGE shell layout and controls

FORGE-OS reserves a dedicated strip above the ordinary FORGE application header. The normal Releases, GitHub, Settings, workspace, and window controls therefore remain unobstructed.

Applications and System remain at the left of the OS strip. Responsive quick actions launch Network, Audio, Display, Power, Applications, Storage, Appearance, Updates, Security, Recovery, and Advanced surfaces. The center strip scrolls horizontally when necessary instead of overlapping modules. Time and Session remain on the right.

Session operations use detached fixed OS helpers. Lock uses `loginctl`; logout terminates the active login session/user; restart and shutdown use non-blocking systemd actions with PolicyKit fallback. This avoids losing the Electron IPC reply when the requested operation itself terminates FORGE or its session.

## Package and service environment

Interactive `pacman` commands in the FORGE Fish profile route through `forge-install-pkg`. Program installation routes through `forge-install-program -> forge-app-install -> forge-install-pkg`. Installer internals use absolute `/usr/bin/pacman` to avoid wrapper recursion.

The bootstrap enables multilib, tracked/Reflector-managed Arch mirrors, Chaotic-AUR, `yay`, and the rolling maintained tuigreet fork. Network, audio, Bluetooth, printing, time, power, Ollama, trim, and mirror-refresh services/timers are enabled persistently as appropriate.

## Installed-system recovery

Ctrl+Alt+F2 requests the graphical recovery unit through the on-demand `autovt@tty2.service` alias. It has its own greetd socket/session and sets `FORGE_RECOVERY_MODE=1`; it is not pulled into every normal graphical boot.

If the graphical stack itself is unhealthy, use an available text console such as Ctrl+Alt+F3 and run `~/FORGE-OS/scripts/disable-graphical-login.sh` to restore console-first access without deleting FORGE runtimes or user data.

## Live ISO recovery

The ISO runs `forge-live-setup.service` before greetd. Live-media detection must succeed before the ephemeral `forge` account, live-only sudo rule, or live greeter profile is installed. The live account password remains locked; greetd enters it via `initial_session` and privileged actions use the live-only sudo policy.

The initial session sets:

```text
FORGE_LIVE_RECOVERY=1 FORGE_RECOVERY_MODE=1 /usr/local/bin/forge-wayland-session
```

FORGE then presents the dedicated full-screen recovery GUI with a privileged root shell and local ISO/ZIP installer workflow. ISO images are mounted read-only, ZIP paths are validated before extraction, and recognized installers require an explicit `INSTALL` confirmation.

## Verification

`tests/session-dispatcher.sh` covers the compatibility dispatcher without launching a compositor. `tests/greeter-contract.sh` checks the actual tuigreet CLI. `tests/source-verify.sh` checks login, top-bar, package-routing, mirror/repository, service, recovery, FORGE typecheck/lint/tests/build, and source diffs. `tests/verify.sh` checks the installed machine. GPU, suspend, portal behavior, session transitions, recovery switching, and ISO boot remain physical/VM acceptance gates.
