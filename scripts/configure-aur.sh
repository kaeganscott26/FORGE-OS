#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source /etc/os-release
[[ "${ID:-}" == arch ]] || { echo 'Arch Linux is required.' >&2; exit 1; }
[[ "$EUID" -ne 0 ]] || { echo 'Run configure-aur.sh as the desktop user; sudo is used only for system changes.' >&2; exit 77; }

install_aur_package() {
  local package="$1" temporary
  temporary="$(mktemp -d)"
  trap 'rm -rf -- "$temporary"' RETURN
  git clone --depth 1 "https://aur.archlinux.org/${package}.git" "$temporary/$package"
  (cd "$temporary/$package" && makepkg -si --needed --noconfirm)
  rm -rf -- "$temporary"
  trap - RETURN
}

enable_chaotic_aur() {
  if /usr/bin/pacman-conf --repo-list | grep -Fxq chaotic-aur; then
    echo 'Chaotic-AUR repository already enabled.'
    return
  fi
  echo 'Enabling Chaotic-AUR binary repository.'
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3056513887B78AEB
  sudo /usr/bin/pacman -U --needed --noconfirm \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  local staged
  staged="$(mktemp)"
  cat /etc/pacman.conf >"$staged"
  printf '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n' >>"$staged"
  /usr/bin/pacman-conf --config "$staged" --repo-list | grep -Fxq chaotic-aur || {
    rm -f -- "$staged"
    echo 'Refusing to install an invalid Chaotic-AUR pacman configuration.' >&2
    exit 1
  }
  sudo install -o root -g root -m 0644 "$staged" /etc/pacman.conf
  rm -f -- "$staged"
  sudo /usr/bin/pacman -Sy --noconfirm
}

if [[ "${FORGE_DISABLE_CHAOTIC_AUR:-0}" != 1 ]]; then
  enable_chaotic_aur
else
  echo 'Chaotic-AUR enablement explicitly disabled by FORGE_DISABLE_CHAOTIC_AUR=1.'
fi

if ! command -v yay >/dev/null 2>&1; then
  echo 'Installing yay-bin AUR helper.'
  install_aur_package yay-bin
fi

fork_ready=false
if command -v tuigreet >/dev/null 2>&1; then
  help_text="$(tuigreet --help 2>&1 || true)"
  if grep -Fq -- '--background' <<<"$help_text" && grep -Fq -- '--kb-background' <<<"$help_text" && grep -Fq -- '--doom-height' <<<"$help_text" && grep -Fq -- '--matrix-length' <<<"$help_text"; then
    fork_ready=true
  fi
fi
if [[ "$fork_ready" != true ]]; then
  echo 'Installing maintained greetd-tuigreet-fork-bin from the AUR.'
  install_aur_package greetd-tuigreet-fork-bin
fi

help_text="$(/usr/bin/tuigreet --help 2>&1 || true)"
for option in --background --background-fps --kb-background --doom-height --doom-spread --doom-colors --matrix-length --matrix-speed --matrix-colors; do
  grep -Fq -- "$option" <<<"$help_text" || { echo "Installed tuigreet is missing required fork option: $option" >&2; exit 1; }
done
sudo ln -sfn /usr/bin/tuigreet /usr/local/bin/tuigreet
getent passwd greeter >/dev/null || { echo 'The greetd greeter account is missing.' >&2; exit 1; }
sudo install -d -o greeter -g greeter -m 0755 /var/cache/tuigreet
printf 'AUR tooling ready: yay=%s; tuigreet=%s\n' "$(command -v yay)" "$(/usr/local/bin/tuigreet --version 2>&1 | head -n1)"
