#!/usr/bin/env bash
set -euo pipefail
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/forge-os/desktop-backup"
backup="$state_dir/mimeapps.list"
target="${XDG_CONFIG_HOME:-$HOME/.config}/mimeapps.list"
[[ -r "$backup" ]] || { echo "No saved mimeapps.list backup exists beneath $state_dir; no change made." >&2; exit 1; }
install -D -m 0644 "$backup" "$target"
echo "Restored $target from $backup."
