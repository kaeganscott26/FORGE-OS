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
check systemd-analyze verify "$root/config/forge-live-setup.service"

grep -Fq -- "--cmd '/usr/local/bin/forge-wayland-session'" "$root/config/greetd-config.toml" && pass 'F2/default command is canonical Wayland path' || fail 'F2/default command is wrong'
grep -Fq -- '--background matrix' "$root/config/greetd-config.toml" && grep -Fq -- '--kb-background 4' "$root/config/greetd-config.toml" && pass 'Matrix default and F4 background selector are configured' || fail 'Matrix/F4 greeter behavior is incomplete'
grep -Fq -- '--doom-height 7' "$root/config/greetd-config.toml" && pass 'DOOM fire tuning is configured for F4' || fail 'DOOM fire configuration is missing'
if grep -Fq -- '--remember-session' "$root/config/greetd-config.toml"; then fail 'greeter can remember and override an old session path'; else pass 'greeter cannot override canonical path with remembered session'; fi
grep -Fqx 'Exec=/usr/local/bin/forge-wayland-session' "$root/session/forge.desktop" && pass 'F3 FORGE entry uses canonical Wayland path' || fail 'F3 FORGE entry exposes a stale dispatcher path'
grep -Fq 'exec "$forge_session"' "$root/session/startplasma-wayland" && pass 'legacy dispatcher remains available only as compatibility implementation' || fail 'compatibility dispatcher is broken'

grep -Fqx 'Alias=autovt@tty2.service' "$root/config/forge-recovery.service" && pass 'recovery is on-demand tty2 alias' || fail 'recovery alias is wrong'
if grep -Fq 'WantedBy=graphical.target' "$root/config/forge-recovery.service"; then fail 'recovery is pulled into every graphical boot'; else pass 'recovery remains on-demand'; fi
grep -Fq 'FORGE_LIVE_RECOVERY=1' "$root/config/forge-live-greetd.toml" && pass 'live greeter enters dedicated recovery GUI' || fail 'live recovery flag is missing'
grep -Fq 'passwd --lock "$live_user"' "$root/scripts/forge-live-setup" && grep -Fq 'NOPASSWD: ALL' "$root/scripts/forge-live-setup" && pass 'live account is locked and sudo is explicitly live-scoped' || fail 'live account privilege boundary is wrong'
grep -Fq 'forge-live-install' "$root/scripts/build-iso.sh" && grep -Fq 'forge-live-select-installer' "$root/scripts/build-iso.sh" && pass 'ISO contains live recovery bundle helpers' || fail 'ISO omits live recovery helpers'

if command -v desktop-file-validate >/dev/null 2>&1; then
  while IFS= read -r desktop; do check desktop-file-validate "$desktop"; done < <(find "$root/session" -maxdepth 1 -name '*.desktop' -type f | sort)
fi

for required in rust fish starship reflector pacman-contrib sudo partitionmanager plasma-firewall firewalld distrobox podman nix ollama ollama-vulkan gamescope gamemode mangohud wine-staging; do
  grep -Fqx "$required" "$root/manifests/arch-packages.txt" && pass "manifest declares $required" || fail "manifest is missing $required"
done
if grep -Fqx greetd-tuigreet "$root/manifests/arch-packages.txt"; then fail 'inactive official tuigreet package remains in official manifest'; else pass 'official manifest defers tuigreet to maintained AUR fork'; fi
grep -Fq 'greetd-tuigreet-fork-git' "$root/scripts/configure-aur.sh" && pass 'AUR bootstrap installs rolling maintained tuigreet fork' || fail 'rolling maintained tuigreet fork is not provisioned'
grep -Fq 'greetd-tuigreet-fork-bin' "$root/scripts/configure-aur.sh" && pass 'bootstrap explicitly removes stale tagged fork package when needed' || fail 'stale tagged fork migration is missing'
grep -Fq 'chaotic-aur' "$root/scripts/configure-aur.sh" && grep -Fq '3056513887B78AEB' "$root/scripts/configure-aur.sh" && pass 'Chaotic-AUR repository bootstrap is explicit and pinned to primary key' || fail 'Chaotic-AUR bootstrap is incomplete'
grep -Fq 'yay-bin' "$root/scripts/configure-aur.sh" && pass 'AUR helper is provisioned' || fail 'AUR helper is missing'
grep -Fq 'install_reference_mirrors' "$root/scripts/bootstrap-forgeos.sh" && grep -Fq 'refresh_ranked_mirrors' "$root/scripts/bootstrap-forgeos.sh" && pass 'bootstrap uses tracked mirror baseline plus reflector ranking' || fail 'mirror bootstrap is incomplete'
grep -Fq 'reflector.timer' "$root/scripts/configure-hardware.sh" && grep -Fq '/etc/xdg/reflector/reflector.conf' "$root/scripts/configure-hardware.sh" && pass 'reflector refresh persists after reboot' || fail 'persistent mirror refresh is missing'

for unit in NetworkManager.service bluetooth.service irqbalance.service systemd-timesyncd.service cups.service; do
  grep -Fq "$unit" "$root/scripts/configure-hardware.sh" && pass "service policy includes $unit" || fail "service policy missing $unit"
done
for unit in pipewire.socket pipewire-pulse.socket wireplumber.service; do
  grep -Fq "$unit" "$root/scripts/configure-hardware.sh" && pass "user service policy includes $unit" || fail "user service policy missing $unit"
done
grep -Fq 'systemctl --global enable' "$root/scripts/configure-hardware.sh" && pass 'user audio service enablement persists across sessions' || fail 'global user service enablement is missing'

grep -Fq 'function pacman' "$root/config/forge-dr460nized.fish" && grep -Fq '/usr/local/bin/forge-install-pkg --backend arch' "$root/config/forge-dr460nized.fish" && pass 'interactive pacman routes through FORGE' || fail 'interactive pacman bypasses FORGE wrapper'
grep -Fq 'exec /usr/local/bin/forge-app-install -S' "$root/scripts/forge-install-program" && pass 'program install routes through forge-app-install' || fail 'program install routing is broken'
grep -Fq '/usr/local/bin/forge-install-pkg "$@"' "$root/scripts/forge-app-install" && pass 'app install routes through forge-install-pkg' || fail 'app install routing is broken'
grep -Fq 'exec pkexec /usr/bin/pacman "$@"' "$root/scripts/forge-install-pkg" && pass 'Arch mutations cross PolicyKit wrapper' || fail 'Arch package mutation boundary is missing'

for stage in bootstrap-forgeos.sh configure-hardware.sh build-forge.sh install-runtime.sh configure-user-desktop.sh; do
  grep -Fq "$stage" "$root/scripts/install-forge-linux.sh" && pass "installer retains stage $stage" || fail "installer orphaned stage $stage"
done
grep -Fq 'forge-system-surface' "$root/scripts/install-forge-linux.sh" && grep -Fq 'forge-session-control' "$root/scripts/install-forge-linux.sh" && pass 'installer deploys system/session helpers' || fail 'installer omits system/session helpers'
grep -Fq 'forge-internal-' "$root/scripts/install-forge-linux.sh" && pass 'installer deploys hidden internal launcher contract' || fail 'internal launcher deployment is missing'
grep -Fq 'find /var/cache/tuigreet' "$root/scripts/install-forge-linux.sh" && pass 'installer clears stale greeter command/session cache' || fail 'stale greeter paths can survive install'
grep -Fq 'readlink -f /usr/local/bin/tuigreet' "$root/scripts/build-iso.sh" && pass 'ISO embeds verified maintained tuigreet binary' || fail 'ISO can package wrong tuigreet binary'
grep -Fq 'record_overlay_executable_permissions' "$root/scripts/build-iso.sh" && grep -Fq 'verify_squashfs_executables' "$root/scripts/build-iso.sh" && pass 'ISO preserves and verifies executable modes' || fail 'ISO executable verification is incomplete'

grep -Fq "['Network', 'network']" "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" && grep -Fq "['Advanced', 'advanced']" "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" && pass 'top bar declares complete quick system surface range' || fail 'top bar system surface range is incomplete'
grep -Fq 'forge-internal-session-logout.desktop' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" && grep -Fq 'forge-internal-session-shutdown.desktop' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" && pass 'session UI uses detached OS helpers' || fail 'session UI still depends on fragile synchronous power IPC'
grep -Fq 'forge-os-shell-active' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" && grep -Fq 'margin-top: 50px' "$forge_source/apps/desktop/src/renderer/src/styles/forge-os.css" && pass 'FORGE OS top bar reserves layout space instead of covering app header' || fail 'top bar can overlap application controls'
grep -Fq 'overflow-x: auto' "$forge_source/apps/desktop/src/renderer/src/styles/forge-os.css" && grep -Fq 'font-size: clamp' "$forge_source/apps/desktop/src/renderer/src/styles/forge-os.css" && pass 'top bar scales fonts and scrolls instead of overlapping' || fail 'top bar responsive scaling is incomplete'
grep -Fq 'trustedInternalApplication' "$forge_source/packages/os-integration/src/index.ts" && pass 'hidden fixed launchers have a trusted system-only bypass' || fail 'internal system launcher trust boundary is missing'
grep -Fq 'liveRecoveryMode' "$forge_source/packages/os-integration/src/index.ts" && grep -Fq 'FORGE Live Recovery' "$forge_source/apps/desktop/src/renderer/src/components/ForgeOsShell.tsx" && pass 'dedicated live recovery GUI remains present' || fail 'live recovery GUI is missing'

[[ -r "$root/config/forge-starship.toml" ]] && grep -Fq 'STARSHIP_CONFIG /usr/share/forge-os/forge-starship.toml' "$root/config/forge-dr460nized.fish" && pass 'Fish/Starship theme wiring is complete' || fail 'Fish/Starship theme wiring is incomplete'

duplicates="$(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$root/manifests/arch-packages.txt" | sort | uniq -d)"
[[ -z "$duplicates" ]] && pass 'official package manifest has no duplicates' || fail "manifest duplicates: $duplicates"
if command -v /usr/bin/pacman >/dev/null 2>&1; then mapfile -t packages < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$root/manifests/arch-packages.txt"); check /usr/bin/pacman -Sp --needed --print-format '%n' "${packages[@]}"; fi
check "$root/scripts/runtime-source-hash.sh" "$forge_source"
check npm --prefix "$forge_source" run typecheck
check npm --prefix "$forge_source" run lint
check npm --prefix "$forge_source" test
check npm --prefix "$forge_source" run build
git -C "$root" diff --check >/dev/null && pass 'FORGE-OS diff whitespace is valid' || fail 'FORGE-OS diff contains whitespace errors'
git -C "$forge_source" diff --check >/dev/null && pass 'FORGE diff whitespace is valid' || fail 'FORGE diff contains whitespace errors'
printf 'SOURCE SUMMARY: %d failure(s)\n' "$failures"
(( failures == 0 ))
