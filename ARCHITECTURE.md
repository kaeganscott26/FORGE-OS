# FORGE-OS architecture

FORGE-OS separates the visible FORGE workspace from the Linux substrate. FORGE owns Explorer, Applications, System, Workspace Intelligence, chat, terminal, tasks, agent actions, recovery UI, and update entry points. Arch owns the kernel, systemd, PAM, package database, devices, filesystems, networking, audio, and hardware services. KWin/Plasma provide compositor and desktop services beneath FORGE.

## Boot and ownership

```text
systemd graphical.target
  -> greetd on tty1 / PAM
  -> startplasma-wayland forge-wayland-session forge-wayland-client
  -> /usr/local/bin/startplasma-wayland (exact-profile dispatcher)
  -> forge-wayland-session
  -> dbus-run-session + one kwin_wayland --xwayland
  -> forge-wayland-client
  -> D-Bus/systemd environment + kded6 + krunner + PolicyKit + plasmashell
  -> forge-session
  -> /opt/forge/current/<manifest-recorded executable>
```

Calls outside the exact FORGE profile delegate to `/usr/bin/startplasma-wayland`. FORGE does not modify that vendor path. Normal session flags distinguish shell mode from host-integrated or standalone packages.

## Recovery

`autovt@tty2.service` aliases the on-demand FORGE recovery unit. Ctrl+Alt+F2 creates a separate greetd socket, D-Bus, KWin, and `FORGE_RECOVERY_MODE=1` application. It is not started at boot and does not create a second active compositor until requested. Diagnostics run as the configured desktop user; rollback uses a narrow privileged helper after two integrity checks.

## Runtime identity and lifecycle

Product versioning is explicit and independent from ordinary commits. A build record retains the source commits as provenance and additionally pins:

- FORGE package and lockfile SHA-256;
- deterministic shared runtime-source SHA-256;
- FORGE-OS version and ordered overlay SHA-256;
- executable, `app.asar`, and full payload SHA-256;
- content-derived runtime ID and relative paths.

Installation copies to `/opt/forge/releases/<runtime-id>`, verifies again, updates last-known-good, then switches `/opt/forge/current`. Cleanup keeps current and the verified previous runtime. Rollback re-verifies under privilege, switches current, and deletes only the superseded immutable directory. User home, workspaces, `.forge` memory/tasks, and XDG configuration are outside that cleanup.

## Package architecture

`manifests/arch-packages.txt` is shared by bootstrap, ISO, source verification, and installed verification. `forge-app-install` and `forge-install-pkg` map familiar operations to fixed backends:

- Arch/pacman: normal host database/cache/install locations and PolicyKit for mutations;
- apt/Ubuntu and Kali: rootless Distrobox/Podman containers;
- Nix: Nix daemon/store and user profile;
- Flatpak: installed as an additional sandboxed ecosystem, not a pacman replacement.

Application discovery follows XDG desktop entries and refreshes continuously. Mirror replacement is explicit through `forge-refresh-mirrors`.

## Shared application architecture

The FORGE renderer and provider-neutral workspace services are shared across Linux, macOS, Windows, standalone, and OS-integrated packages. Platform packages embed deterministic version/commit/build-date metadata plus a shared runtime hash; each native executable and package keeps its own platform-specific hash.

Linux-only IPC is typed and shell-mode gated. Explorer canonicalizes workspace paths. Settings actions map enum values to fixed executable/argument arrays. Agent requests still pass through registry, policy, approval, executor, and audit even when the Release Workflow capability advertises full filesystem/requestable scope.

## Release boundary

Source gates prove syntax, dependency resolution, tests, lint, types, bundles, and manifest consistency. Stable publication additionally requires clean/native packages, ISO boot and physical/VM acceptance, cross-platform metadata parity, signing/channel rules, and local-versus-remote artifact hashes. See [the release checklist](docs/RELEASE_CHECKLIST.md).
