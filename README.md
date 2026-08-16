# FORGE-OS

FORGE-OS is the Arch-based integration layer that makes FORGE the visible workspace, desktop, Explorer, settings, recovery, and update experience. Arch, systemd, KWin, Plasma services, NetworkManager, PipeWire, PolicyKit, and native package databases remain the operating-system substrate; they do not become the primary UI.

Current stable candidate: `0.2.2`. Publication remains gated by [release acceptance](docs/RELEASE_CHECKLIST.md).

## Login contract

The normal greetd/tuigreet profile has been restored to the last-good pre-Matrix behavior. After authentication, tuigreet hands directly to the installed FORGE Wayland session:

```text
/usr/local/bin/forge-wayland-session
```

That installed file is copied from `session/forge-wayland-session` by the authoritative installer. The normal boot path is therefore:

```text
greetd on tty1
  -> tuigreet
  -> /usr/local/bin/forge-wayland-session
  -> one KWin Wayland compositor + XWayland compatibility
  -> /usr/local/libexec/forge-wayland-client
  -> D-Bus, KRunner, KDE services, PolicyKit, and Plasma visuals beneath FORGE
  -> /usr/local/bin/forge-session
  -> content-addressed FORGE runtime
```

The login screen intentionally does **not** force a persistent Matrix/background mode. The greeter keeps the previous `--issue`, time, remembered user, password asterisks, power controls, isolated FORGE session directory, and direct Wayland handoff. `tests/greeter-contract.sh` executes the installed `tuigreet --help` contract so a future cosmetic change cannot silently introduce unsupported boot-critical options.

The FORGE desktop entry still retains `startplasma-wayland forge-wayland-session forge-wayland-client` as a compatibility/session-selector profile. `/usr/local/bin/startplasma-wayland` recognizes that exact profile and dispatches into the same installed `forge-wayland-session`; non-FORGE invocations continue to the vendor `/usr/bin/startplasma-wayland`.

## The two normal commands

Normal installation and maintenance have exactly two repository entry points. The underlying bootstrap, build, runtime, and configuration scripts are intentionally retained because the installer executes them as explicit stages.

### Install or repair the current checkout

Run as the desktop user:

```bash
cd ~/FORGE-OS
./install.sh
```

`install.sh` delegates to `scripts/install-forge-linux.sh`. The installer verifies clean/current FORGE and FORGE-OS checkouts, runs `bootstrap-forgeos.sh` unless packages are skipped, runs hardware configuration, builds FORGE with `build-forge.sh` unless a verified current build is requested, installs that runtime with `install-runtime.sh`, installs the Wayland/greetd/recovery files, configures the user desktop, and finishes with installed-machine verification. It invokes sudo only for system mutations and never reboots automatically.

### Update FORGE + FORGE-OS and reinstall

```bash
cd ~/FORGE-OS
./update.sh
```

`update.sh` delegates to `scripts/forge-os-update`. It verifies both `~/FORGE` and `~/FORGE-OS`, fast-forwards their trusted `main` branches, runs the installer, and restores both source checkouts to their pre-update commits if installation fails. After installation, the same updater is available as `forge-os-update`.

The installer supports `--skip-packages` for a machine that already satisfies the complete manifest and `--use-current-build` only when the recorded version, package/lock hashes, runtime-source hash, overlays, executable, app archive, and payload still match.

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
- Native system surfaces cover Network, Audio, Display, Power, Applications, Updates, Security, Recovery, and Advanced state.
- Workspace source/memory indexing starts when a workspace opens and refreshes automatically on filesystem changes without prompting the model.
- KWin provides focus, placement, blur, contrast, translucency, and animation under the FORGE shell.

## Installed-system recovery

FORGE Recovery uses a separate greetd/KWin path on tty2 and is installed as the on-demand `autovt@tty2.service` alias rather than an always-running second graphical service. If the graphical stack itself is unhealthy, switch to another TTY such as Ctrl+Alt+F3, log in, and run:

```bash
cd ~/FORGE-OS
./scripts/disable-graphical-login.sh
```

That disables graphical login, restores console services, and preserves installed runtimes and user/project data. See [Recovery](docs/RECOVERY.md) for logs and rollback details.

## Live ISO recovery and provisioning

The ISO has a separate live-only profile. `forge-live-setup.service` detects ArchISO before it makes any privileged live changes. On live media it:

- creates the ephemeral `forge` account;
- grants passwordless sudo **only to that live account**;
- installs the dedicated live greetd profile;
- enters the same tested FORGE Wayland runtime with `FORGE_LIVE_RECOVERY=1` and `FORGE_RECOVERY_MODE=1`;
- opens FORGE in its full-screen **Live Recovery** GUI;
- exposes **Recovery Root Shell** and **Load / Install ISO or ZIP** launchers.

The bundle loader accepts local `.iso` and `.zip` files, stages them read-only/extracted under `/run`, rejects unsafe ZIP paths, recognizes explicit installer entry points, and requires the user to type `INSTALL` before an installer is executed. Bundles without a recognized installer remain a manual-recovery case instead of being executed blindly.

On an installed system, `forge-live-setup` exits without creating the live user, passwordless sudo rule, or live greeter configuration.

## Build and validate

```bash
./tests/greeter-contract.sh
./tests/source-verify.sh
./scripts/build-forge.sh ~/FORGE
./scripts/build-iso.sh
```

`tests/greeter-contract.sh` prevents the packaged greeter and configured command lines from drifting apart. `tests/source-verify.sh` checks the complete source/build contract. `tests/verify.sh` validates an installed machine. ISO publication additionally requires boot/hardware acceptance and artifact provenance from [the release checklist](docs/RELEASE_CHECKLIST.md).

## Documentation

- [Architecture](ARCHITECTURE.md)
- [Runtime/session contract](session/README.md)
- [User manual](docs/USER_MANUAL.md)
- [Recovery](docs/RECOVERY.md)
- [Security model](docs/SECURITY_MODEL.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)
- [Changelog](CHANGELOG.md)
