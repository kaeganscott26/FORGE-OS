#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_record="$repository_root/build/latest.env"
[[ -r "$build_record" ]] || { echo 'Run scripts/build-forge.sh first.' >&2; exit 1; }
source "$build_record"
for name in FORGE_SOURCE_COMMIT FORGE_RUNTIME_PATH FORGE_EXECUTABLE_PATH FORGE_EXECUTABLE_SHA256; do
  [[ -n "${!name:-}" ]] || { echo "Missing $name in $build_record" >&2; exit 1; }
done
[[ -d "$FORGE_RUNTIME_PATH" ]] || { echo 'Recorded runtime is absent.' >&2; exit 1; }
actual_sha="$(sha256sum "$FORGE_EXECUTABLE_PATH" | awk '{print $1}')"
[[ "$actual_sha" == "$FORGE_EXECUTABLE_SHA256" ]] || { echo 'Runtime hash mismatch.' >&2; exit 1; }

release_dir="/opt/forge/releases/$FORGE_SOURCE_COMMIT"
sudo install -d -o root -g root -m 0755 /opt/forge/releases
if [[ ! -d "$release_dir" ]]; then
  sudo cp -a "$FORGE_RUNTIME_PATH" "$release_dir"
  sudo chown -R root:root "$release_dir"
fi
installed_binary="$release_dir/$(basename "$FORGE_EXECUTABLE_PATH")"
[[ "$(sha256sum "$installed_binary" | awk '{print $1}')" == "$FORGE_EXECUTABLE_SHA256" ]] || { echo 'Installed runtime hash mismatch.' >&2; exit 1; }
sudo ln -sfn "releases/$FORGE_SOURCE_COMMIT" /opt/forge/current
echo "Installed immutable runtime $release_dir"
