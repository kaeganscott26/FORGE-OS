#!/usr/bin/env bash
set -euo pipefail

source /etc/os-release
[[ "${ID:-}" == arch ]] || { echo 'Arch Linux is required.' >&2; exit 1; }
[[ "$EUID" -ne 0 ]] || { echo 'Run configure-aur.sh as the desktop user; sudo is used only for system changes.' >&2; exit 77; }

TUIGREET_VERSION=0.11.0
TUIGREET_COMMIT=6fb15fffb794c6bd357164347d8b6d9e0aa92bbc
TUIGREET_REPOSITORY=https://github.com/tuigreet/tuigreet.git

install_aur_package() {
  local package="$1" temporary
  temporary="$(mktemp -d)"
  git clone --depth 1 "https://aur.archlinux.org/${package}.git" "$temporary/$package"
  (cd "$temporary/$package" && makepkg -si --needed --noconfirm)
  rm -rf -- "$temporary"
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

install_canonical_tuigreet() {
  local help_text current_version temporary head
  if [[ -x /usr/local/bin/tuigreet ]]; then
    help_text="$(/usr/local/bin/tuigreet --help 2>&1 || true)"
    current_version="$(/usr/local/bin/tuigreet --version 2>&1 | head -n1 || true)"
    if grep -Fq "$TUIGREET_VERSION" <<<"$current_version" && \
       grep -Fq -- '--background' <<<"$help_text" && \
       grep -Fq -- '--kb-background' <<<"$help_text" && \
       grep -Fq -- '--doom-height' <<<"$help_text" && \
       grep -Fq -- '--matrix-length' <<<"$help_text"; then
      echo "Canonical tuigreet $TUIGREET_VERSION is already installed."
      return
    fi
  fi

  command -v cargo >/dev/null 2>&1 || { echo 'Rust/cargo is required to build canonical tuigreet.' >&2; exit 69; }
  temporary="$(mktemp -d)"
  trap 'rm -rf -- "$temporary"' RETURN
  git clone --branch "$TUIGREET_VERSION" --depth 1 "$TUIGREET_REPOSITORY" "$temporary/tuigreet"
  head="$(git -C "$temporary/tuigreet" rev-parse HEAD)"
  [[ "$head" == "$TUIGREET_COMMIT" ]] || {
    echo "Refusing unexpected tuigreet source commit: $head" >&2
    exit 1
  }
  cargo build --locked --release --manifest-path "$temporary/tuigreet/Cargo.toml" -p tuigreet
  sudo install -o root -g root -m 0755 "$temporary/tuigreet/target/release/tuigreet" /usr/local/bin/tuigreet
  sudo install -d -o root -g root -m 0755 /usr/share/forge-os
  printf 'repository=%s\nversion=%s\ncommit=%s\n' "$TUIGREET_REPOSITORY" "$TUIGREET_VERSION" "$TUIGREET_COMMIT" | \
    sudo tee /usr/share/forge-os/tuigreet-source.env >/dev/null
  sudo chmod 0644 /usr/share/forge-os/tuigreet-source.env
  rm -rf -- "$temporary"
  trap - RETURN

  help_text="$(/usr/local/bin/tuigreet --help 2>&1 || true)"
  for option in --background --background-fps --kb-background --doom-height --doom-spread --doom-colors --matrix-length --matrix-speed --matrix-colors; do
    grep -Fq -- "$option" <<<"$help_text" || { echo "Canonical tuigreet is missing required option: $option" >&2; exit 1; }
  done
  /usr/local/bin/tuigreet --version 2>&1 | grep -Fq "$TUIGREET_VERSION" || { echo 'Canonical tuigreet version verification failed.' >&2; exit 1; }
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

# Remove obsolete distro/AUR tuigreet packages so the canonical pinned binary
# has one unambiguous owner in /usr/local/bin and cannot be shadowed by /usr/bin.
stale=()
for package in greetd-tuigreet greetd-tuigreet-fork-bin greetd-tuigreet-fork-bin-debug greetd-tuigreet-fork-git; do
  /usr/bin/pacman -Q "$package" >/dev/null 2>&1 && stale+=("$package")
done
if (( ${#stale[@]} > 0 )); then
  sudo /usr/bin/pacman -Rns --noconfirm "${stale[@]}"
fi

install_canonical_tuigreet
getent passwd greeter >/dev/null || { echo 'The greetd greeter account is missing.' >&2; exit 1; }
sudo install -d -o greeter -g greeter -m 0755 /var/cache/tuigreet
printf 'Community repositories ready: chaotic-aur=%s; yay=%s; tuigreet=%s\n' \
  "$(/usr/bin/pacman-conf --repo-list | grep -Fx chaotic-aur || printf disabled)" \
  "$(command -v yay)" \
  "$(/usr/local/bin/tuigreet --version 2>&1 | head -n1)"
