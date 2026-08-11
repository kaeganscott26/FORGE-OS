#!/usr/bin/env bash
set -euo pipefail
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backup="$repository_root/build/user-desktop-backup/mimeapps.list"
target="${XDG_CONFIG_HOME:-$HOME/.config}/mimeapps.list"
[[ -r "$backup" ]] || { echo 'No saved mimeapps.list backup exists; no change made.' >&2; exit 1; }
install -D -m 0644 "$backup" "$target"
echo "Restored $target from the FORGE-OS backup."
