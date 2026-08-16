#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source /etc/os-release
[[ "${ID:-}" == arch ]] || { echo 'Arch Linux is required.' >&2; exit 1; }

required_system_units=(
  NetworkManager.service
  bluetooth.service
  firewalld.service
  irqbalance.service
  systemd-timesyncd.service
  cups.service
)
for unit in "${required_system_units[@]}"; do
  sudo systemctl enable --now "$unit"
done

# Persistent maintenance timers. Reflector owns only the official Arch
# mirrorlist; third-party repository mirrorlists keep their own packages.
sudo install -d -o root -g root -m 0755 /etc/xdg/reflector
sudo install -o root -g root -m 0644 "$root/config/reflector.conf" /etc/xdg/reflector/reflector.conf
for timer in fstrim.timer reflector.timer; do
  sudo systemctl enable --now "$timer"
done
if systemctl list-unit-files fwupd-refresh.timer >/dev/null 2>&1; then
  sudo systemctl enable --now fwupd-refresh.timer || echo 'Warning: fwupd refresh timer could not be enabled.' >&2
fi

# PipeWire and WirePlumber are user services. --global makes the enablement
# survive reboot/new sessions; --user starts them immediately when the current
# graphical user manager is reachable.
for unit in pipewire.socket pipewire-pulse.socket wireplumber.service; do
  sudo systemctl --global enable "$unit" >/dev/null 2>&1 || true
done
if [[ -n "${XDG_RUNTIME_DIR:-}" ]] && systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service || {
    echo 'Warning: audio user services could not be started immediately; global enablement remains installed.' >&2
  }
fi

# Power profile support is hardware- and driver-dependent. It must not abort a
# valid FORGE-OS install on hardware whose firmware does not expose profiles.
if sudo systemctl enable --now power-profiles-daemon.service; then
  if command -v powerprofilesctl >/dev/null && ! powerprofilesctl set performance; then
    echo 'Warning: unable to select the performance power profile; continuing the update.' >&2
  fi
else
  echo 'Warning: power-profiles-daemon could not be started; continuing the update.' >&2
fi

if ! sudo systemctl enable --now ollama.service; then
  echo 'Warning: Ollama could not be started; local model tooling will remain unavailable until the service is repaired.' >&2
fi

echo 'FORGE-OS system services, user audio services, and maintenance timers are enabled persistently.'
