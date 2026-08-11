#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_user="${FORGE_USER:-${SUDO_USER:-$USER}}"
target_home="$(getent passwd "$target_user" | cut -d: -f6)"
[[ -n "$target_home" && -d "$target_home" && "$target_user" != root ]] || { echo "Invalid session user: $target_user" >&2; exit 1; }
sudo install -o root -g root -m 0755 "$repository_root/session/forge-session" /usr/local/bin/forge-session
sudo install -o "$target_user" -g "$(id -gn "$target_user")" -m 0755 "$repository_root/session/xinitrc" "$target_home/.xinitrc"
install -d -m 0700 "$target_home/.local/state/forge"
echo 'Session installed. Run startx manually; login autostart remains disabled pending acceptance.'
