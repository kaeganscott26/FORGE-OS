#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary="$(mktemp -d)"
trap 'rm -rf -- "$temporary"' EXIT
log="$temporary/calls"

make_mock() {
  local target="$1" name="$2"
  sed -e "s|@LOG@|$log|g" -e "s|@NAME@|$name|g" >"$target" <<'EOF'
#!/usr/bin/env bash
printf '%s' '@NAME@' >>'@LOG@'
for argument in "$@"; do printf ' <%s>' "$argument" >>'@LOG@'; done
printf '\nCHAIN=%s\n' "${FORGE_RUNTIME_CHAIN:-}" >>'@LOG@'
EOF
  chmod +x "$target"
}

make_mock "$temporary/forge" forge
make_mock "$temporary/plasma" plasma
run_dispatcher() {
  FORGE_SESSION_DISPATCH_TEST=1 \
  FORGE_TEST_FORGE_SESSION="$temporary/forge" \
  FORGE_TEST_PLASMA_SESSION="$temporary/plasma" \
    "$root/session/startplasma-wayland" "$@"
}

run_dispatcher forge-wayland-session forge-wayland-client
grep -Fx 'forge' "$log" >/dev/null
grep -Fx 'CHAIN=startplasma-wayland forge-wayland-session forge-wayland-client' "$log" >/dev/null
if grep -q '^plasma' "$log"; then echo 'Canonical chain reached the vendor Plasma entry point.' >&2; exit 1; fi

: >"$log"
run_dispatcher --replace example
grep -Fx 'plasma <--replace> <example>' "$log" >/dev/null
if grep -q '^forge' "$log"; then echo 'Non-canonical call reached FORGE.' >&2; exit 1; fi

: >"$log"
run_dispatcher forge-wayland-session || true
grep -Fx 'plasma <forge-wayland-session>' "$log" >/dev/null

echo 'PASS: canonical session dispatch is isolated and vendor fallback preserves arguments'
