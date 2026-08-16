#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$repository_root/manifests/arch-packages.txt"
source /etc/os-release
[[ "${ID:-}" == arch ]] || { echo 'This bootstrap supports Arch Linux only.' >&2; exit 1; }
command -v pacman >/dev/null || { echo 'The Arch package backend is required.' >&2; exit 1; }
mapfile -t packages < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$manifest")
(( ${#packages[@]} > 0 )) || { echo 'Package manifest is empty.' >&2; exit 1; }

enable_multilib() {
  local pacman_config=/etc/pacman.conf staged
  /usr/bin/pacman-conf --repo-list | grep -Fxq multilib && return
  grep -Fxq '#[multilib]' "$pacman_config" || {
    echo 'The canonical commented [multilib] section is missing from /etc/pacman.conf; refusing an ambiguous edit.' >&2
    exit 1
  }
  staged="$(mktemp)"
  awk '
    $0 == "#[multilib]" { in_multilib = 1; print "[multilib]"; next }
    in_multilib && $0 == "#Include = /etc/pacman.d/mirrorlist" {
      print "Include = /etc/pacman.d/mirrorlist"
      in_multilib = 0
      enabled = 1
      next
    }
    { print }
    END { if (!enabled) exit 42 }
  ' "$pacman_config" >"$staged" || {
    rm -f -- "$staged"
    echo 'Unable to enable the canonical [multilib] mirror include.' >&2
    exit 1
  }
  /usr/bin/pacman-conf --config "$staged" --repo-list | grep -Fxq multilib || {
    rm -f -- "$staged"
    echo 'The staged pacman configuration does not expose [multilib].' >&2
    exit 1
  }
  sudo install -o root -g root -m 0644 "$staged" "$pacman_config"
  rm -f -- "$staged"
  echo 'Enabled the official Arch [multilib] repository for Steam and 32-bit compatibility.'
}

enable_multilib

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
sudo /usr/bin/pacman -Syu --needed --noconfirm "${packages[@]}"
