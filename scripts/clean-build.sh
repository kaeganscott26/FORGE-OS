#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build="$root/build"
mkdir -p "$build"
[[ "$(realpath -m "$build")" == "$root/build" ]] || { echo 'Unsafe build path.' >&2; exit 1; }
for target in "$build/archiso-profile" "$build/archiso-work" "$build/iso" "$build/forge-dist" "$build/latest.env" "$build/user-desktop-backup"; do
  [[ "$target" == "$build/"* ]] || { echo "Refusing path outside build directory: $target" >&2; exit 1; }
  if [[ -e "$target" || -L "$target" ]]; then
    sudo rm -rf -- "$target"
    echo "Removed generated build state: ${target#"$root/"}"
  fi
done
find "$build" -maxdepth 1 -type f -name 'forge-source.*' -writable -delete
echo 'FORGE-OS generated build state is clean.'
