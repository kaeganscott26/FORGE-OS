#!/usr/bin/env bash
set -euo pipefail
source /etc/os-release
[[ "${ID:-}" == arch ]] || { echo 'Arch Linux is required.' >&2; exit 1; }
for unit in NetworkManager.service bluetooth.service irqbalance.service power-profiles-daemon.service; do sudo systemctl enable --now "$unit"; done
command -v powerprofilesctl >/dev/null && powerprofilesctl set performance
echo 'Hardware services enabled. Reboot manually to activate a new kernel or AMD microcode.'
