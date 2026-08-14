#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$repository_root/manifests/arch-packages.txt"
source /etc/os-release
[[ "${ID:-}" == arch ]] || { echo 'This bootstrap supports Arch Linux only.' >&2; exit 1; }
command -v pacman >/dev/null || { echo 'pacman is required.' >&2; exit 1; }
mapfile -t packages < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$manifest")
(( ${#packages[@]} > 0 )) || { echo 'Package manifest is empty.' >&2; exit 1; }

legacy_x11=(xorg-server xorg-xinit openbox kwin-x11 thunar thunar-volman dunst xclip polkit-gnome)
installed_legacy=()
for package in "${legacy_x11[@]}"; do
  pacman -Q "$package" >/dev/null 2>&1 && installed_legacy+=("$package")
done
if (( ${#installed_legacy[@]} > 0 )); then
  echo "Removing retired X11 session packages: ${installed_legacy[*]}"
  sudo pacman -Rns --noconfirm "${installed_legacy[@]}"
fi

if [[ "${FORGE_USE_REFERENCE_MIRRORS:-0}" == 1 ]]; then
  sudo install -o root -g root -m 0644 "$repository_root/config/mirrorlist" /etc/pacman.d/mirrorlist
  echo 'Installed the FORGE-OS reference mirror order by explicit request.'
else
  echo 'Preserving the machine current pacman mirrorlist. Set FORGE_USE_REFERENCE_MIRRORS=1 to install the tracked reference list.'
fi

echo "Installing ${#packages[@]} declared packages from $manifest"
sudo pacman -Syu --needed --noconfirm "${packages[@]}"
