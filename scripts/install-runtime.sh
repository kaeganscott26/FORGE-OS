#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_record="$repository_root/build/latest.env"
[[ -r "$build_record" ]] || { echo 'Run scripts/build-forge.sh first.' >&2; exit 1; }
source "$build_record"
for name in FORGE_SOURCE_COMMIT FORGE_VERSION FORGE_PACKAGE_SHA256 FORGE_LOCK_SHA256 FORGE_OS_VERSION FORGE_OS_COMMIT FORGE_OS_OVERLAY_SHA256 FORGE_RUNTIME_RELATIVE_PATH FORGE_EXECUTABLE_RELATIVE_PATH FORGE_EXECUTABLE_SHA256 FORGE_APP_ASAR_SHA256 FORGE_PAYLOAD_SHA256 FORGE_RUNTIME_ID; do
  [[ -n "${!name:-}" ]] || { echo "Missing $name in $build_record" >&2; exit 1; }
done
overlay_hash() {
  local overlay relative
  while IFS= read -r overlay; do
    relative="${overlay#"$repository_root/"}"
    printf 'FILE %s\n' "$relative"
    sha256sum "$overlay" | awk '{print $1}'
  done < <(find "$repository_root/overlays" -maxdepth 1 -type f -name '*.patch' -print | sort)
}
[[ "$FORGE_OS_VERSION" == "$(<"$repository_root/VERSION")" ]] || { echo 'Build record FORGE-OS version mismatch.' >&2; exit 1; }
[[ "$FORGE_OS_COMMIT" == "$(git -C "$repository_root" rev-parse HEAD)" ]] || { echo 'Build record FORGE-OS commit mismatch.' >&2; exit 1; }
[[ "$FORGE_OS_OVERLAY_SHA256" == "$(overlay_hash | sha256sum | awk '{print $1}')" ]] || { echo 'Build record overlay hash mismatch.' >&2; exit 1; }
runtime="$repository_root/$FORGE_RUNTIME_RELATIVE_PATH"
binary="$runtime/$FORGE_EXECUTABLE_RELATIVE_PATH"
[[ -d "$runtime" ]] || { echo 'Recorded runtime is absent.' >&2; exit 1; }
actual_sha="$(sha256sum "$binary" | awk '{print $1}')"
[[ "$actual_sha" == "$FORGE_EXECUTABLE_SHA256" ]] || { echo 'Runtime hash mismatch.' >&2; exit 1; }
[[ "$(sha256sum "$runtime/resources/app.asar" | awk '{print $1}')" == "$FORGE_APP_ASAR_SHA256" ]] || { echo 'app.asar hash mismatch.' >&2; exit 1; }
payload_hash() { (cd "$1"; { find . -type f ! -name .forge-runtime.env -print0 | sort -z | xargs -0 sha256sum; find . -type l -printf 'LINK %p %l\n' | LC_ALL=C sort; }) | sha256sum | awk '{print $1}'; }
[[ "$(payload_hash "$runtime")" == "$FORGE_PAYLOAD_SHA256" ]] || { echo 'Runtime payload hash mismatch.' >&2; exit 1; }

release_dir="/opt/forge/releases/$FORGE_RUNTIME_ID"
sudo install -d -o root -g root -m 0755 /opt/forge/releases
if [[ -e "$release_dir" && "$(payload_hash "$release_dir")" != "$FORGE_PAYLOAD_SHA256" ]]; then sudo mv "$release_dir" "$release_dir.stale.$(date +%s)"; fi
if [[ ! -d "$release_dir" ]]; then
  temporary="/opt/forge/releases/.${FORGE_RUNTIME_ID}.new.$$"
  sudo cp -a "$runtime" "$temporary"
  sudo chown -R root:root "$temporary"
  sudo mv "$temporary" "$release_dir"
fi
installed_binary="$release_dir/$FORGE_EXECUTABLE_RELATIVE_PATH"
[[ "$(payload_hash "$release_dir")" == "$FORGE_PAYLOAD_SHA256" ]] || { echo 'Installed runtime payload mismatch.' >&2; exit 1; }
[[ "$(sha256sum "$installed_binary" | awk '{print $1}')" == "$FORGE_EXECUTABLE_SHA256" ]] || { echo 'Installed executable mismatch.' >&2; exit 1; }
[[ "$(sha256sum "$release_dir/resources/app.asar" | awk '{print $1}')" == "$FORGE_APP_ASAR_SHA256" ]] || { echo 'Installed app.asar mismatch.' >&2; exit 1; }
if [[ -f "$release_dir/chrome-sandbox" ]]; then sudo chown root:root "$release_dir/chrome-sandbox"; sudo chmod 4755 "$release_dir/chrome-sandbox"; fi
sudo install -o root -g root -m 0644 "$build_record" "$release_dir/.forge-runtime.env"
sudo ln -sfn "releases/$FORGE_RUNTIME_ID" /opt/forge/current
echo "Installed immutable runtime $release_dir"
