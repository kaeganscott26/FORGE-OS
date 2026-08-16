#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

grep -Fqx 'greetd-tuigreet' "$root/manifests/arch-packages.txt" || \
  fail 'authoritative package manifest does not declare greetd-tuigreet.'

command -v tuigreet >/dev/null 2>&1 || \
  fail 'tuigreet is not installed; greeter compatibility cannot be verified.'

help_text="$(tuigreet --help 2>&1 || true)"
[[ -n "$help_text" ]] || fail 'tuigreet --help returned no option contract.'

extract_flags() {
  python - "$1" <<'PY'
import shlex
import sys
import tomllib

with open(sys.argv[1], "rb") as handle:
    data = tomllib.load(handle)

command = data["default_session"]["command"]
args = shlex.split(command)
if not args or args[0] != "tuigreet":
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
  grep -Fq -- "$option" <<<"$help_text" && return 0

  case "$option" in
    --kb-command|--kb-sessions|--kb-power)
      grep -Fq -- '--kb-[command|sessions|power]' <<<"$help_text"
      ;;
    *)
      return 1
      ;;
  esac
}

for config in "$root/config/greetd-config.toml" "$root/config/forge-recovery-greetd.toml"; do
  while IFS= read -r option; do
    option_supported "$option" || \
      fail "$config uses unsupported option $option for $(tuigreet --version 2>&1 | head -n1)."
  done < <(extract_flags "$config")
done

grep -Fq -- "--cmd 'startplasma-wayland forge-wayland-session forge-wayland-client'" "$root/config/greetd-config.toml" || \
  fail 'production greeter lost the canonical FORGE Wayland chain.'

grep -Fq -- '--background matrix' "$root/config/greetd-config.toml" || \
  fail 'production greeter lost the persistent Matrix background.'

grep -Fq -- "--cmd '/usr/local/bin/forge-recovery-session'" "$root/config/forge-recovery-greetd.toml" || \
  fail 'recovery greeter lost the recovery session command.'

echo "PASS: greetd configuration matches $(tuigreet --version 2>&1 | head -n1)."
