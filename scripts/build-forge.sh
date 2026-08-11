#!/usr/bin/env bash
set -euo pipefail

forge_source="${1:-$HOME/FORGE}"
state_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/build"
[[ -d "$forge_source/.git" && -x "$forge_source/scripts/package-linux.sh" ]] || { echo "FORGE source/package script not found: $forge_source" >&2; exit 1; }
[[ "$(node --version)" == v22.* ]] || { echo "FORGE requires Node 22; found $(node --version)." >&2; exit 1; }

mkdir -p "$state_dir"
commit="$(git -C "$forge_source" rev-parse HEAD)"
lock_sha="$(sha256sum "$forge_source/package-lock.json" | awk '{print $1}')"
(cd "$forge_source" && ./scripts/package-linux.sh)

runtime="$forge_source/dist_electron/linux-unpacked"
binary=""
for candidate in "$runtime/forge" "$runtime/FORGE"; do [[ -x "$candidate" ]] && binary="$candidate" && break; done
[[ -n "$binary" ]] || { echo "Packaged executable is missing beneath $runtime" >&2; exit 1; }
artifact_sha="$(sha256sum "$binary" | awk '{print $1}')"
cat >"$state_dir/latest.env.tmp" <<EOF
FORGE_SOURCE_COMMIT=$commit
FORGE_LOCK_SHA256=$lock_sha
FORGE_RUNTIME_PATH=$runtime
FORGE_EXECUTABLE_PATH=$binary
FORGE_EXECUTABLE_SHA256=$artifact_sha
EOF
mv "$state_dir/latest.env.tmp" "$state_dir/latest.env"
echo "Built FORGE $commit; executable SHA-256 $artifact_sha"
