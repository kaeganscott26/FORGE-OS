#!/usr/bin/env bash
set -euo pipefail

forge_source="${1:-$HOME/FORGE}"
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
state_dir="$repository_root/build"
mapfile -t overlays < <(find "$repository_root/overlays" -maxdepth 1 -type f -name '*.patch' -print | sort)
[[ -d "$forge_source/.git" && -x "$forge_source/scripts/package-linux.sh" ]] || { echo "FORGE source/package script not found: $forge_source" >&2; exit 1; }
[[ "$(node --version)" == v22.* ]] || { echo "FORGE requires Node 22; found $(node --version)." >&2; exit 1; }
(( ${#overlays[@]} > 0 )) || { echo "FORGE-OS overlays are missing beneath $repository_root/overlays" >&2; exit 1; }

mkdir -p "$state_dir"
commit="$(git -C "$forge_source" rev-parse HEAD)"
lock_sha="$(sha256sum "$forge_source/package-lock.json" | awk '{print $1}')"
overlay_sha="$(sha256sum "${overlays[@]}" | sha256sum | awk '{print $1}')"
staging="$(mktemp -d "$state_dir/forge-source.XXXXXX")"
cleanup() { rm -rf -- "$staging"; }
trap cleanup EXIT
git -C "$forge_source" archive "$commit" | tar -x -C "$staging"
for overlay in "${overlays[@]}"; do
  patch --batch --forward -d "$staging" -p1 <"$overlay"
done
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
