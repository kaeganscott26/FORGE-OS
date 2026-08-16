# FORGE-OS

FORGE-OS is the Arch-based integration layer that makes FORGE the visible workspace, desktop, Explorer, settings, recovery, and update experience. Arch, systemd, KWin, Plasma services, NetworkManager, PipeWire, PolicyKit, and native package databases remain the operating-system substrate; they do not become the primary UI.

Current stable candidate: `0.2.2`. Publication remains gated by [release acceptance](docs/RELEASE_CHECKLIST.md).

## Canonical login command

The greetd/tuigreet default and the F2 command profile are exactly:

```text
startplasma-wayland forge-wayland-session forge-wayland-client
```

Keep those three command names and their order unchanged. FORGE-OS installs a dispatcher at `/usr/local/bin/startplasma-wayland`; it recognizes only the two trailing FORGE names, records the chain identity, and enters `/usr/local/bin/forge-wayland-session`. Every other invocation falls through to the unchanged vendor `/usr/bin/startplasma-wayland`.

This produces one compositor owner:

```text
greetd on tty1
  -> startplasma-wayland forge-wayland-session forge-wayland-client
  -> FORGE dispatcher
  -> KWin Wayland + XWayland compatibility
  -> D-Bus, KRunner, KDE services, and Plasma visuals beneath FORGE
  -> content-addressed FORGE runtime
```

Login shortcuts are F2 command, F3 session, F4 persistent background selection, and F5 power. Matrix is the default animation.

## Install on an Arch development/reference system

Keep clean, trusted `main` checkouts at `~/FORGE` and `~/FORGE-OS`, then run as the desktop user:

```bash
cd ~/FORGE-OS
./scripts/install-forge-linux.sh
```

The installer invokes sudo or PolicyKit only for system mutations. It does not reboot. `--skip-packages` is for a machine that already satisfies the complete manifest; `--use-current-build` accepts a build only when its version, package/lock hashes, runtime-source hash, overlays, executable, app archive, and payload still match.

## Package commands

The user-facing commands retain familiar pacman operations while keeping the native databases and default installation paths:

```bash
forge-app-install -S steam
forge-install-pkg -S npm
forge-install-pkg -Syu
forge-install-pkg -Ss package-name
forge-install-pkg -Rns package-name
```

Arch is the host backend. Apt/Ubuntu and Kali run only in rootless Distrobox/Podman containers; Nix uses its own profile/store. They are initialized with `forge-workspace-bootstrap apt|kali|nix|all` and selected with `--backend`. Kali/Debian repositories are never mixed into pacman.

`forge-refresh-mirrors --country COUNTRY` ranks current HTTPS Arch mirrors; `--tracked` installs the reviewed repository list. The active mirror list is never replaced merely because an installer ran.

## Desktop behavior

- Fish is the login shell and uses the repository Dr460nized-inspired Fish/Starship palette.
- FORGE Explorer is the default directory/file workflow; Dolphin is not the primary shell UI.
- The native top bar owns Applications, System, Workspace Intelligence, clock, and Session.
- Native system surfaces cover Network, Audio, Display, Power, Applications, Updates, Security, Recovery, and Advanced state. Fixed backend actions are exposed for networking, audio, power, applications, and updates.
- Workspace source/memory indexing starts when a workspace opens and refreshes automatically on filesystem changes without prompting the model.
- KWin provides focus, placement, blur, contrast, translucency, and animation under the FORGE shell.

## Recovery

Press Ctrl+Alt+F2. systemd-logind starts the on-demand `autovt@tty2` alias, which opens a separate greetd, D-Bus, KWin, and full-screen native FORGE Recovery environment. Entering diagnostics does not require credentials. Logs and the user-owned diagnostic terminal are read-only/user-scoped; verified runtime rollback crosses PolicyKit, atomically activates last-known-good, removes only the superseded immutable runtime, and preserves home, projects, `.forge` memory, and task state.

## Build and validate

```bash
./tests/source-verify.sh
./scripts/build-forge.sh ~/FORGE
./scripts/build-iso.sh
```

`tests/source-verify.sh` is non-mutating. `tests/verify.sh` validates an installed machine. ISO publication additionally requires boot/hardware acceptance and artifact provenance from [the release checklist](docs/RELEASE_CHECKLIST.md).

## Documentation

- [Architecture](ARCHITECTURE.md)
- [Runtime/session contract](session/README.md)
- [User manual](docs/USER_MANUAL.md)
- [Recovery](docs/RECOVERY.md)
- [Security model](docs/SECURITY_MODEL.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)
- [Changelog](CHANGELOG.md)
