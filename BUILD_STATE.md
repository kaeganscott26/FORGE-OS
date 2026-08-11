# FORGE OS Build State

## Checkpoint

- Observed: 2026-08-11T00:20:17-05:00
- Phase: packaged-runtime staging and session installation
- Status: build and non-graphical verification complete; manual X acceptance pending
- Next dependency-ready action: the human runs `startx`, completes
  `docs/ACCEPTANCE.md`, and records the result before enabling the TTY1 handoff.
- Login autostart is deliberately **disabled**. No reboot was requested or run.

## Machine and operating system

- Hostname: `forge-linux`; ASUS TUF Gaming FX705DY; x86_64.
- CPU: AMD Ryzen 5 3550H, 4 cores / 8 threads.
- Memory: 15 GiB; no swap configured.
- OS: Arch Linux on ext4 `/dev/sda2`; EFI remains mounted at `/boot`.
- Running kernel: `7.1.6-arch1-1`.
- Installed kernel package: `7.1.7.arch1-1`; activation requires a later
  human-controlled reboot.
- Root filesystem at checkpoint: 915 GiB total, 6.8 GiB used.
- The secondary NVMe/NTFS storage was not mounted or modified.

## User, privilege, network, and recovery

- Session user: `North3rnLight3r` (UID 1000), a member of `wheel`.
- NetworkManager is enabled and active.
- The getty recovery path is enabled; no display manager was installed.
- `systemctl --failed` reported no failed units.
- `visudo -c` passes.
- Main `/etc/sudoers` line 128 contains `%wheel ALL=(ALL:ALL) NOPASSWD: ALL`;
  line 125 also retains the password-protected wheel rule. This pre-existing
  blanket rule was not removed because password authentication must be tested
  with the human first. No `/etc/sudoers.d/90-forge-experiment` file exists.

## Installed prerequisites

- Node changed from unsupported v26 to `nodejs-lts-jod 22.23.2-1`.
- The minimal Xorg/Openbox runtime, GTK/Mesa/audio/notification/printing
  libraries, `libxss`, and Noto fonts are installed from
  `manifests/arch-packages.txt`.
- `libxcrypt-compat 4.5.2-1` is installed for electron-builder's bundled FPM
  DEB backend.
- The tracked mirror order is installed at `/etc/pacman.d/mirrorlist`; the
  prior file is preserved as
  `/etc/pacman.d/mirrorlist.pre-forge-20260810`.

## FORGE source and verified build

- Source: `/home/North3rnLight3r/FORGE`, branch `main`.
- Artifact source commit: `1c1b50ef26d3a86d8c815ba3ab56f71d256003d5`.
- Lockfile SHA-256:
  `af710a4d6cfee19eb43ffab37194592bf0539f5aae00ac4f67092253f3a4262a`.
- Source gates passed: TypeScript, ESLint, 27 Vitest files, 113 tests passed,
  2 tests intentionally skipped, Electron/Vite production build.
- Packaging passed for AppImage and DEB. The unpacked native `node-pty` module
  is an x86-64 ELF shared object and has no missing dynamic libraries.
- electron-builder emitted a non-fatal desktop-name/window-association warning.

Artifacts:

| Artifact | SHA-256 |
| --- | --- |
| `FORGE/dist_electron/FORGE-2.3.0-beta.1-x86_64.AppImage` | `907eb23757c8deb593ba0f0e51df22e214dfc1c48e96a8082ffc6631271f812a` |
| `FORGE/dist_electron/FORGE-2.3.0-beta.1-amd64.deb` | `54584158a5ecc64bc03d255f5eb32f9f9fda89dca67807f83d67ad9a683937bf` |
| `FORGE/dist_electron/linux-unpacked/forge` | `57defb643d7c3e0718419a414dfd758986d6d50ba9b50c9f7ff154eeb26e973d` |

The first package attempt exposed missing maintainer metadata. The second
exposed FPM's `libcrypt.so.1` dependency. The third exposed a Linux verifier
that incorrectly required node-pty's macOS-only `spawn-helper`. Each failure
stopped before acceptance; the final build was rerun from the committed fix.

## Installed runtime and session boundary

- Immutable runtime:
  `/opt/forge/releases/1c1b50ef26d3a86d8c815ba3ab56f71d256003d5`.
- Stable pointer: `/opt/forge/current` resolves to that release.
- Root-owned launcher: `/usr/local/bin/forge-session` (mode 0755).
- User-owned xinit entry: `/home/North3rnLight3r/.xinitrc` (mode 0755).
- The launcher rejects root, uses the immutable runtime, opens
  `/home/North3rnLight3r/FORGE-OS`, and logs to
  `~/.local/state/forge/session.log`.
- `tests/verify.sh`: 0 failures, 1 warning. The warning is the pre-existing
  non-interactive wheel sudo authority described above.
- `/etc/profile.d/forge-autostart.sh` is absent, so console login behavior is
  unchanged and `startx` remains an explicit manual action. The enable script
  was verified to refuse installation while the acceptance marker is absent.

## Preserved state and remaining acceptance

- The pre-existing generated-file modification in
  `FORGE/apps/desktop/out/main/index.js` remains user-owned and must retain its
  observed commit/date constants after build cleanup.
- The repositories and `FORGE-OS/.forge` workspace state were preserved.
- Graphical launch, hybrid-GPU behavior, file persistence, integrated PTY,
  Codex availability inside the PTY, close/reopen persistence, physical VT
  recovery, and post-kernel-update reboot remain unverified.
- Do not create `build/acceptance.env` or run `scripts/enable-autostart.sh`
  until a human completes every check in `docs/ACCEPTANCE.md`.

## Rollback

- From a recovery TTY, run `~/FORGE-OS/scripts/rollback-session.sh` to remove
  the installed launcher and matching `.xinitrc` while preserving releases and
  workspace data.
- If autostart is later accepted and installed, run
  `~/FORGE-OS/scripts/disable-autostart.sh` or create
  `~/.config/forge/disable-autostart` before the next login.
- Restore the former mirror list, if needed, from the dated backup above.
