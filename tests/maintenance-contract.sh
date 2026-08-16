#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $*" >&2; exit 1; }

for script in \
  "$root/scripts/forge-maintenance-center" \
  "$root/scripts/forge-system-surface" \
  "$root/scripts/forge-runtime-rollback" \
  "$root/scripts/forge-runtime-rollback-activate" \
  "$root/scripts/forge-service-manager" \
  "$root/scripts/forge-service-control"; do
  bash -n "$script"
done

grep -Fq 'advanced) exec /usr/local/bin/forge-maintenance-center' "$root/scripts/forge-system-surface" || fail 'Advanced does not open the maintenance center.'
grep -Fq 'QT_QPA_PLATFORM' "$root/scripts/forge-system-surface" && grep -Fq 'KDE_SESSION_VERSION' "$root/scripts/forge-system-surface" || fail 'native surfaces are not constrained to KDE/Wayland.'
grep -Fq "root-shell 'Administrator shell" "$root/scripts/forge-maintenance-center" || fail 'Advanced root shell action is missing.'
grep -Fq "-e sudo -i" "$root/scripts/forge-maintenance-center" || fail 'Administrator shell is not a real authenticated root shell.'
grep -Fq './install.sh' "$root/scripts/forge-maintenance-center" || fail 'Advanced repair action is missing.'
grep -Fq './update.sh' "$root/scripts/forge-maintenance-center" || fail 'Advanced update/reinstall action is missing.'
grep -Fq 'forge-runtime-rollback' "$root/scripts/forge-maintenance-center" || fail 'Advanced rollback action is missing.'
grep -Fq 'disable-graphical-login.sh' "$root/scripts/forge-maintenance-center" || fail 'Advanced console recovery action is missing.'

grep -Fq 'ln -sfn "releases/$(basename "$target")" "$runtime_root/current"' "$root/scripts/forge-runtime-rollback-activate" || fail 'rollback does not activate last-known-good.'
grep -Fq 'ln -sfn "releases/$(basename "$current")" "$runtime_root/last-known-good"' "$root/scripts/forge-runtime-rollback-activate" || fail 'rollback does not preserve the previous current runtime.'
if grep -Fq 'rm -rf -- "$current"' "$root/scripts/forge-runtime-rollback-activate"; then fail 'rollback still deletes the build it is leaving.'; fi

grep -Fq 'forge-maintenance-center' "$root/scripts/configure-hardware.sh" || fail 'normal installer hardware/service stage does not install the maintenance center.'
grep -Fq 'system-services.tsv' "$root/scripts/configure-hardware.sh" || fail 'service manifest is not installed with Advanced.'
grep -Fq '[Colors:Selection]' "$root/config/kdeglobals" && grep -Fq 'DecorationFocus=55,220,125' "$root/config/kdeglobals" || fail 'KDE native windows do not carry the FORGE accent palette.'

echo 'PASS: Advanced provides explicit authenticated root control, repair/update/recovery tools, and reversible verified runtime rollback inside the KDE Wayland UI.'
