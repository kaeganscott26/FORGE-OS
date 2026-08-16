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
  -> tuigreet
  -> startplasma-wayland forge-wayland-session forge-wayland-client
  -> FORGE dispatcher
  -> KWin Wayland + XWayland compatibility
  -> D-Bus, KRunner, KDE services, and Plasma visuals beneath FORGE
  -> content-addressed FORGE runtime
```

The production greeter command is intentionally limited to options supported by the `greetd-tuigreet` package declared in `manifests/arch-packages.txt`. Experimental/background-animation options must not be made boot-critical unless FORGE-OS deliberately changes its packaged greeter implementation. CI enforces this contract.

Login shortcuts are F2 command, F3 session, and F5 power.

## The two normal commands

Normal installation and maintenance have exactly two repository entry points. Everything under `scripts/` is an implementation detail or an advanced/recovery tool unless a document explicitly says otherwise.

### Install or repair the current checkout

Run as the desktop user:

```bash
cd ~/FORGE-OS
./install.sh
```

`install.sh` is the authoritative install/repair entry point. It delegates to the Linux installer, which provisions required Arch packages, hardware integration, the FORGE runtime, Wayland session files, greetd, recovery components, and verification. It invokes sudo only for system mutations and never reboots automatically.

### Update FORGE + FORGE-OS and reinstall

```bash
cd ~/FORGE-OS
./update.sh
```

`update.sh` is the authoritative source-based update entry point. It verifies both `~/FORGE` and `~/FORGE-OS`, fast-forwards their trusted `main` branches, runs the installer, and restores both source checkouts to their pre-update commits if installation fails. After a successful installation the same updater is also available as `forge-os-update`.

Do not manually source `build/latest.env`, and do not run `bootstrap-forgeos.sh`, `build-forge.sh`, `install-runtime.sh`, or the package/bootstrap helpers as part of the normal update workflow. Those are internal stages used by the authoritative entry points.

The installer still supports `--skip-packages` for a machine that already satisfies the complete manifest and `--use-current-build` for a build whose version, package/lock hashes, runtime-source hash, overlays, executable, app archive, and payload still match.

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

The graphical FORGE Recovery profile currently uses its own greetd/KWin path on tty2. Its greeter command is kept to the same packaged-tuigreet compatibility contract as the production login.

For a guaranteed break-glass console when the graphical login path is unhealthy, switch to another available TTY (for example Ctrl+Alt+F3), log in, and run:

```bash
cd ~/FORGE-OS
./scripts/disable-graphical-login.sh
```

That disables graphical login, restores console services, and preserves installed runtimes and user/project data. See [Recovery](docs/RECOVERY.md) for logs and rollback details.

## Build and validate

```bash
./tests/greeter-contract.sh
./tests/source-verify.sh
./scripts/build-forge.sh ~/FORGE
./scripts/build-iso.sh
```

`tests/greeter-contract.sh` prevents the packaged greeter and configured command line from silently drifting apart. `tests/source-verify.sh` is non-mutating. `tests/verify.sh` validates an installed machine. ISO publication additionally requires boot/hardware acceptance and artifact provenance from [the release checklist](docs/RELEASE_CHECKLIST.md).

## Documentation

- [Architecture](ARCHITECTURE.md)
- [Runtime/session contract](session/README.md)
- [User manual](docs/USER_MANUAL.md)
- [Recovery](docs/RECOVERY.md)
- [Security model](docs/SECURITY_MODEL.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)
- [Changelog](CHANGELOG.md)
