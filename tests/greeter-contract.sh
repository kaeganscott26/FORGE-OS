#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $*" >&2; exit 1; }

grep -Fqx 'greetd' "$root/manifests/arch-packages.txt" || fail 'official package manifest does not declare greetd.'
if grep -Fqx 'greetd-tuigreet' "$root/manifests/arch-packages.txt"; then fail 'official legacy tuigreet package must not own the FORGE greeter binary.'; fi
grep -Fq 'TUIGREET_VERSION=0.11.0' "$root/scripts/configure-aur.sh" || fail 'canonical tuigreet version pin is missing.'
grep -Fq 'TUIGREET_COMMIT=6fb15fffb794c6bd357164347d8b6d9e0aa92bbc' "$root/scripts/configure-aur.sh" || fail 'canonical tuigreet commit pin is missing.'
grep -Fq 'https://github.com/tuigreet/tuigreet.git' "$root/scripts/configure-aur.sh" || fail 'canonical tuigreet repository is not configured.'

tuigreet_bin="${TUIGREET_BIN:-/usr/local/bin/tuigreet}"
[[ -x "$tuigreet_bin" ]] || tuigreet_bin="$(command -v tuigreet 2>/dev/null || true)"
[[ -n "$tuigreet_bin" && -x "$tuigreet_bin" ]] || fail 'canonical tuigreet binary is not installed.'
version_text="$("$tuigreet_bin" --version 2>&1 | head -n1 || true)"
grep -Fq '0.11.0' <<<"$version_text" || fail "expected canonical tuigreet 0.11.0, found: $version_text"
help_text="$("$tuigreet_bin" --help 2>&1 || true)"
for option in --background --background-fps --kb-background --doom-height --doom-spread --doom-colors --matrix-length --matrix-speed --matrix-colors; do
  grep -Fq -- "$option" <<<"$help_text" || fail "canonical tuigreet 0.11.0 is missing $option."
done

extract_flags() {
  python - "$1" <<'PY'
import os, shlex, sys, tomllib
with open(sys.argv[1], "rb") as handle: data = tomllib.load(handle)
args = shlex.split(data["default_session"]["command"])
if not args or os.path.basename(args[0]) != "tuigreet": raise SystemExit("default_session command is not tuigreet")
if "--issue" in args and "--greeting" in args: raise SystemExit("tuigreet --issue and --greeting are mutually exclusive")
for token in args[1:]:
    if token.startswith("--"): print(token.split("=", 1)[0])
PY
}
for config in "$root/config/greetd-config.toml" "$root/config/forge-recovery-greetd.toml" "$root/config/forge-live-greetd.toml"; do
  grep -Fq '/usr/local/bin/tuigreet' "$config" || fail "$config does not pin /usr/local/bin/tuigreet."
  while IFS= read -r option; do grep -Fq -- "$option" <<<"$help_text" || fail "$config uses unsupported option $option."; done < <(extract_flags "$config")
done

grep -Fq -- "--cmd '/usr/local/bin/forge-wayland-session'" "$root/config/greetd-config.toml" || fail 'F2/default command is wrong.'
grep -Fq -- '--background matrix' "$root/config/greetd-config.toml" || fail 'Matrix is not default.'
grep -Fq -- '--kb-background 4' "$root/config/greetd-config.toml" || fail 'F4 background selector is missing.'
grep -Fq -- '--doom-height 7' "$root/config/greetd-config.toml" && grep -Fq -- '--doom-colors red,yellow,white' "$root/config/greetd-config.toml" || fail 'DOOM fire tuning is missing.'
if grep -Fq -- '--remember-session' "$root/config/greetd-config.toml"; then fail 'remember-session can override canonical runtime path.'; fi
grep -Fq -- "--cmd '/usr/local/bin/forge-recovery-session'" "$root/config/forge-recovery-greetd.toml" || fail 'recovery command is wrong.'
grep -Fq 'FORGE_LIVE_RECOVERY=1' "$root/config/forge-live-greetd.toml" || fail 'live recovery flag is missing.'
echo "PASS: canonical tuigreet 0.11.0 supports Matrix, F4/DOOM, and the FORGE Wayland login contract."
