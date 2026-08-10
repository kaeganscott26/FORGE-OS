# FORGE OS Build State

## Checkpoint

- Observed: 2026-08-10T16:15:26-05:00
- Phase: 1 - initial reality discovery
- Status: bootstrap prerequisites incomplete; no graphical session installed
- Next dependency-ready action: establish a supported Node 22 toolchain, then
  verify FORGE from source before installing a minimal graphical stack.

## Machine and operating system

- Hostname: `forge-linux`
- Hardware: ASUS TUF Gaming FX705DY
- Architecture: x86_64
- CPU: AMD Ryzen 5 3550H, 4 cores / 8 threads
- Memory: 15 GiB; no swap configured
- OS: Arch Linux rolling release
- Kernel: `7.1.6-arch1-1`
- Boot: persistent internal installation; EFI is mounted at `/boot`
- Root filesystem: ext4 on `/dev/sda2`, UUID
  `3af3cece-c6b1-47a7-8508-fea94eeb7d04`
- Root capacity at checkpoint: 915 GiB total, 5.0 GiB used
- Secondary storage observed: NVMe device with existing NTFS partitions; it has
  not been mounted or modified by this experiment.

## Hardware observations

- Integrated GPU: AMD Picasso/Raven 2 Vega, `amdgpu`
- Discrete GPU: AMD Baffin RX 460/560 family, `amdgpu`
- Wi-Fi: Qualcomm Atheros QCA9377, `ath10k_pci`
- Ethernet: Realtek RTL8111/8168 family, `r8169`
- Audio: AMD HDMI/DP and Ryzen HD Audio, `snd_hda_intel`

## User, privilege, and recovery state

- Active user: `North3rnLight3r` (UID 1000), member of `wheel`
- Prompt assumption mismatch: no `forge` user is currently active.
- Session: local `tty1`; no display manager; `$DISPLAY` is unset.
- Default systemd target: `graphical.target`
- Recovery getty: `getty@.service` is enabled.
- Sudo: `sudo -l` reports both normal ALL and blanket `NOPASSWD: ALL` rules.
- `/etc/sudoers.d/90-forge-experiment` was not present during inspection; the
  actual source of NOPASSWD authority remains to be identified before removal.
- No failed systemd units were reported.

## Networking and graphical stack

- NetworkManager: enabled and active.
- Connectivity: full at checkpoint; connection reported metered (guessed).
- Xorg server: not installed as a pacman package.
- xinit: not installed as a pacman package.
- Openbox: not installed as a pacman package.
- No display-manager unit exists.
- No X11/Wayland desktop session is active.

## Development toolchain

- Node.js: `v26.7.0`
- npm: `12.0.2`
- Git: `2.55.0`
- Codex CLI: `0.147.0`
- `base-devel`: installed
- Prompt/toolchain mismatch: repository documentation requires Node.js 22 LTS;
  the installed Node 26 runtime must not be treated as verified compatibility.

## FORGE source

- Path: `/home/North3rnLight3r/FORGE`
- Branch: `main`, tracking `origin/main`
- Commit: `ab650e63714b9e23b87200b8c0d61a327f5ec118`
- Remote: `https://github.com/kaeganscott26/FORGE`
- Tree state: dirty before FORGE-OS work. Existing generated file
  `apps/desktop/out/main/index.js` contains updated build commit/date constants.
  It is treated as user-owned and has not been reverted or edited.
- Native Linux packaging entrypoint: `scripts/package-linux.sh`
- Package targets: x86_64 AppImage and DEB via `npm run package:linux`
- Packaging script requires Node, npm, Python 3, make, and g++; runs clean install,
  typecheck, lint, tests, build, packaging, and node-pty artifact checks.
- Current Linux build status: not yet verified on this installation.

## Startup path

Current startup is Arch console login on `tty1`. The prompt's assumed temporary
`startx + Openbox + npm run dev` path is not present on this machine. No FORGE
autostart, launcher, user service, or graphical session has been installed.

## Known limitations and risks

1. The active username differs from the experiment prompt.
2. Node 26 differs from the documented Node 22 LTS requirement.
3. The minimal graphical dependencies are absent.
4. No packaged FORGE Linux artifact has been built or manually accepted.
5. Blanket passwordless sudo is active and its defining rule is not yet located.
6. No swap is configured.
7. Hybrid AMD graphics behavior under Electron/Xorg is unverified.
8. Reboot, graphical startup, workspace persistence, and integrated PTY behavior
   have not been tested in this checkpoint.

## Recovery and non-actions

- `Ctrl+Alt+F2` or another getty-backed virtual terminal is the intended recovery
  route once graphics are introduced; it has not yet been physically tested.
- No packages, system files, services, login configuration, partitions,
  bootloader settings, or FORGE source files were changed in this phase.
- Do not point boot/login startup at the mutable FORGE checkout.
- Do not remove sudo authority until the source rule is identified and a
  password-protected wheel path is verified with the human.
