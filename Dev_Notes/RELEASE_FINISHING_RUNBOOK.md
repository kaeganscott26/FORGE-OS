# FORGE 2.3.0 / FORGE-OS 0.2.2 finishing runbook

This is the ordered operator runbook for finishing the 2.3.0/0.2.2 release from the committed source. Run each numbered section in order. Do not skip a failed gate, publish around a failure, replace an existing tag, or run the installer/updater against the currently accepted desktop before a disposable VM or reference machine passes.

The canonical login command must remain exactly:

```text
startplasma-wayland forge-wayland-session forge-wayland-client
```

The installed command paths remain `/usr/local/bin/startplasma-wayland`, `/usr/local/bin/forge-wayland-session`, and `/usr/local/libexec/forge-wayland-client`. Do not replace them with `/usr/bin` paths or a direct Electron application launch.

## Status when this release-source runbook was frozen

Completed in source before this file was added:

- FORGE-owned Wayland dispatcher/session, login profiles/effects, D-Bus/KRunner startup, native desktop/settings/Explorer/Recovery surfaces, Workspace Intelligence plugin and automatic context indexing.
- Pacman-compatible FORGE package commands; rootless apt/Kali Distrobox and Nix backends; Fish/Starship theme; mirrors; Wayland, gaming and Ollama package declarations.
- Ollama local-model tool schema/UUID fixes and packaged `local-model-tooling` skill parity.
- Content-addressed runtime/update/last-known-good behavior, cross-platform runtime metadata, release-version synchronization and publication workflow.
- Source checks, FORGE typecheck/lint/tests/build, updater transaction tests, dependency audit and an initial Linux package build.

Not performed against a production installation at source freeze:

- No packages, runtime, login manager, shell, mirror list, services, or updater were installed on the currently running workstation. This is intentional protection of the accepted session.
- The final package/ISO rebuild that includes this runbook and its source commit, isolated runtime lifecycle test, UEFI VM boot, live-session acceptance, and physical reference-hardware boot were not yet complete.
- Native Windows and macOS packages had not yet run on their native GitHub runners. Windows signing is not configured by this repository. macOS signing/notarization requires the secrets listed in step 12.
- No 2.3.0/0.2.2 tag, stable GitHub release, stable-channel update, remote asset, or remote checksum had been published.

Anything still listed above must remain an explicit gap unless later evidence names the command/run, artifact hash, machine and result. A graphical ISO that has no guided disk installer must be described as a live/recovery image, not as a completed destructive disk installer.

## 1. Prepare clean trusted checkouts

Use a clean Arch build/VM host and keep the repositories as siblings. The scripts assume these defaults:

```bash
git clone https://github.com/kaeganscott26/FORGE.git "$HOME/FORGE"
git clone https://github.com/kaeganscott26/FORGE-OS.git "$HOME/FORGE-OS"
git -C "$HOME/FORGE" switch main
git -C "$HOME/FORGE-OS" switch main
git -C "$HOME/FORGE" pull --ff-only origin main
git -C "$HOME/FORGE-OS" pull --ff-only origin main
test -z "$(git -C "$HOME/FORGE" status --porcelain)"
test -z "$(git -C "$HOME/FORGE-OS" status --porcelain)"
test "$(node -p "require('$HOME/FORGE/package.json').version")" = 2.3.0
test "$(cat "$HOME/FORGE-OS/VERSION")" = 0.2.2
```

Stop if either origin is not the expected repository, either branch is not `main`, either worktree is dirty, or the versions differ.

## 2. Install the Arch build/runtime dependency stack

On a clean disposable Arch target, run this executable as the desktop user:

```bash
cd "$HOME/FORGE-OS"
./scripts/bootstrap-forgeos.sh
```

`bootstrap-forgeos.sh` enables the official Arch `[multilib]` repository when absent, preserves the active mirror list unless `FORGE_USE_REFERENCE_MIRRORS=1` is explicitly set, removes only the retired FORGE X11-session packages it detects, and runs one `pacman -Syu --needed` transaction. This system mutation must not be run on the accepted workstation merely to build artifacts.

The authoritative package order is `manifests/arch-packages.txt`; at this release it is:

```text
base base-devel linux linux-firmware archiso git npm python nodejs-lts-jod
fish starship reflector
wayland xorg-xwayland kwin plasma-desktop plasma-workspace systemsettings kdialog konsole krunner plasma-nm plasma-pa kscreen powerdevil
breeze breeze-gtk breeze-icons kvantum qt6-wayland qt6-tools qt5-wayland layer-shell-qt qt6-multimedia
xdg-desktop-portal xdg-desktop-portal-kde xdg-desktop-portal-gtk kde-gtk-config polkit-kde-agent dolphin gtk3
mesa vulkan-radeon amd-ucode alsa-lib libnotify cups nss libxss libxcrypt-compat xdg-utils xdg-user-dirs gvfs chromium
networkmanager pipewire pipewire-pulse wireplumber upower power-profiles-daemon irqbalance bluez bluez-utils dbus dbus-broker greetd greetd-tuigreet
flatpak podman distrobox nix ollama ollama-vulkan
gamescope gamemode mangohud wine-staging winetricks goverlay
fwupd snapper btrfs-progs
```

Use `./scripts/configure-hardware.sh` only on the disposable/reference installation after the manifest succeeds. AMD/Vulkan is the declared reference stack; a different GPU requires an intentionally reviewed driver change before hardware acceptance.

## 3. Run the source gate

```bash
cd "$HOME/FORGE"
npm ci
npm audit --omit=dev
npm run verify:release-version

cd "$HOME/FORGE-OS"
FORGE_SOURCE="$HOME/FORGE" ./tests/source-verify.sh
git diff --check
git -C "$HOME/FORGE" diff --check
```

The following executable tests are included by `source-verify.sh` and can be rerun individually while diagnosing a failure:

```text
$HOME/FORGE-OS/tests/session-dispatcher.sh
$HOME/FORGE-OS/tests/update-transaction.sh
$HOME/FORGE-OS/scripts/runtime-source-hash.sh
```

Do not continue unless the summary is zero failures and both repositories remain clean.

## 4. Build and inspect the Linux runtime/packages

Node 22 is mandatory. Confirm `node --version` begins with `v22.` before running:

```bash
cd "$HOME/FORGE-OS"
./scripts/build-forge.sh "$HOME/FORGE"
./tests/runtime-lifecycle.sh
source build/latest.env
sha256sum build/forge-dist/linux-unpacked/"$FORGE_EXECUTABLE_RELATIVE_PATH"
sha256sum build/forge-dist/linux-unpacked/resources/app.asar
find build/forge-dist -maxdepth 1 -type f -printf '%f\n' | sort
```

Expected deliverables include `FORGE-2.3.0-x86_64.AppImage`, `FORGE-2.3.0-amd64.deb`, `latest-linux.yml`, and `linux-unpacked/`. Inspect without installing:

```bash
dpkg-deb --info build/forge-dist/FORGE-2.3.0-amd64.deb
dpkg-deb --contents build/forge-dist/FORGE-2.3.0-amd64.deb
cd build/forge-dist
./FORGE-2.3.0-x86_64.AppImage --appimage-extract
test -x squashfs-root/forge
test -r squashfs-root/resources/app.asar
```

The lifecycle test uses a temporary runtime root and covers initial install, repeat install, corrupt-payload replacement, rollback, superseded-runtime removal and update after rollback. It must not alter `/opt/forge/current`.

## 5. Build and verify the live/recovery ISO

```bash
cd "$HOME/FORGE-OS"
./scripts/build-iso.sh
cd build/iso
sha256sum -c SHA256SUMS
```

`build-iso.sh` consumes `build/latest.env`, checks the immutable runtime hashes, enables `[multilib]` in the ISO pacman profile, embeds the committed FORGE-OS source and produces `build/iso/forge-os-*.iso` plus `SHA256SUMS`.

## 6. Install VM-only boot-test dependencies

After the source/package/ISO gates pass, install these verification packages on the disposable build host in this order:

```text
qemu-desktop
edk2-ovmf
swtpm
socat
```

```bash
sudo pacman -S --needed qemu-desktop edk2-ovmf swtpm socat
test -x /usr/bin/qemu-system-x86_64
test -d /usr/share/edk2/x64
```

Use KVM when `/dev/kvm` is available; otherwise use QEMU TCG and record that reduced-acceleration condition. Boot the ISO with UEFI and at least 4 GiB RAM. Do not attach a production disk:

```bash
cp /usr/share/edk2/x64/OVMF_VARS.4m.fd /tmp/forge-os-OVMF_VARS.4m.fd
iso_path="$(find "$HOME/FORGE-OS/build/iso" -maxdepth 1 -name 'forge-os-*.iso' -print -quit)"
if test -r /dev/kvm; then
  forge_qemu_accel=(-enable-kvm -cpu host)
else
  forge_qemu_accel=(-accel tcg -cpu max)
fi
qemu-system-x86_64 -machine q35 "${forge_qemu_accel[@]}" -m 4096 -smp 4 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
  -drive if=pflash,format=raw,file=/tmp/forge-os-OVMF_VARS.4m.fd \
  -cdrom "$iso_path" \
  -boot d -nic user,model=virtio-net-pci -device virtio-vga-gl -display gtk,gl=on
```

In the VM verify cold matrix login, F2/F3/F4/F5, the exact canonical chain, one KWin owner, all native top-bar/settings/Explorer/Workspace Intelligence/chat surfaces, networking/audio/portals, logout/relogin, Ctrl+Alt+F2 Recovery, shutdown and that `/opt/forge/current/.forge-runtime.env` matches the build record.

## 7. Exercise package backends on the disposable installation

Run `./scripts/install-forge-linux.sh` only after VM/live acceptance and only on the disposable/reference Arch installation. It fetches the trusted `main` origins, rebuilds unless `--use-current-build` is explicitly valid, installs the immutable runtime/session files, configures the user desktop and runs installed verification:

```bash
cd "$HOME/FORGE-OS"
./scripts/install-forge-linux.sh
./tests/verify.sh
```

Then test package operations in this order. Installation/removal commands mutate only this disposable target:

```bash
forge-install-pkg -Ss tree
forge-install-pkg -Si tree
forge-install-pkg -S tree
forge-install-pkg -Q tree
forge-install-pkg -Rns tree

forge-app-install -S kcalc
kbuildsycoca6 --noincremental
forge-app-install -Rns kcalc

forge-install-pkg -Si steam
forge-app-install -S steam
forge-app-install -Rns steam

forge-workspace-bootstrap apt
forge-install-pkg --backend apt -Ss curl
forge-install-pkg --backend apt -S curl
forge-install-pkg --backend apt -Q curl

forge-workspace-bootstrap kali
forge-install-pkg --backend kali -Ss nmap
forge-install-pkg --backend kali -S nmap
forge-install-pkg --backend kali -Q nmap

forge-workspace-bootstrap nix
forge-install-pkg --backend nix -Ss hello
forge-install-pkg --backend nix -S hello
forge-install-pkg --backend nix -Q hello
forge-install-pkg --backend nix -R hello
```

Also test `-Syu` for Arch, apt, Kali and Nix only on a disposable snapshot. Confirm applications use the backend’s normal paths and FORGE Applications refreshes without relogin. Never add Ubuntu/Kali repositories to host pacman.

## 8. Test update and last-known-good on the disposable installation

Create a filesystem/VM snapshot first, then run:

```bash
forge-os-update
sudo /usr/local/libexec/forge-runtime-rollback-activate --help
forge-runtime-rollback
forge-os-update
```

The source gate already tests dirty, untrusted, divergent and failed-install rollback cases. Installed acceptance must confirm persistent `$HOME`, projects, `.forge` memory and task state survive; only superseded immutable `/opt/forge/releases/*` content may be removed.

## 9. Perform reference-hardware acceptance

Boot the checksum-verified ISO on the intended AMD/Vulkan reference hardware. Record model, firmware/UEFI mode, GPU, network/audio devices, ISO SHA-256 and every result from the ISO section of `docs/RELEASE_CHECKLIST.md`. This cannot be replaced by source checks or a headless container. Do not call the ISO stable until this evidence exists.

## 10. Push release-source commits only after local gates

Before pushing, fetch and prove each push is a fast-forward of the trusted remote:

```bash
git -C "$HOME/FORGE" fetch origin main
git -C "$HOME/FORGE-OS" fetch origin main
git -C "$HOME/FORGE" merge-base --is-ancestor origin/main HEAD
git -C "$HOME/FORGE-OS" merge-base --is-ancestor origin/main HEAD
git -C "$HOME/FORGE" push origin main
git -C "$HOME/FORGE-OS" push origin main
```

Do not force-push. Record the full commit IDs after the push.

## 11. Run native cross-platform package acceptance

Authenticate GitHub CLI with workflow/repository access, then run the nonpublishing native workflow from FORGE:

```bash
cd "$HOME/FORGE"
gh auth status
gh workflow run package-cross-platform.yml --ref main
gh run list --workflow package-cross-platform.yml --limit 3
gh run watch RUN_ID --exit-status
mkdir -p /tmp/forge-native-artifacts
gh run download RUN_ID --dir /tmp/forge-native-artifacts
node scripts/verify-runtime-parity.mjs \
  /tmp/forge-native-artifacts/FORGE-macOS-universal/forge-runtime-darwin.json \
  /tmp/forge-native-artifacts/FORGE-Linux-x64/forge-runtime-linux.json \
  /tmp/forge-native-artifacts/FORGE-Windows-x64/forge-runtime-win32.json
```

Inspect the Linux AppImage/DEB, Windows NSIS/ConPTY resources, and macOS universal DMG/ZIP/native PTY evidence on their native runners. `workflow_dispatch` deliberately does not publish.

## 12. Configure signing if signed stable artifacts are required

The tag workflow can sign/notarize macOS only when all of these FORGE repository secrets exist:

```text
CSC_LINK
CSC_KEY_PASSWORD
APPLE_ID
APPLE_APP_SPECIFIC_PASSWORD
APPLE_TEAM_ID
```

Windows artifacts are currently unsigned; add and validate an explicit Authenticode workflow before policy claims signed Windows packages. Do not claim unsigned packages are signed. Never store signing material in either repository or this runbook.

## 13. Tag and publish FORGE 2.3.0

Only after steps 1-12 and every applicable release-checklist gate pass, prove the tags/releases do not already exist, make annotated tags, and push without replacement:

```bash
cd "$HOME/FORGE"
git ls-remote --exit-code --tags origin refs/tags/v2.3.0 && exit 1 || true
gh release view v2.3.0 && exit 1 || true
git tag -a v2.3.0 -m 'FORGE 2.3.0' "$(git rev-parse HEAD)"
test "$(git cat-file -t v2.3.0)" = tag
git push origin refs/tags/v2.3.0
gh run list --workflow package-cross-platform.yml --limit 3
gh run watch RUN_ID --exit-status
```

The tag workflow verifies tag/version/runtime parity, builds all native packages, creates `SHA256SUMS`, creates a draft release, independently downloads and verifies every asset, then publishes it as latest. Download the published release to a new directory and verify again:

```bash
mkdir -p /tmp/forge-2.3.0-release
gh release download v2.3.0 --dir /tmp/forge-2.3.0-release
cd /tmp/forge-2.3.0-release
sha256sum -c SHA256SUMS
```

## 14. Tag and publish the FORGE-OS 0.2.2 live/recovery ISO

```bash
cd "$HOME/FORGE-OS"
git ls-remote --exit-code --tags origin refs/tags/v0.2.2 && exit 1 || true
gh release view v0.2.2 && exit 1 || true
git tag -a v0.2.2 -m 'FORGE-OS 0.2.2' "$(git rev-parse HEAD)"
test "$(git cat-file -t v0.2.2)" = tag
git push origin refs/tags/v0.2.2
gh release create v0.2.2 build/iso/forge-os-*.iso build/iso/SHA256SUMS \
  --verify-tag --latest --title 'FORGE-OS 0.2.2' --generate-notes
mkdir -p /tmp/forge-os-0.2.2-release
gh release download v0.2.2 --dir /tmp/forge-os-0.2.2-release
cd /tmp/forge-os-0.2.2-release
sha256sum -c SHA256SUMS
```

Label the release as live/recovery if guided disk installation has not been separately implemented and accepted.

## 15. Verify the stable channel from a clean client

From a disposable installation on the prior stable build, run `forge-os-update` and confirm it resolves the new trusted `main` source, installs the content-addressed runtime, preserves memory and leaves one last-known-good release. Verify FORGE’s published `latest-linux.yml`, `latest.yml`, and `latest-mac.yml` resolve to assets whose hashes match the release checksum manifest. Equal version, downgrade, prerelease/stable mismatch, dirty source, untrusted origin and divergent history must all be rejected.

The release is finished only when `docs/RELEASE_CHECKLIST.md` is fully evidenced and the final session log records commit IDs, tags, workflow run URLs, native/VM/hardware results, artifact names, SHA-256 values, release URLs and any deliberately unsupported signing state.
