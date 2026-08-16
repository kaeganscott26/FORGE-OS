#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: forge-workspace-bootstrap apt|kali|nix|all

Creates rootless, isolated compatibility environments. It never adds Debian,
Ubuntu, Kali, or Nix repositories to the Arch host package database.
EOF
}

[[ "$EUID" -ne 0 ]] || { echo 'Run as the signed-in user, not root.' >&2; exit 77; }
action="${1:-}"
[[ "$action" =~ ^(apt|kali|nix|all)$ ]] || { usage >&2; exit 64; }

ensure_box() {
  local name="$1" image="$2"
  command -v distrobox >/dev/null || { echo 'Install the declared distrobox package first.' >&2; exit 69; }
  command -v podman >/dev/null || { echo 'Install the declared podman package first.' >&2; exit 69; }
  if distrobox list --no-color 2>/dev/null | awk 'NR > 1 {print $3}' | grep -Fxq "$name"; then
    echo "$name already exists."
    return
  fi
  distrobox create --yes --name "$name" --image "$image"
  distrobox generate-entry "$name" >/dev/null 2>&1 || true
}

setup_nix() {
  command -v nix-env >/dev/null || { echo 'Install the declared nix package first.' >&2; exit 69; }
  pkexec /usr/bin/systemctl enable --now nix-daemon.service
  if ! nix-channel --list | awk '{print $1}' | grep -Fxq nixpkgs; then
    nix-channel --add https://channels.nixos.org/nixpkgs-unstable nixpkgs
  fi
  nix-channel --update nixpkgs
}

[[ "$action" == apt || "$action" == all ]] && ensure_box forge-apt docker.io/library/ubuntu:24.04
[[ "$action" == kali || "$action" == all ]] && ensure_box forge-kali docker.io/kalilinux/kali-rolling:latest
[[ "$action" == nix || "$action" == all ]] && setup_nix

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "${XDG_DATA_HOME:-$HOME/.local/share}/applications" >/dev/null 2>&1 || true
command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
echo "FORGE compatibility environment '$action' is ready."
