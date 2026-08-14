#!/usr/bin/env bash
set -euo pipefail
source /etc/os-release
[[ "${ID:-}" == arch ]] || { echo 'Arch Linux is required.' >&2; exit 1; }
for unit in NetworkManager.service bluetooth.service irqbalance.service; do sudo systemctl enable --now "$unit"; done

# Power profile support is hardware- and driver-dependent. In particular,
# powerprofilesctl can briefly fail to reach the daemon over the system bus
# while an update is being installed from a graphical session. Power tuning
# must not prevent the rest of FORGE-OS from being updated.
if sudo systemctl enable --now power-profiles-daemon.service; then
  if command -v powerprofilesctl >/dev/null && ! powerprofilesctl set performance; then
    echo 'Warning: unable to select the performance power profile; continuing the update.' >&2
  fi
else
  echo 'Warning: power-profiles-daemon could not be started; continuing the update.' >&2
fi
echo 'Hardware services enabled. Reboot manually to activate a new kernel or AMD microcode.'
