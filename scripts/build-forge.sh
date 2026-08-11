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
app_asar="$runtime/resources/app.asar"
[[ -r "$app_asar" ]] || { echo "Packaged app.asar is missing: $app_asar" >&2; exit 1; }
app_asar_sha="$(sha256sum "$app_asar" | awk '{print $1}')"
payload_sha="$(
  cd "$runtime"
  find . -type f -print0 | sort -z | xargs -0 sha256sum
  find . -type l -printf 'LINK %p %l\n' | LC_ALL=C sort
)"
payload_sha="$(printf '%s\n' "$payload_sha" | sha256sum | awk '{print $1}')"
runtime_id="${commit:0:12}-${overlay_sha:0:12}-${payload_sha:0:16}"
cat >"$state_dir/latest.env.tmp" <<EOF
FORGE_SOURCE_COMMIT=$commit
FORGE_LOCK_SHA256=$lock_sha
FORGE_OS_OVERLAY_SHA256=$overlay_sha
FORGE_RUNTIME_RELATIVE_PATH=build/forge-dist/linux-unpacked
FORGE_EXECUTABLE_RELATIVE_PATH=$(basename "$binary")
FORGE_EXECUTABLE_SHA256=$artifact_sha
FORGE_APP_ASAR_SHA256=$app_asar_sha
FORGE_PAYLOAD_SHA256=$payload_sha
FORGE_RUNTIME_ID=$runtime_id
EOF
mv "$state_dir/latest.env.tmp" "$state_dir/latest.env"
echo "Built FORGE runtime $runtime_id; app.asar SHA-256 $app_asar_sha"
