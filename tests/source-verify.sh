#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
forge_source="${FORGE_SOURCE:-$HOME/FORGE}"
failures=0
pass() { printf 'PASS: %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; failures=$((failures + 1)); }
check() { if "$@" >/dev/null 2>&1; then pass "$*"; else fail "$*"; fi; }

while IFS= read -r file; do check bash -n "$file"; done < <(find "$root/scripts" "$root/session" "$root/tests" -maxdepth 1 -type f -exec awk 'NR == 1 && /bash/ { print FILENAME; exit }' {} \; | sort)
check bash -n "$root/install.sh"
check bash -n "$root/update.sh"
check "$root/tests/session-dispatcher.sh"
check "$root/tests/update-transaction.sh"
check "$root/tests/greeter-contract.sh"
check python -c 'import tomllib,sys; [tomllib.load(open(p, "rb")) for p in sys.argv[1:]]' "$root/config/greetd-config.toml" "$root/config/forge-recovery-greetd.toml" "$root/config/forge-live-greetd.toml"
check systemd-analyze verify "$root/config/forge-recovery.service"
grep -Fqx 'Alias=autovt@tty2.service' "$root/config/forge-recovery.service" && pass 'recovery is an on-demand tty2 alias' || fail 'recovery unit is not bound to on-demand tty2 activation'
if grep -Fq 'WantedBy=graphical.target' "$root/config/forge-recovery.service"; then fail 'recovery is still pulled into every graphical boot'; else pass 'recovery is not pulled into graphical.target'; fi
grep -Fqx 'ExecStart=/usr/local/libexec/forge-live-setup' "$root/config/forge-live-setup.service" && pass 'live account setup unit has fixed executable' || fail 'live account setup unit is malformed'
grep -Fq 'FORGE_LIVE_RECOVERY=1' "$root/config/forge-live-greetd.toml" && pass 'live greeter enters the recovery GUI mode' || fail 'live greeter does not set recovery GUI mode'
grep -Fq 'NOPASSWD: ALL' "$root/scripts/forge-live-setup" && grep -Fq 'detected an installed system' "$root/scripts/forge-live-setup" && pass 'passwordless sudo is scoped to detected live media' || fail 'live sudo boundary is not explicitly isolated from installed systems'
grep -Fq 'forge-live-install' "$root/scripts/forge-live-setup" && grep -Fq 'forge-live-select-installer' "$root/scripts/forge-live-setup" && pass 'live setup installs recovery bundle helpers from the ISO repository payload' || fail 'live setup does not install the recovery helpers'
if command -v desktop-file-validate >/dev/null 2>&1; then
  while IFS= read -r desktop; do check desktop-file-validate "$desktop"; done < <(find "$root/session" -maxdepth 1 -name '*.desktop' -type f | sort)
fi
[[ "$(grep -Fc -- "--cmd '/usr/local/bin/forge-wayland-session'" "$root/config/greetd-config.toml")" == 1 ]] && pass 'greetd contains the last-good installed Wayland session path once' || fail 'greetd last-good Wayland session path is missing or ambiguous'
if grep -Eq -- '--background([ =]|$)|--matrix-|--kb-background|--remember-session' "$root/config/greetd-config.toml"; then fail 'normal greetd profile contains post-last-good login behavior'; else pass 'normal greetd profile preserves pre-Matrix login behavior'; fi
grep -Fqx 'Exec=startplasma-wayland forge-wayland-session forge-wayland-client' "$root/session/forge.desktop" && pass 'desktop session compatibility entry keeps the canonical chain' || fail 'desktop session canonical chain is wrong'
grep -Fq 'exec "$forge_session"' "$root/session/startplasma-wayland" && pass 'FORGE dispatcher still owns the compatibility desktop session' || fail 'FORGE dispatcher ownership is missing'
for required in fish starship reflector sudo distrobox podman nix ollama ollama-vulkan gamescope gamemode mangohud wine-staging; do grep -Fqx "$required" "$root/manifests/arch-packages.txt" && pass "manifest declares $required" || fail "manifest is missing $required"; done
grep -Fq '/usr/bin/pacman-conf --repo-list | grep -Fxq multilib' "$root/scripts/bootstrap-forgeos.sh" && pass 'bootstrap enables official multilib when needed' || fail 'bootstrap does not enable multilib for Steam compatibility'
grep -Fq '/usr/bin/pacman-conf --config "$profile/pacman.conf" --repo-list | grep -Fxq multilib' "$root/scripts/build-iso.sh" && pass 'ISO validates its multilib repository' || fail 'ISO does not validate multilib availability'
grep -Fq 'sudo rm -rf -- "$profile" "$work"' "$root/scripts/build-iso.sh" && pass 'ISO repeat-build cleanup handles constrained root-owned state' || fail 'ISO cleanup cannot safely remove prior mkarchiso state'
grep -Fq 'awk -v mirror_file="$root/config/mirrorlist"' "$root/scripts/build-iso.sh" && pass 'ISO build uses tracked mirrors independently of host state' || fail 'ISO build still depends on the host mirrorlist'
grep -Fq 'repository_servers="$(/usr/bin/pacman-conf' "$root/scripts/build-iso.sh" && pass 'ISO mirror validation avoids pipefail SIGPIPE false negatives' || fail 'ISO mirror validation can fail on a valid server list'
grep -Fq 'tool_source="$root/scripts/forge-workspace-bootstrap.sh"' "$root/scripts/build-iso.sh" && pass 'ISO maps workspace bootstrap source to installed command' || fail 'ISO workspace bootstrap source path is wrong'
grep -Fq 'record_overlay_executable_permissions' "$root/scripts/build-iso.sh" && pass 'ISO records every executable overlay permission' || fail 'ISO can flatten executable overlay modes'
grep -Fq 'verify_squashfs_executables' "$root/scripts/build-iso.sh" && pass 'ISO verifies critical executable modes after SquashFS creation' || fail 'ISO does not verify packaged executable modes'
grep -Fq '"$root/scripts/bootstrap-forgeos.sh"' "$root/scripts/install-forge-linux.sh" && pass 'installer executes bootstrap when packages are not skipped' || fail 'bootstrap is orphaned from the installer'
grep -Fq '"$root/scripts/build-forge.sh"' "$root/scripts/install-forge-linux.sh" && pass 'installer executes the FORGE build stage' || fail 'build-forge is orphaned from the installer'
grep -Fq '"$root/scripts/install-runtime.sh"' "$root/scripts/install-forge-linux.sh" && pass 'installer executes runtime installation' || fail 'install-runtime is orphaned from the installer'
grep -Fq 'tool_source="$root/scripts/forge-workspace-bootstrap.sh"' "$root/scripts/install-forge-linux.sh" && pass 'installer maps workspace bootstrap source to installed command' || fail 'installer workspace bootstrap source path is wrong'
[[ -r "$root/config/forge-starship.toml" ]] && grep -Fq 'STARSHIP_CONFIG /usr/share/forge-os/forge-starship.toml' "$root/config/forge-dr460nized.fish" && pass 'FORGE Fish profile selects the packaged Starship theme' || fail 'Fish/Starship theme wiring is incomplete'
grep -Fq "emitRuntimeEvent('context.invalidated'" "$forge_source/apps/desktop/src/main/index.ts" && pass 'workspace watcher invalidates indexed context automatically' || fail 'automatic workspace context invalidation is missing'
grep -Fq 'liveRecoveryMode' "$forge_source/packages/os-integration/src/index.ts" && grep -Fq 'FORGE Live Recovery' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" && pass 'FORGE contains the dedicated live recovery GUI mode' || fail 'FORGE live recovery GUI mode is missing'
grep -Fq 'forge-live-root-shell.desktop' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" && grep -Fq 'forge-live-installer.desktop' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" && pass 'live recovery GUI exposes privileged shell and bundle installation launchers' || fail 'live recovery GUI launchers are incomplete'
if [[ -r "$forge_source/apps/desktop/resources/ollama/skills.json" ]]; then
  [[ -r "$forge_source/apps/desktop/resources/ollama/skills/local-model-tooling/SKILL.md" ]] &&
    grep -Fq 'local-model-tooling' "$forge_source/apps/desktop/resources/ollama/skills.json" &&
    pass 'optional Ollama local-model tooling bundle is internally consistent' ||
    fail 'optional Ollama local-model tooling bundle is incomplete'
else
  pass 'optional Ollama-local skill bundle is absent from FORGE'
fi
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
