#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
state_dir="$repository_root/build/user-desktop-backup"
mimeapps="${XDG_CONFIG_HOME:-$HOME/.config}/mimeapps.list"
browser_desktop="${FORGE_BROWSER_DESKTOP:-chromium.desktop}"
file_manager_desktop="${FORGE_FILE_MANAGER_DESKTOP:-thunar.desktop}"

[[ "$(id -u)" -ne 0 ]] || { echo 'Run this as the FORGE session user, not root.' >&2; exit 1; }
command -v xdg-mime >/dev/null
command -v xdg-settings >/dev/null
[[ -r "/usr/share/applications/$browser_desktop" || -r "$HOME/.local/share/applications/$browser_desktop" ]] || { echo "Desktop entry not found: $browser_desktop" >&2; exit 1; }

mkdir -p "$state_dir"
if [[ -e "$mimeapps" && ! -e "$state_dir/mimeapps.list" ]]; then cp -p "$mimeapps" "$state_dir/mimeapps.list"; fi
xdg-user-dirs-update
xdg-settings set default-web-browser "$browser_desktop"
for mime in x-scheme-handler/http x-scheme-handler/https text/html; do xdg-mime default "$browser_desktop" "$mime"; done
xdg-mime default "$file_manager_desktop" inode/directory
printf 'Configured browser %s and file manager %s. Backup: %s\n' "$browser_desktop" "$file_manager_desktop" "$state_dir"
