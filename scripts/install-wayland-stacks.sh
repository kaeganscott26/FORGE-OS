#!/usr/bin/env bash
set -euo pipefail

profile="${1:-full}"
case "$profile" in
  core) packages=(wayland xorg-xwayland kwin qt6-wayland layer-shell-qt) ;;
  plasma) packages=(plasma-desktop plasma-workspace plasma-nm plasma-pa kscreen powerdevil xdg-desktop-portal-kde) ;;
  gaming) packages=(gamescope gamemode mangohud wine-staging winetricks goverlay) ;;
  full) packages=(wayland xorg-xwayland kwin qt6-wayland layer-shell-qt plasma-desktop plasma-workspace plasma-nm plasma-pa kscreen powerdevil xdg-desktop-portal-kde gamescope gamemode mangohud wine-staging winetricks goverlay) ;;
  *) echo 'Usage: install-wayland-stacks.sh core|plasma|gaming|full' >&2; exit 64 ;;
esac

exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/forge-install-pkg" -S "${packages[@]}"
