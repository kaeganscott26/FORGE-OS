#!/usr/bin/env bash
set -euo pipefail

forge_source="${1:-$HOME/FORGE}"
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
state_dir="$repository_root/build"
overlay="$repository_root/overlays/0001-polish-FORGE-OS-navigation-layout.patch"
[[ -d "$forge_source/.git" && -x "$forge_source/scripts/package-linux.sh" ]] || { echo "FORGE source/package script not found: $forge_source" >&2; exit 1; }
[[ "$(node --version)" == v22.* ]] || { echo "FORGE requires Node 22; found $(node --version)." >&2; exit 1; }
[[ -r "$overlay" ]] || { echo "FORGE-OS UI overlay is missing: $overlay" >&2; exit 1; }

mkdir -p "$state_dir"
commit="$(git -C "$forge_source" rev-parse HEAD)"
lock_sha="$(sha256sum "$forge_source/package-lock.json" | awk '{print $1}')"
overlay_sha="$(sha256sum "$overlay" | awk '{print $1}')"
staging="$(mktemp -d "$state_dir/forge-source.XXXXXX")"
cleanup() { rm -rf -- "$staging"; }
trap cleanup EXIT
git -C "$forge_source" archive "$commit" | tar -x -C "$staging"
patch --batch --forward -d "$staging" -p1 <"$overlay"
(cd "$staging" && ./scripts/package-linux.sh)

dist="$state_dir/forge-dist"
rm -rf -- "$dist"
mv "$staging/dist_electron" "$dist"

runtime="$dist/linux-unpacked"
binary=""
for candidate in "$runtime/forge" "$runtime/FORGE"; do [[ -x "$candidate" ]] && binary="$candidate" && break; done
[[ -n "$binary" ]] || { echo "Packaged executable is missing beneath $runtime" >&2; exit 1; }
artifact_sha="$(sha256sum "$binary" | awk '{print $1}')"
cat >"$state_dir/latest.env.tmp" <<EOF
FORGE_SOURCE_COMMIT=$commit
FORGE_LOCK_SHA256=$lock_sha
FORGE_OS_UI_OVERLAY_SHA256=$overlay_sha
FORGE_RUNTIME_PATH=$runtime
FORGE_EXECUTABLE_PATH=$binary
FORGE_EXECUTABLE_SHA256=$artifact_sha
EOF
mv "$state_dir/latest.env.tmp" "$state_dir/latest.env"
echo "Built FORGE $commit; executable SHA-256 $artifact_sha"
