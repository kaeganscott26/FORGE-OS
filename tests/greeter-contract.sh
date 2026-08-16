#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

grep -Fqx 'greetd' "$root/manifests/arch-packages.txt" || fail 'official package manifest does not declare greetd.'
if grep -Fqx 'greetd-tuigreet' "$root/manifests/arch-packages.txt"; then
  fail 'the inactive official greetd-tuigreet package must not replace the maintained Matrix-capable fork.'
fi
grep -Fq 'greetd-tuigreet-fork-bin' "$root/scripts/configure-aur.sh" || fail 'AUR bootstrap does not provision the maintained tuigreet fork.'

tuigreet_bin="${TUIGREET_BIN:-/usr/local/bin/tuigreet}"
[[ -x "$tuigreet_bin" ]] || tuigreet_bin="$(command -v tuigreet 2>/dev/null || true)"
[[ -n "$tuigreet_bin" && -x "$tuigreet_bin" ]] || fail 'maintained tuigreet fork is not installed.'

help_text="$("$tuigreet_bin" --help 2>&1 || true)"
[[ -n "$help_text" ]] || fail 'tuigreet --help returned no option contract.'
for fork_option in --background --background-fps --kb-background --doom-height --doom-spread --doom-colors --matrix-length --matrix-speed --matrix-colors; do
  grep -Fq -- "$fork_option" <<<"$help_text" || fail "installed tuigreet is not the required maintained fork; missing $fork_option."
done

extract_flags() {
  python - "$1" <<'PY'
import os
import shlex
import sys
import tomllib

with open(sys.argv[1], "rb") as handle:
    data = tomllib.load(handle)

command = data["default_session"]["command"]
args = shlex.split(command)
if not args or os.path.basename(args[0]) != "tuigreet":
    raise SystemExit(f"default_session command is not tuigreet: {command}")

if "--issue" in args and "--greeting" in args:
    raise SystemExit("tuigreet --issue and --greeting are mutually exclusive")

for token in args[1:]:
    if token.startswith("--"):
        print(token.split("=", 1)[0])
PY
}

option_supported() {
  local option="$1"
  grep -Fq -- "$option" <<<"$help_text"
}

for config in \
  "$root/config/greetd-config.toml" \
  "$root/config/forge-recovery-greetd.toml" \
  "$root/config/forge-live-greetd.toml"; do
  grep -Fq '/usr/local/bin/tuigreet' "$config" || fail "$config does not pin the verified maintained tuigreet binary."
  while IFS= read -r option; do
    option_supported "$option" || fail "$config uses unsupported option $option for $("$tuigreet_bin" --version 2>&1 | head -n1)."
  done < <(extract_flags "$config")
done

grep -Fq -- "--cmd '/usr/local/bin/forge-wayland-session'" "$root/config/greetd-config.toml" || fail 'production F2/default command is not the installed FORGE Wayland session.'
grep -Fq -- '--background matrix' "$root/config/greetd-config.toml" || fail 'Matrix is not the production default background.'
grep -Fq -- '--kb-background 4' "$root/config/greetd-config.toml" || fail 'F4 background selection is not configured.'
grep -Fq -- '--doom-height 7' "$root/config/greetd-config.toml" && grep -Fq -- '--doom-colors red,yellow,white' "$root/config/greetd-config.toml" || fail 'DOOM fire background tuning is missing.'
if grep -Fq -- '--remember-session' "$root/config/greetd-config.toml"; then
  fail 'production greeter remembers an old session and can override the canonical F2/default Wayland path.'
fi

grep -Fq -- "--cmd '/usr/local/bin/forge-recovery-session'" "$root/config/forge-recovery-greetd.toml" || fail 'recovery greeter lost the recovery session command.'
grep -Fq 'FORGE_LIVE_RECOVERY=1' "$root/config/forge-live-greetd.toml" || fail 'live greeter does not enter FORGE Live Recovery mode.'
grep -Fq -- '--background matrix' "$root/config/forge-live-greetd.toml" || fail 'live fallback greeter does not retain Matrix/F4 behavior.'

echo "PASS: Matrix default, F4 fire selector, canonical Wayland F2 path, and recovery profiles match $("$tuigreet_bin" --version 2>&1 | head -n1)."
