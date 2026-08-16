#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary="$(mktemp -d)"
cleanup() { rm -rf -- "$temporary"; }
trap cleanup EXIT

git_identity() {
  git -C "$1" config user.name 'FORGE Update Test'
  git -C "$1" config user.email 'forge-update-test@invalid.local'
}

create_fixture() {
  local name="$1" expected_url="$2"
  local seed="$temporary/seed-$name" bare="$temporary/$name.git" checkout="$temporary/checkout-$name" publisher="$temporary/publisher-$name"
  git init --quiet --initial-branch=main "$seed"
  git_identity "$seed"
  printf '%s\n' "$name baseline" >"$seed/state.txt"
  if [[ "$name" == FORGE-OS ]]; then
    install -d "$seed/scripts"
    printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail' '[[ "${FORGE_UPDATE_TEST_INSTALL_FAIL:-0}" != 1 ]] || exit 42' 'touch "$FORGE_UPDATE_TEST_MARKER"' >"$seed/scripts/install-forge-linux.sh"
    chmod 0755 "$seed/scripts/install-forge-linux.sh"
  fi
  git -C "$seed" add .
  git -C "$seed" commit --quiet -m 'initial fixture'
  git clone --quiet --bare "$seed" "$bare"
  git clone --quiet "$bare" "$checkout"
  git clone --quiet "$bare" "$publisher"
  git_identity "$checkout"
  git_identity "$publisher"

  # The test intentionally rewrites the trusted HTTPS origin to a local bare
  # repository. Modern Git correctly restricts local-file transport in nested
  # operations unless it is explicitly allowed. This opt-in applies only to
  # the disposable fixture; production updater origin policy remains HTTPS-only.
  git -C "$checkout" config protocol.file.allow always
  git -C "$publisher" config protocol.file.allow always
  git -C "$checkout" remote set-url origin "$expected_url"
  git -C "$checkout" config "url.file://$bare.insteadOf" "$expected_url"
}

publish_change() {
  local publisher="$1" label="$2"
  printf '%s\n' "$label" >>"$publisher/state.txt"
  git -C "$publisher" add state.txt
  git -C "$publisher" commit --quiet -m "$label"
  git -C "$publisher" push --quiet origin main
}

expect_failure() {
  local expected="$1"; shift
  set +e
  "$@" >"$temporary/failure.out" 2>"$temporary/failure.err"
  local status=$?
  set -e
  [[ "$status" -eq "$expected" ]] || {
    echo "Expected exit $expected, received $status" >&2
    sed -n '1,160p' "$temporary/failure.err" >&2
    exit 1
  }
}

forge="$temporary/checkout-FORGE"
forge_os="$temporary/checkout-FORGE-OS"
forge_publisher="$temporary/publisher-FORGE"
os_publisher="$temporary/publisher-FORGE-OS"
forge_url='https://github.com/kaeganscott26/FORGE.git'
os_url='https://github.com/kaeganscott26/FORGE-OS.git'
marker="$temporary/installed"

create_fixture FORGE "$forge_url"
create_fixture FORGE-OS "$os_url"

touch "$forge/dirty-untracked"
expect_failure 65 env HOME="$temporary" FORGE_SOURCE_DIR="$forge" FORGE_OS_SOURCE_DIR="$forge_os" FORGE_UPDATE_TEST_MARKER="$marker" "$root/scripts/forge-os-update"
rm "$forge/dirty-untracked"

git -C "$forge" config remote.origin.url 'https://untrusted.invalid/FORGE.git'
expect_failure 65 env HOME="$temporary" FORGE_SOURCE_DIR="$forge" FORGE_OS_SOURCE_DIR="$forge_os" FORGE_UPDATE_TEST_MARKER="$marker" "$root/scripts/forge-os-update"
git -C "$forge" config remote.origin.url "$forge_url"

publish_change "$forge_publisher" 'remote-divergence'
git -C "$forge" commit --quiet --allow-empty -m 'local divergence'
expect_failure 65 env HOME="$temporary" FORGE_SOURCE_DIR="$forge" FORGE_OS_SOURCE_DIR="$forge_os" FORGE_UPDATE_TEST_MARKER="$marker" "$root/scripts/forge-os-update"
git -C "$forge" fetch --quiet origin main
git -C "$forge" reset --quiet --hard origin/main

publish_change "$forge_publisher" 'transaction candidate'
publish_change "$os_publisher" 'transaction candidate'
forge_before="$(git -C "$forge" rev-parse HEAD)"
os_before="$(git -C "$forge_os" rev-parse HEAD)"
expect_failure 42 env HOME="$temporary" FORGE_SOURCE_DIR="$forge" FORGE_OS_SOURCE_DIR="$forge_os" FORGE_UPDATE_TEST_MARKER="$marker" FORGE_UPDATE_TEST_INSTALL_FAIL=1 "$root/scripts/forge-os-update"
[[ "$(git -C "$forge" rev-parse HEAD)" == "$forge_before" && "$(git -C "$forge_os" rev-parse HEAD)" == "$os_before" ]] || { echo 'Failed install did not restore both source commits.' >&2; exit 1; }
[[ ! -e "$marker" ]] || { echo 'Failed installer unexpectedly produced its success marker.' >&2; exit 1; }

env HOME="$temporary" FORGE_SOURCE_DIR="$forge" FORGE_OS_SOURCE_DIR="$forge_os" FORGE_UPDATE_TEST_MARKER="$marker" "$root/scripts/forge-os-update" >/dev/null
[[ -e "$marker" ]] || { echo 'Clean fast-forward update did not run the installer.' >&2; exit 1; }
[[ "$(git -C "$forge" rev-parse HEAD)" == "$(git -C "$forge" rev-parse origin/main)" && "$(git -C "$forge_os" rev-parse HEAD)" == "$(git -C "$forge_os" rev-parse origin/main)" ]] || { echo 'Clean update did not activate both origin/main commits.' >&2; exit 1; }

echo 'PASS: updater refuses dirty/untrusted/divergent input, rolls both sources back after installer failure, and completes a clean fast-forward update'
