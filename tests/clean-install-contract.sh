#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
installer="$root/scripts/forge-clean-install"
live_setup="$root/scripts/forge-live-setup"
forge_source="${FORGE_SOURCE:-$HOME/FORGE}"
fail() { echo "FAIL: $*" >&2; exit 1; }

bash -n "$installer"
for package in arch-install-scripts efibootmgr dosfstools gptfdisk; do
  grep -Fqx "$package" "$root/manifests/arch-packages.txt" || fail "clean install package is missing: $package"
done

grep -Fq 'Refusing clean-install outside the FORGE live/ArchISO environment.' "$installer" || fail 'installer is not live-environment gated.'
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

# Partitioning and formatting remain deliberately outside this installer. The
# test fails if a future edit silently introduces disk-layout mutations.
if grep -Eq '(^|[;&|[:space:]])(mkfs(\.|[[:space:]])|wipefs([[:space:]]|$)|fdisk([[:space:]]|$)|cfdisk([[:space:]]|$)|parted([[:space:]]|$)|sgdisk([[:space:]]|$))' "$installer"; then
  fail 'clean installer contains a partitioning or formatting command.'
fi

grep -Fq 'forge-clean-install' "$live_setup" || fail 'live setup does not install the clean installer.'
grep -Fq 'forge-live-clean-install.desktop' "$live_setup" || fail 'live setup does not expose the clean installer launcher.'
[[ -r "$root/session/forge-live-clean-install.desktop" ]] || fail 'clean install desktop launcher is missing.'
grep -Fq 'NoDisplay=true' "$root/session/forge-live-clean-install.desktop" || fail 'clean install launcher should remain internal to FORGE Live Recovery.'

grep -Fq 'forge-live-clean-install.desktop' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" || fail 'FORGE Live Recovery does not expose the clean install action.'
grep -Fq 'never partitions or formats' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" || fail 'Live Recovery does not explain the clean installer safety boundary.'

echo 'PASS: clean-install path is live-only, confirmation-gated, mount-targeted, runtime-pinned, and never partitions/formats disks.'
