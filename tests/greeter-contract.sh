#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# FORGE-OS currently declares Arch's official greetd-tuigreet package. Keep the
# production and recovery command lines inside that package's supported CLI.
grep -Fqx 'greetd-tuigreet' "$root/manifests/arch-packages.txt" || {
  echo 'FAIL: authoritative package manifest does not declare greetd-tuigreet.' >&2
  exit 1
}

fork_only_pattern='--background([ =]|$)|--background-fps|--matrix-|--doom-|--kb-background|--custom-title|--battery([ =]|$)'
for config in "$root/config/greetd-config.toml" "$root/config/forge-recovery-greetd.toml"; do
  if grep -Eq -- "$fork_only_pattern" "$config"; then
    echo "FAIL: $config contains tuigreet fork-only options while the manifest installs Arch greetd-tuigreet." >&2
    exit 1
  fi
done

grep -Fq "--cmd 'startplasma-wayland forge-wayland-session forge-wayland-client'" "$root/config/greetd-config.toml" || {
  echo 'FAIL: production greeter lost the canonical FORGE Wayland chain.' >&2
  exit 1
}

grep -Fq "--cmd '/usr/local/bin/forge-recovery-session'" "$root/config/forge-recovery-greetd.toml" || {
  echo 'FAIL: recovery greeter lost the recovery session command.' >&2
  exit 1
}

echo 'PASS: greetd/tuigreet configuration matches the declared package contract.'
