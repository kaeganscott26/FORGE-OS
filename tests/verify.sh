#!/usr/bin/env bash
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0
warnings=0
pass() { printf 'PASS: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL: %s\n' "$*" >&2; failures=$((failures + 1)); }
check() { if "$@" >/dev/null 2>&1; then pass "$*"; else fail "$*"; fi; }
payload_hash() { (cd "$1" 2>/dev/null && { find . -type f ! -name .forge-runtime.env -print0 | sort -z | xargs -0 sha256sum; find . -type l -printf 'LINK %p %l\n' | LC_ALL=C sort; }) | sha256sum | awk '{print $1}'; }
overlay_hash() {
  local overlay relative
  while IFS= read -r overlay; do relative="${overlay#"$root/"}"; printf 'FILE %s\n' "$relative"; sha256sum "$overlay" | awk '{print $1}'; done < <(find "$root/overlays" -maxdepth 1 -type f -name '*.patch' -print | sort)
}

"$root/tests/session-dispatcher.sh" && pass 'compatibility dispatcher tests pass' || fail 'compatibility dispatcher tests failed'
"$root/tests/greeter-contract.sh" && pass 'Matrix-capable greeter contract passes' || fail 'greeter contract failed'

source /etc/os-release 2>/dev/null || true
[[ "${ID:-}" == arch ]] && pass 'platform is Arch Linux' || fail 'platform is not Arch Linux'
[[ "$(id -u)" -ne 0 ]] && pass 'verifier runs as normal user' || fail 'verifier must not run as root'
for command in node npm git codex kwin_wayland plasmashell qdbus6 krunner kdialog konsole systemsettings kcmshell6 greetd /usr/local/bin/tuigreet xdg-open dbus-update-activation-environment; do check command -v "$command"; done
[[ "$(node --version 2>/dev/null)" == v22.* ]] && pass 'Node major version is 22' || fail "Node 22 is required; found $(node --version 2>/dev/null || echo missing)"

while IFS= read -r package; do check /usr/bin/pacman -Q "$package"; done < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$root/manifests/arch-packages.txt")
for package in xorg-server xorg-xinit openbox kwin-x11 thunar thunar-volman dunst xclip polkit-gnome greetd-tuigreet; do
  /usr/bin/pacman -Q "$package" >/dev/null 2>&1 && fail "retired package remains installed: $package" || pass "retired package absent: $package"
done
/usr/bin/pacman -Q greetd-tuigreet-fork-bin >/dev/null 2>&1 && pass 'maintained tuigreet fork package is installed' || fail 'maintained tuigreet fork package is missing'
for repository in core extra multilib chaotic-aur; do /usr/bin/pacman-conf --repo-list | grep -Fxq "$repository" && pass "repository enabled: $repository" || fail "repository disabled: $repository"; done

grep -q '^Server = https://' /etc/pacman.d/mirrorlist && pass 'official mirrorlist contains HTTPS servers' || fail 'official mirrorlist is invalid'
[[ -r /etc/xdg/reflector/reflector.conf ]] && pass 'reflector policy is installed' || fail 'reflector policy is missing'

help_text="$(/usr/local/bin/tuigreet --help 2>&1 || true)"
for option in --background --kb-background --doom-height --matrix-length; do grep -Fq -- "$option" <<<"$help_text" && pass "tuigreet supports $option" || fail "tuigreet missing $option"; done

for repository in "$HOME/FORGE" "$root"; do
  [[ -d "$repository/.git" ]] && pass "$repository is a Git repository" || fail "$repository is not a Git repository"
  git -C "$repository" fsck --no-dangling >/dev/null 2>&1 && pass "$repository Git objects are healthy" || fail "$repository Git check failed"
done

[[ -r "$root/build/latest.env" ]] || fail 'local build/latest.env is missing'
if [[ -r "$root/build/latest.env" ]]; then
  source "$root/build/latest.env"
  for name in FORGE_SOURCE_COMMIT FORGE_VERSION FORGE_BUILD_DATE FORGE_PACKAGE_SHA256 FORGE_LOCK_SHA256 FORGE_RUNTIME_SOURCE_SHA256 FORGE_OS_VERSION FORGE_OS_COMMIT FORGE_OS_OVERLAY_SHA256 FORGE_RUNTIME_RELATIVE_PATH FORGE_EXECUTABLE_RELATIVE_PATH FORGE_EXECUTABLE_SHA256 FORGE_APP_ASAR_SHA256 FORGE_PAYLOAD_SHA256 FORGE_RUNTIME_ID; do
    [[ -n "${!name:-}" ]] && pass "$name is recorded" || fail "$name is missing"
  done
  build_runtime="$root/${FORGE_RUNTIME_RELATIVE_PATH:-missing}"
  installed_runtime="$(readlink -f /opt/forge/current 2>/dev/null || true)"
  [[ "$(node -p "require(process.argv[1]).version" "$HOME/FORGE/package.json" 2>/dev/null)" == "${FORGE_VERSION:-}" ]] && pass 'FORGE application version matches record' || fail 'FORGE application version is stale'
  [[ "$(sha256sum "$HOME/FORGE/package.json" 2>/dev/null | awk '{print $1}')" == "${FORGE_PACKAGE_SHA256:-}" ]] && pass 'package manifest identity matches' || fail 'package manifest identity is stale'
  [[ "$(sha256sum "$HOME/FORGE/package-lock.json" 2>/dev/null | awk '{print $1}')" == "${FORGE_LOCK_SHA256:-}" ]] && pass 'package-lock identity matches' || fail 'package-lock identity is stale'
  [[ "$("$root/scripts/runtime-source-hash.sh" "$HOME/FORGE" 2>/dev/null)" == "${FORGE_RUNTIME_SOURCE_SHA256:-}" ]] && pass 'runtime source content matches build' || fail 'runtime source content is stale'
  [[ "$(<"$root/VERSION")" == "${FORGE_OS_VERSION:-}" ]] && pass 'FORGE-OS version matches build record' || fail 'FORGE-OS build version is stale'
  actual_overlay="$(overlay_hash | sha256sum | awk '{print $1}')"
  [[ "$actual_overlay" == "${FORGE_OS_OVERLAY_SHA256:-}" ]] && pass 'overlay identity matches' || fail 'overlay identity is stale'
  [[ -d "$build_runtime" ]] && pass 'packaged build runtime exists' || fail 'packaged build runtime is missing'
  [[ "$installed_runtime" == "/opt/forge/releases/${FORGE_RUNTIME_ID:-missing}" ]] && pass 'current runtime points to recorded release' || fail 'current runtime pointer is stale'
  [[ "$(payload_hash "$build_runtime")" == "${FORGE_PAYLOAD_SHA256:-}" ]] && pass 'build payload hash matches' || fail 'build payload hash mismatch'
  [[ "$(payload_hash "$installed_runtime")" == "${FORGE_PAYLOAD_SHA256:-}" ]] && pass 'installed payload hash matches' || fail 'installed payload is stale'
  [[ "$(sha256sum "$installed_runtime/resources/app.asar" 2>/dev/null | awk '{print $1}')" == "${FORGE_APP_ASAR_SHA256:-}" ]] && pass 'installed app.asar matches record' || fail 'installed app.asar is stale'
  [[ "$(sha256sum "$installed_runtime/${FORGE_EXECUTABLE_RELATIVE_PATH:-missing}" 2>/dev/null | awk '{print $1}')" == "${FORGE_EXECUTABLE_SHA256:-}" ]] && pass 'installed executable matches record' || fail 'installed executable mismatch'
fi

for pair in \
  "$root/session/forge-wayland-session:/usr/local/bin/forge-wayland-session" \
  "$root/session/forge-wayland-client:/usr/local/libexec/forge-wayland-client" \
  "$root/session/forge-session:/usr/local/bin/forge-session" \
  "$root/scripts/forge-system-surface:/usr/local/bin/forge-system-surface" \
  "$root/scripts/forge-session-control:/usr/local/bin/forge-session-control" \
  "$root/scripts/forge-install-program:/usr/local/bin/forge-install-program" \
  "$root/scripts/forge-install-pkg:/usr/local/bin/forge-install-pkg" \
  "$root/config/greetd-config.toml:/etc/greetd/config.toml" \
  "$root/config/reflector.conf:/etc/xdg/reflector/reflector.conf" \
  "$root/session/forge.desktop:/usr/share/forge-os/wayland-sessions/forge.desktop"; do
  installed="${pair#*:}"
  [[ -e "$installed" ]] || { fail "mandatory installed component is missing: $installed"; continue; }
  cmp -s "${pair%%:*}" "$installed" && pass "$installed matches repository" || fail "$installed is stale"
done
for desktop in "$root"/session/forge-internal-*.desktop; do
  installed="/usr/share/applications/$(basename "$desktop")"
  [[ -e "$installed" ]] && cmp -s "$desktop" "$installed" && pass "$installed matches repository" || fail "$installed is missing or stale"
done

grep -q '^source_profile = false$' /etc/greetd/config.toml && pass 'greetd profile sourcing is disabled' || fail 'greetd profile sourcing is enabled'
grep -Fq -- "--cmd '/usr/local/bin/forge-wayland-session'" /etc/greetd/config.toml && pass 'F2/default path is canonical Wayland runtime' || fail 'F2/default runtime path is wrong'
grep -Fq -- '--background matrix' /etc/greetd/config.toml && pass 'Matrix is default login background' || fail 'Matrix default background is missing'
grep -Fq -- '--kb-background 4' /etc/greetd/config.toml && pass 'F4 background selector is configured' || fail 'F4 background selector is missing'
if grep -Fq -- '--remember-session' /etc/greetd/config.toml; then fail 'remembered session can override canonical path'; else pass 'session cache cannot override canonical path'; fi
grep -Fq 'Exec=/usr/local/bin/forge-wayland-session' /usr/share/forge-os/wayland-sessions/forge.desktop && pass 'F3 FORGE entry uses canonical path' || fail 'F3 FORGE entry uses old path'

# Package command routing.
grep -Fq 'function pacman' "$HOME/.config/fish/conf.d/forge-dr460nized.fish" && pass 'interactive pacman wrapper is installed' || fail 'interactive pacman wrapper is missing'
grep -Fq '/usr/local/bin/forge-install-pkg --backend arch' "$HOME/.config/fish/conf.d/forge-dr460nized.fish" && pass 'interactive pacman routes through forge-install-pkg' || fail 'interactive pacman routing is wrong'

# Persistent service state.
for unit in NetworkManager.service bluetooth.service irqbalance.service systemd-timesyncd.service cups.service ollama.service; do
  systemctl is-enabled "$unit" >/dev/null 2>&1 && pass "$unit enabled" || fail "$unit is not enabled"
  systemctl is-active "$unit" >/dev/null 2>&1 && pass "$unit active" || warn "$unit is enabled but not currently active"
done
for timer in fstrim.timer reflector.timer; do
  systemctl is-enabled "$timer" >/dev/null 2>&1 && pass "$timer enabled" || fail "$timer is not enabled"
done
for unit in pipewire.socket pipewire-pulse.socket wireplumber.service; do
  systemctl --global is-enabled "$unit" >/dev/null 2>&1 && pass "$unit globally enabled" || fail "$unit is not globally enabled"
done
systemctl is-enabled greetd.service >/dev/null 2>&1 && pass 'greetd enabled' || fail 'greetd not enabled'
[[ "$(systemctl get-default 2>/dev/null)" == graphical.target ]] && pass 'default target is graphical.target' || fail 'default target is not graphical.target'
[[ -L /etc/systemd/system/autovt@tty2.service && "$(readlink -f /etc/systemd/system/autovt@tty2.service)" == /etc/systemd/system/forge-recovery.service ]] && pass 'tty2 recovery alias is installed' || fail 'tty2 recovery alias is missing'
[[ -L /etc/systemd/system/display-manager.service && "$(readlink -f /etc/systemd/system/display-manager.service)" == /usr/lib/systemd/system/greetd.service ]] && pass 'display-manager selects greetd' || fail 'display-manager does not select greetd'

if [[ -e /opt/forge/current/chrome-sandbox ]]; then
  [[ "$(stat -c '%U:%G %a' /opt/forge/current/chrome-sandbox)" == 'root:root 4755' ]] && pass 'chrome-sandbox permissions are correct' || fail "chrome-sandbox permissions are unsafe: $(stat -c '%U:%G %a' /opt/forge/current/chrome-sandbox)"
else
  fail 'chrome-sandbox is missing'
fi
[[ -r /etc/forge-os-version && "$(</etc/forge-os-version)" == "$(<"$root/VERSION")" ]] && pass 'installed FORGE-OS version matches repository' || fail 'installed FORGE-OS version is stale'
printf 'SUMMARY: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
(( failures == 0 ))
