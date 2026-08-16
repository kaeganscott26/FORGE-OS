#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source /etc/os-release
[[ "${ID:-}" == arch ]] || { echo 'Arch Linux is required.' >&2; exit 1; }
manifest="$root/manifests/system-services.tsv"
[[ -r "$manifest" ]] || { echo 'FORGE-OS service manifest is missing.' >&2; exit 1; }

# Install the same manifest and allowlisted controller used by the Advanced UI.
sudo install -d -o root -g root -m 0755 /usr/share/forge-os /usr/local/bin /usr/local/libexec /etc/xdg/reflector
sudo install -o root -g root -m 0644 "$manifest" /usr/share/forge-os/system-services.tsv
sudo install -o root -g root -m 0755 "$root/scripts/forge-service-manager" /usr/local/bin/forge-service-manager
sudo install -o root -g root -m 0755 "$root/scripts/forge-service-control" /usr/local/libexec/forge-service-control
sudo install -o root -g root -m 0644 "$root/config/reflector.conf" /etc/xdg/reflector/reflector.conf

# The normal installer configures greetd only after the canonical login files
# are verified, so do not start greetd from this early service pass.
while IFS='|' read -r scope unit policy risk label description; do
  [[ -n "$scope" && "$scope" != \#* ]] || continue
  case "$scope" in
    system)
      [[ "$unit" == greetd.service ]] && continue
      if ! systemctl cat "$unit" >/dev/null 2>&1; then
        if [[ "$policy" == required ]]; then
          echo "Required systemd unit is missing: $unit" >&2
          exit 1
        fi
        echo "Optional systemd unit is unavailable: $unit" >&2
        continue
      fi
      if ! sudo systemctl enable --now "$unit"; then
        if [[ "$policy" == required ]]; then
          echo "Required systemd unit failed to enable/start: $unit" >&2
          exit 1
        fi
        echo "Optional systemd unit could not start: $unit" >&2
      fi
      ;;
    global)
      if [[ ! -e "/usr/lib/systemd/user/$unit" && ! -e "/etc/systemd/user/$unit" && ! -e "/usr/local/lib/systemd/user/$unit" ]]; then
        if [[ "$policy" == required ]]; then
          echo "Required user unit is missing: $unit" >&2
          exit 1
        fi
        continue
      fi
      sudo systemctl --global enable "$unit" >/dev/null
      ;;
    *)
      echo "Unknown service scope in manifest: $scope" >&2
      exit 1
      ;;
  esac
done <"$manifest"

# Start per-user media services immediately when the current user manager is
# reachable. Global enablement above is what guarantees persistence on reboot.
if [[ -n "${XDG_RUNTIME_DIR:-}" ]] && systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user start pipewire.socket pipewire-pulse.socket wireplumber.service || {
    echo 'Warning: audio user services could not be started immediately; global enablement remains installed.' >&2
  }
fi

# Power profile selection is a preference, not an install gate; some firmware
# exposes no performance profile even when the service itself is healthy.
if command -v powerprofilesctl >/dev/null 2>&1 && systemctl is-active --quiet power-profiles-daemon.service; then
  powerprofilesctl set performance || echo 'Warning: unable to select performance power profile.' >&2
fi

echo 'FORGE-OS services are enabled from the authoritative manifest; Advanced can manage them without terminal systemctl commands.'
