#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
runtime_root="$(realpath -m -- "${FORGE_RUNTIME_ROOT:-/opt/forge}")"
[[ "$runtime_root" != / && "$runtime_root" != "$HOME" ]] || { echo 'Unsafe FORGE runtime root.' >&2; exit 64; }
run_privileged() {
  if [[ "$runtime_root" == /opt/forge ]]; then sudo "$@"; else "$@"; fi
}
build_record="$repository_root/build/latest.env"
[[ -r "$build_record" ]] || { echo 'Run scripts/build-forge.sh first.' >&2; exit 1; }
source "$build_record"
for name in FORGE_SOURCE_COMMIT FORGE_VERSION FORGE_PACKAGE_SHA256 FORGE_LOCK_SHA256 FORGE_RUNTIME_SOURCE_SHA256 FORGE_OS_VERSION FORGE_OS_COMMIT FORGE_OS_OVERLAY_SHA256 FORGE_RUNTIME_RELATIVE_PATH FORGE_EXECUTABLE_RELATIVE_PATH FORGE_EXECUTABLE_SHA256 FORGE_APP_ASAR_SHA256 FORGE_PAYLOAD_SHA256 FORGE_RUNTIME_ID; do
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
[[ "$FORGE_OS_OVERLAY_SHA256" == "$(overlay_hash | sha256sum | awk '{print $1}')" ]] || { echo 'Build record overlay hash mismatch.' >&2; exit 1; }
runtime="$repository_root/$FORGE_RUNTIME_RELATIVE_PATH"
binary="$runtime/$FORGE_EXECUTABLE_RELATIVE_PATH"
[[ -d "$runtime" ]] || { echo 'Recorded runtime is absent.' >&2; exit 1; }
actual_sha="$(sha256sum "$binary" | awk '{print $1}')"
[[ "$actual_sha" == "$FORGE_EXECUTABLE_SHA256" ]] || { echo 'Runtime hash mismatch.' >&2; exit 1; }
[[ "$(sha256sum "$runtime/resources/app.asar" | awk '{print $1}')" == "$FORGE_APP_ASAR_SHA256" ]] || { echo 'app.asar hash mismatch.' >&2; exit 1; }
payload_hash() { (cd "$1"; { find . -type f ! -name .forge-runtime.env -print0 | sort -z | xargs -0 sha256sum; find . -type l -printf 'LINK %p %l\n' | LC_ALL=C sort; }) | sha256sum | awk '{print $1}'; }
[[ "$(payload_hash "$runtime")" == "$FORGE_PAYLOAD_SHA256" ]] || { echo 'Runtime payload hash mismatch.' >&2; exit 1; }

release_dir="$runtime_root/releases/$FORGE_RUNTIME_ID"
run_privileged install -d -m 0755 "$runtime_root/releases"
if [[ -e "$release_dir" && "$(payload_hash "$release_dir")" != "$FORGE_PAYLOAD_SHA256" ]]; then run_privileged mv "$release_dir" "$release_dir.stale.$(date +%s)"; fi
if [[ ! -d "$release_dir" ]]; then
  temporary="$runtime_root/releases/.${FORGE_RUNTIME_ID}.new.$$"
  run_privileged cp -a "$runtime" "$temporary"
  if [[ "$runtime_root" == /opt/forge ]]; then run_privileged chown -R root:root "$temporary"; fi
  run_privileged mv "$temporary" "$release_dir"
fi
installed_binary="$release_dir/$FORGE_EXECUTABLE_RELATIVE_PATH"
[[ "$(payload_hash "$release_dir")" == "$FORGE_PAYLOAD_SHA256" ]] || { echo 'Installed runtime payload mismatch.' >&2; exit 1; }
[[ "$(sha256sum "$installed_binary" | awk '{print $1}')" == "$FORGE_EXECUTABLE_SHA256" ]] || { echo 'Installed executable mismatch.' >&2; exit 1; }
[[ "$(sha256sum "$release_dir/resources/app.asar" | awk '{print $1}')" == "$FORGE_APP_ASAR_SHA256" ]] || { echo 'Installed app.asar mismatch.' >&2; exit 1; }
if [[ -f "$release_dir/chrome-sandbox" ]]; then
  if [[ "$runtime_root" == /opt/forge ]]; then run_privileged chown root:root "$release_dir/chrome-sandbox"; fi
  run_privileged chmod 4755 "$release_dir/chrome-sandbox"
fi
if [[ "$runtime_root" == /opt/forge ]]; then run_privileged install -o root -g root -m 0644 "$build_record" "$release_dir/.forge-runtime.env"; else install -m 0644 "$build_record" "$release_dir/.forge-runtime.env"; fi
previous_runtime="$(readlink -f "$runtime_root/current" 2>/dev/null || true)"
known_good="$(readlink -f "$runtime_root/last-known-good" 2>/dev/null || true)"
if [[ -n "$previous_runtime" && -d "$previous_runtime" && "$previous_runtime" != "$release_dir" ]]; then
  run_privileged ln -sfn "releases/$(basename "$previous_runtime")" "$runtime_root/last-known-good"
  known_good="$previous_runtime"
fi
run_privileged ln -sfn "releases/$FORGE_RUNTIME_ID" "$runtime_root/current"
for candidate in "$runtime_root"/releases/*; do
  [[ -d "$candidate" ]] || continue
  [[ "$candidate" == "$release_dir" || "$candidate" == "$known_good" ]] && continue
  run_privileged rm -rf -- "$candidate"
done
echo "Installed immutable runtime $release_dir"
