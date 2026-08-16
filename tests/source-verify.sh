#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
forge_source="${FORGE_SOURCE:-$HOME/FORGE}"
failures=0
pass() { printf 'PASS: %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; failures=$((failures + 1)); }
check() { if "$@" >/dev/null 2>&1; then pass "$*"; else fail "$*"; fi; }

while IFS= read -r file; do check bash -n "$file"; done < <(find "$root/scripts" "$root/session" "$root/tests" -maxdepth 1 -type f -exec awk 'NR == 1 && /bash/ { print FILENAME; exit }' {} \; | sort)
check "$root/tests/session-dispatcher.sh"
check "$root/tests/update-transaction.sh"
check python -c 'import tomllib,sys; tomllib.load(open(sys.argv[1], "rb")); tomllib.load(open(sys.argv[2], "rb"))' "$root/config/greetd-config.toml" "$root/config/forge-recovery-greetd.toml"
check systemd-analyze verify "$root/config/forge-recovery.service"
grep -Fqx 'ExecStart=/usr/local/libexec/forge-live-setup' "$root/config/forge-live-setup.service" && pass 'live account setup unit has fixed executable' || fail 'live account setup unit is malformed'
if command -v desktop-file-validate >/dev/null 2>&1; then
  while IFS= read -r desktop; do check desktop-file-validate "$desktop"; done < <(find "$root/session" -maxdepth 1 -name '*.desktop' -type f | sort)
fi
[[ "$(grep -Fc 'startplasma-wayland forge-wayland-session forge-wayland-client' "$root/config/greetd-config.toml")" == 1 ]] && pass 'greetd contains the exact canonical chain once' || fail 'greetd canonical chain is missing or ambiguous'
grep -Fqx 'Exec=startplasma-wayland forge-wayland-session forge-wayland-client' "$root/session/forge.desktop" && pass 'desktop session has exact canonical chain' || fail 'desktop session canonical chain is wrong'
grep -Fq 'exec "$forge_session"' "$root/session/startplasma-wayland" && pass 'FORGE dispatcher owns canonical session' || fail 'FORGE dispatcher ownership is missing'
for required in fish starship reflector distrobox podman nix ollama ollama-vulkan gamescope gamemode mangohud wine-staging; do grep -Fqx "$required" "$root/manifests/arch-packages.txt" && pass "manifest declares $required" || fail "manifest is missing $required"; done
grep -Fq '/usr/bin/pacman-conf --repo-list | grep -Fxq multilib' "$root/scripts/bootstrap-forgeos.sh" && pass 'bootstrap enables official multilib when needed' || fail 'bootstrap does not enable multilib for Steam compatibility'
grep -Fq '/usr/bin/pacman-conf --config "$profile/pacman.conf" --repo-list | grep -Fxq multilib' "$root/scripts/build-iso.sh" && pass 'ISO validates its multilib repository' || fail 'ISO does not validate multilib availability'
grep -Fq 'sudo rm -rf -- "$profile" "$work"' "$root/scripts/build-iso.sh" && pass 'ISO repeat-build cleanup handles constrained root-owned state' || fail 'ISO cleanup cannot safely remove prior mkarchiso state'
grep -Fq 'awk -v mirror_file="$root/config/mirrorlist"' "$root/scripts/build-iso.sh" && pass 'ISO build uses tracked mirrors independently of host state' || fail 'ISO build still depends on the host mirrorlist'
grep -Fq 'repository_servers="$(/usr/bin/pacman-conf' "$root/scripts/build-iso.sh" && pass 'ISO mirror validation avoids pipefail SIGPIPE false negatives' || fail 'ISO mirror validation can fail on a valid server list'
grep -Fq 'tool_source="$root/scripts/forge-workspace-bootstrap.sh"' "$root/scripts/build-iso.sh" && pass 'ISO maps workspace bootstrap source to installed command' || fail 'ISO workspace bootstrap source path is wrong'
grep -Fq 'tool_source="$root/scripts/forge-workspace-bootstrap.sh"' "$root/scripts/install-forge-linux.sh" && pass 'installer maps workspace bootstrap source to installed command' || fail 'installer workspace bootstrap source path is wrong'
[[ -r "$root/config/forge-starship.toml" ]] && grep -Fq 'STARSHIP_CONFIG /usr/share/forge-os/forge-starship.toml' "$root/config/forge-dr460nized.fish" && pass 'FORGE Fish profile selects the packaged Starship theme' || fail 'Fish/Starship theme wiring is incomplete'
grep -Fq "emitRuntimeEvent('context.invalidated'" "$forge_source/apps/desktop/src/main/index.ts" && pass 'workspace watcher invalidates indexed context automatically' || fail 'automatic workspace context invalidation is missing'
[[ -r "$forge_source/apps/desktop/resources/ollama/skills/local-model-tooling/SKILL.md" ]] && grep -Fq 'local-model-tooling' "$forge_source/apps/desktop/resources/ollama/skills.json" && pass 'Ollama local-model tooling skill is packaged' || fail 'Ollama tooling parity skill is missing'
duplicates="$(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$root/manifests/arch-packages.txt" | sort | uniq -d)"
[[ -z "$duplicates" ]] && pass 'package manifest has no duplicates' || fail "package manifest duplicates: $duplicates"
if command -v pacman >/dev/null 2>&1; then mapfile -t packages < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$root/manifests/arch-packages.txt"); check pacman -Sp --needed --print-format '%n' "${packages[@]}"; fi
check "$root/scripts/runtime-source-hash.sh" "$forge_source"
check npm --prefix "$forge_source" run typecheck
check npm --prefix "$forge_source" run lint
check npm --prefix "$forge_source" test
check npm --prefix "$forge_source" run build
git -C "$root" diff --check >/dev/null && pass 'FORGE-OS diff whitespace is valid' || fail 'FORGE-OS diff contains whitespace errors'
git -C "$forge_source" diff --check >/dev/null && pass 'FORGE diff whitespace is valid' || fail 'FORGE diff contains whitespace errors'
printf 'SOURCE SUMMARY: %d failure(s)\n' "$failures"
(( failures == 0 ))
