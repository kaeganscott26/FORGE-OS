#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
record="$root/build/latest.env"
[[ -r "$record" ]] || { echo 'Run scripts/build-forge.sh before the runtime lifecycle test.' >&2; exit 66; }
source "$record"

test_root="$(mktemp -d)"
runtime_root="$test_root/forge"
cleanup() { rm -rf -- "$test_root"; }
trap cleanup EXIT

FORGE_RUNTIME_ROOT="$runtime_root" "$root/scripts/install-runtime.sh" >/dev/null
current="$(readlink -f "$runtime_root/current")"
[[ -d "$current" && "$(basename "$current")" == "$FORGE_RUNTIME_ID" ]] || { echo 'Initial isolated runtime activation failed.' >&2; exit 1; }

previous="$runtime_root/releases/previous-known-good"
install -d "$previous/resources"
cp "$current/$FORGE_EXECUTABLE_RELATIVE_PATH" "$previous/$FORGE_EXECUTABLE_RELATIVE_PATH"
cp "$current/resources/app.asar" "$previous/resources/app.asar"
install -m 0644 "$record" "$previous/.forge-runtime.env"
ln -s "releases/$(basename "$previous")" "$runtime_root/last-known-good"

FORGE_RUNTIME_ROOT="$runtime_root" "$root/scripts/install-runtime.sh" >/dev/null
[[ -d "$previous" && "$(readlink -f "$runtime_root/last-known-good")" == "$previous" ]] || { echo 'Repeat activation removed the existing last-known-good runtime.' >&2; exit 1; }

printf '\0tamper' >>"$current/$FORGE_EXECUTABLE_RELATIVE_PATH"
FORGE_RUNTIME_ROOT="$runtime_root" "$root/scripts/install-runtime.sh" >/dev/null
current="$(readlink -f "$runtime_root/current")"
[[ "$(sha256sum "$current/$FORGE_EXECUTABLE_RELATIVE_PATH" | awk '{print $1}')" == "$FORGE_EXECUTABLE_SHA256" ]] || { echo 'A corrupt installed release was not replaced from verified build content.' >&2; exit 1; }

sudo env FORGE_RUNTIME_ROOT="$runtime_root" "$root/scripts/forge-runtime-rollback-activate" "$previous" "$current"
[[ "$(readlink -f "$runtime_root/current")" == "$previous" && ! -e "$current" ]] || { echo 'Rollback did not activate last-known-good and remove the superseded runtime.' >&2; exit 1; }

FORGE_RUNTIME_ROOT="$runtime_root" "$root/scripts/install-runtime.sh" >/dev/null
current="$(readlink -f "$runtime_root/current")"
[[ "$(basename "$current")" == "$FORGE_RUNTIME_ID" && -d "$previous" && "$(readlink -f "$runtime_root/last-known-good")" == "$previous" ]] || { echo 'Update after rollback did not recreate a conflict-free current/known-good pair.' >&2; exit 1; }

echo 'PASS: isolated install, repeat install, corrupt-runtime replacement, rollback, cleanup, and update-after-rollback lifecycle'
