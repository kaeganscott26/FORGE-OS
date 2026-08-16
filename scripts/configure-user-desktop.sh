#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/forge-os/desktop-backup"
mimeapps="${XDG_CONFIG_HOME:-$HOME/.config}/mimeapps.list"
browser_desktop="${FORGE_BROWSER_DESKTOP:-chromium.desktop}"
file_manager_desktop="${FORGE_FILE_MANAGER_DESKTOP:-forge-explorer.desktop}"

[[ "$(id -u)" -ne 0 ]] || { echo 'Run this as the FORGE session user, not root.' >&2; exit 1; }
command -v xdg-mime >/dev/null
command -v xdg-settings >/dev/null
for desktop in "$browser_desktop" "$file_manager_desktop"; do
  [[ -r "/usr/share/applications/$desktop" || -r "$HOME/.local/share/applications/$desktop" ]] || { echo "Desktop entry not found: $desktop" >&2; exit 1; }
done

mkdir -p "$state_dir"
if [[ -e "$mimeapps" && ! -e "$state_dir/mimeapps.list" ]]; then
  cp -p "$mimeapps" "$state_dir/mimeapps.list"
fi
xdg-user-dirs-update
if command -v fish >/dev/null 2>&1 && [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v fish)" ]]; then
  command -v chsh >/dev/null 2>&1 && sudo chsh -s "$(command -v fish)" "$USER"
fi
fish_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fish"
mkdir -p "$fish_config_dir/conf.d"
install -m 0644 "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config/forge-dr460nized.fish" "$fish_config_dir/conf.d/forge-dr460nized.fish"
xdg-settings set default-web-browser "$browser_desktop"
for mime in x-scheme-handler/http x-scheme-handler/https text/html; do xdg-mime default "$browser_desktop" "$mime"; done
xdg-mime default "$file_manager_desktop" inode/directory
printf 'Configured browser %s and file manager %s. User backup: %s\n' "$browser_desktop" "$file_manager_desktop" "$state_dir"
