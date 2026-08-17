#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $*" >&2; exit 1; }

for script in \
  "$root/scripts/forge-maintenance-center" \
  "$root/scripts/forge-system-surface" \
  "$root/scripts/forge-runtime-rollback" \
  "$root/scripts/forge-runtime-rollback-activate" \
  "$root/scripts/forge-system-checkpoint" \
  "$root/scripts/forge-system-rollback" \
  "$root/scripts/forge-system-rollback-apply" \
  "$root/scripts/forge-service-manager" \
  "$root/scripts/forge-service-control"; do
  bash -n "$script"
done

grep -Fq 'advanced) exec /usr/local/bin/forge-maintenance-center' "$root/scripts/forge-system-surface" || fail 'Advanced does not open the maintenance center.'
grep -Fq 'QT_QPA_PLATFORM' "$root/scripts/forge-system-surface" && grep -Fq 'KDE_SESSION_VERSION' "$root/scripts/forge-system-surface" || fail 'native surfaces are not constrained to KDE/Wayland.'
grep -Fq "root-shell 'Administrator shell" "$root/scripts/forge-maintenance-center" || fail 'Advanced root shell action is missing.'
grep -Fq -- '-e sudo -i' "$root/scripts/forge-maintenance-center" || fail 'Administrator shell is not a real authenticated root shell.'
grep -Fq './install.sh' "$root/scripts/forge-maintenance-center" || fail 'Advanced repair action is missing.'
grep -Fq './update.sh' "$root/scripts/forge-maintenance-center" || fail 'Advanced update/reinstall action is missing.'
grep -Fq "system-rollback 'Roll back system checkpoint" "$root/scripts/forge-maintenance-center" || fail 'Advanced full-system checkpoint rollback action is missing.'
grep -Fq "runtime-rollback 'Switch runtime only" "$root/scripts/forge-maintenance-center" || fail 'Advanced runtime-only rollback action is missing.'
grep -Fq 'disable-graphical-login.sh' "$root/scripts/forge-maintenance-center" || fail 'Advanced console recovery action is missing.'

grep -Fq 'ln -sfn "releases/$(basename "$target")" "$runtime_root/current"' "$root/scripts/forge-runtime-rollback-activate" || fail 'runtime rollback does not activate last-known-good.'
grep -Fq 'ln -sfn "releases/$(basename "$current")" "$runtime_root/last-known-good"' "$root/scripts/forge-runtime-rollback-activate" || fail 'runtime rollback does not preserve the previous current runtime.'
if grep -Fq 'rm -rf -- "$current"' "$root/scripts/forge-runtime-rollback-activate"; then fail 'runtime rollback still deletes the build it is leaving.'; fi

grep -Fq 'checkpoint_root=/var/lib/forge-os/checkpoints' "$root/scripts/forge-system-checkpoint" && grep -Fq 'checkpoint="$checkpoint_root/previous"' "$root/scripts/forge-system-checkpoint" || fail 'system checkpoint does not resolve to the fixed root-owned /var/lib/forge-os/checkpoints/previous path.'
grep -Fq 'install -d -o root -g root -m 0700 "$checkpoint_root"' "$root/scripts/forge-system-checkpoint" || fail 'system checkpoint directory is not root-owned and private.'
grep -Fq 'SHA256SUMS' "$root/scripts/forge-system-checkpoint" && grep -Fq 'SYMLINKS' "$root/scripts/forge-system-checkpoint" || fail 'system checkpoint lacks file/symlink integrity manifests.'
grep -Fq '/etc/greetd/config.toml' "$root/scripts/forge-system-checkpoint" && grep -Fq '/usr/share/forge-os' "$root/scripts/forge-system-checkpoint" || fail 'system checkpoint omits boot-critical FORGE integration.'
grep -Fq 'sha256sum -c' "$root/scripts/forge-system-rollback-apply" && grep -Fq 'cmp -s "$current_links"' "$root/scripts/forge-system-rollback-apply" || fail 'system rollback does not verify checkpoint integrity before restore.'
grep -Fq 'cp -a "$rootfs/." /' "$root/scripts/forge-system-rollback-apply" || fail 'system rollback does not restore the FORGE-owned rootfs checkpoint.'
grep -Fq 'ln -sfn "releases/$runtime_name" /opt/forge/current' "$root/scripts/forge-system-rollback-apply" || fail 'system rollback does not restore checkpoint runtime.'
grep -Fq 'ln -sfn "releases/$(basename "$current_runtime")" /opt/forge/last-known-good' "$root/scripts/forge-system-rollback-apply" || fail 'system rollback is not reversible.'
grep -Fq 'forge-system-checkpoint' "$root/scripts/forge-os-update" || fail 'updater does not checkpoint the installed system before fast-forward/install.'

grep -Fq 'forge-maintenance-center' "$root/scripts/configure-hardware.sh" || fail 'normal installer hardware/service stage does not install the maintenance center.'
grep -Fq 'forge-system-rollback' "$root/scripts/configure-hardware.sh" && grep -Fq 'forge-system-checkpoint' "$root/scripts/configure-hardware.sh" || fail 'normal installer does not install system checkpoint recovery helpers.'
grep -Fq 'system-services.tsv' "$root/scripts/configure-hardware.sh" || fail 'service manifest is not installed with Advanced.'
grep -Fq 'forge-system-rollback' "$root/scripts/forge-clean-install-wrapper" && grep -Fq 'forge-system-checkpoint' "$root/scripts/forge-clean-install-wrapper" || fail 'clean installer omits system checkpoint recovery helpers.'
grep -Fq '[Colors:Selection]' "$root/config/kdeglobals" && grep -Fq 'DecorationFocus=55,220,125' "$root/config/kdeglobals" || fail 'KDE native windows do not carry the FORGE accent palette.'

echo 'PASS: Advanced provides authenticated root control, service/repair/update/recovery tools, reversible runtime switching, and hash-verified pre-update FORGE-OS system rollback inside the KDE Wayland UI.'
