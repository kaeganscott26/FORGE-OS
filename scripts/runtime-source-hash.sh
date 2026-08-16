#!/usr/bin/env bash
set -euo pipefail

source_root="${1:?Usage: runtime-source-hash.sh FORGE_SOURCE}"
[[ -d "$source_root/apps/desktop/src" && -r "$source_root/package-lock.json" ]] || { echo 'Invalid FORGE source tree.' >&2; exit 66; }

cd "$source_root"
{
  for path in package.json package-lock.json tsconfig.json electron.vite.config.ts apps/desktop/electron.vite.config.ts; do
    [[ -f "$path" ]] || continue
    printf 'FILE %s\n' "$path"
    sha256sum "$path" | awk '{print $1}'
  done
  find apps/desktop/src apps/desktop/resources packages scripts -type f \
    ! -path '*/node_modules/*' \
    ! -path '*/out/*' \
    ! -path '*/dist/*' \
    -print0 | LC_ALL=C sort -z | while IFS= read -r -d '' path; do
      printf 'FILE %s\n' "$path"
      sha256sum "$path" | awk '{print $1}'
    done
} | sha256sum | awk '{print $1}'
