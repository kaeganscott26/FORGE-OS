#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_user="${FORGE_USER:-${SUDO_USER:-$USER}}"
target_home="$(getent passwd "$target_user" | cut -d: -f6)"
sudo rm -f /usr/local/bin/forge-session
if [[ -f "$target_home/.xinitrc" ]] && cmp -s "$target_home/.xinitrc" "$repository_root/session/xinitrc"; then
  rm -f "$target_home/.xinitrc"
else
  echo "Preserved non-matching $target_home/.xinitrc" >&2
fi
echo 'Removed the launcher. Packaged releases and workspace data were preserved.'
