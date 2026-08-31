#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
installer="$root/scripts/forge-clean-install"
wrapper="$root/scripts/forge-clean-install-wrapper"
guided="$root/scripts/forge-live-guided-install"
setup_ui="$root/scripts/forge-live-setup-ui"
live_setup="$root/scripts/forge-live-setup"
wayland_client="$root/session/forge-wayland-client"
forge_source="${FORGE_SOURCE:-$HOME/FORGE}"
fail() { echo "FAIL: $*" >&2; exit 1; }

for script in "$installer" "$wrapper" "$guided" "$setup_ui" "$live_setup" "$root/scripts/forge-first-boot"; do bash -n "$script"; done
for package in arch-install-scripts efibootmgr dosfstools gptfdisk; do
  grep -Fqx "$package" "$root/manifests/arch-packages.txt" || fail "clean install package is missing: $package"
done

grep -Fq 'Refusing clean-install outside the FORGE live/ArchISO environment.' "$installer" || fail 'installer core is not live-environment gated.'
grep -Fq 'mountpoint -q "$target"' "$installer" || fail 'installer does not require an explicitly mounted target root.'
grep -Fq 'mountpoint -q "$target/boot"' "$installer" || fail 'installer does not require an explicitly mounted UEFI system partition.'
grep -Fq "Type INSTALL to continue" "$installer" || fail 'destructive install confirmation is missing.'
grep -Fq 'pacstrap -K "$target"' "$installer" || fail 'installer does not bootstrap target packages with pacstrap.'
grep -Fq 'genfstab -U "$target"' "$installer" || fail 'installer does not generate a UUID-based fstab.'
grep -Fq 'bootctl install' "$installer" || fail 'UEFI systemd-boot installation is missing.'
grep -Fq 'FORGE_RUNTIME_ID' "$installer" && grep -Fq 'cp -a "$runtime"' "$installer" || fail 'clean install does not reproduce the exact ISO runtime.'
grep -Fq '/opt/forge-os/scripts/configure-aur.sh' "$installer" || fail 'community/AUR repository bootstrap is not run in the installed target.'
grep -Fq 'systemctl --root="$target" enable greetd.service' "$installer" || fail 'graphical login is not enabled in the installed target.'
grep -Fq 'reflector.timer' "$installer" || fail 'persistent mirror refresh is not enabled in the installed target.'
grep -Fq 'pipewire.socket' "$installer" && grep -Fq 'wireplumber.service' "$installer" || fail 'persistent user audio services are missing from clean install.'
grep -Fq -- '--groups wheel,audio,video,input,storage' "$installer" || fail 'primary installed user is not created as an administrator.'
grep -Fq '%%wheel ALL=(ALL:ALL) ALL' "$installer" || fail 'installed wheel administrators do not have authenticated sudo policy.'
grep -Fq '"$user_home/.local/bin"' "$installer" || fail 'clean install does not provision the user-owned npm executable directory.'

# Partitioning and formatting remain deliberately outside the installer core.
if grep -Eq '(^|[;&|[:space:]])(mkfs(\.|[[:space:]])|wipefs([[:space:]]|$)|fdisk([[:space:]]|$)|cfdisk([[:space:]]|$)|parted([[:space:]]|$)|sgdisk([[:space:]]|$))' "$installer"; then
  fail 'clean installer contains a partitioning or formatting command.'
fi

grep -Fq '/usr/local/libexec/forge-clean-install-core' "$wrapper" || fail 'clean install wrapper does not isolate the destructive core.'
grep -Fq 'forge-maintenance-center' "$wrapper" && grep -Fq 'forge-service-manager' "$wrapper" || fail 'clean install finalizer omits Advanced maintenance tools.'
grep -Fq 'forge-first-boot.service' "$wrapper" && grep -Fq 'systemctl --root="$target" enable forge-first-boot.service' "$wrapper" || fail 'clean install finalizer does not install/enable first-boot verification.'
grep -Fq '10-forge-live' "$wrapper" || fail 'clean install finalizer does not remove the live sudo rule from the target.'

grep -Fq '/usr/local/bin/forge-clean-install' "$guided" || fail 'guided installer does not route through the finalized clean installer.'
grep -Fq 'FORGE_FEATURES=' "$guided" || fail 'guided installer does not persist setup feature choices.'
grep -Fq 'power-profiles-daemon.service' "$guided" && grep -Fq 'fwupd-refresh.timer' "$guided" || fail 'guided optional service policy is incomplete.'

grep -Fq -- '--checklist' "$setup_ui" || fail 'live setup has no checkbox-driven optional service UI.'
grep -Fq 'partitionmanager' "$setup_ui" || fail 'live setup cannot open KDE Partition Manager.'
grep -Fq 'forge-live-guided-install' "$setup_ui" || fail 'live setup does not route selections to the guided installer.'
grep -Fq 'QT_QPA_PLATFORM' "$setup_ui" && grep -Fq 'KDE_SESSION_VERSION' "$setup_ui" || fail 'live setup is not pinned to the KDE/Wayland window environment.'
grep -Fq 'forge-live-setup-ui' "$wayland_client" && grep -Fq 'FORGE_LIVE_RECOVERY' "$wayland_client" || fail 'live Wayland session does not auto-open setup.'

grep -Fq 'forge-clean-install-core' "$live_setup" && grep -Fq 'forge-clean-install-wrapper' "$live_setup" || fail 'live setup does not install the finalized clean-install pair.'
grep -Fq 'forge-live-setup.desktop' "$live_setup" || fail 'live setup does not expose its internal launcher.'
[[ -r "$root/session/forge-live-setup.desktop" ]] || fail 'live setup desktop launcher is missing.'
grep -Fq 'NoDisplay=true' "$root/session/forge-live-setup.desktop" || fail 'live setup launcher should remain internal to FORGE Live Recovery.'

grep -Fq 'forge-live-setup.desktop' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" || fail 'FORGE Live Recovery does not expose Guided Setup.'
grep -Fq 'Guided Setup opens automatically' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" || fail 'Live Recovery does not describe the automatic setup contract.'

echo 'PASS: live ISO auto-opens themed KDE setup, keeps disk layout user-controlled, finalizes every install, and verifies required services again on first boot.'
