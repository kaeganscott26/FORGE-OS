#!/usr/bin/env bash
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0
warnings=0
pass() { printf 'PASS: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL: %s\n' "$*"; failures=$((failures + 1)); }
check() { if "$@" >/dev/null 2>&1; then pass "$*"; else fail "$*"; fi; }
payload_hash() { (cd "$1" 2>/dev/null && { find . -type f ! -name .forge-runtime.env -print0 | sort -z | xargs -0 sha256sum; find . -type l -printf 'LINK %p %l\n' | LC_ALL=C sort; }) | sha256sum | awk '{print $1}'; }

source /etc/os-release 2>/dev/null || true
[[ "${ID:-}" == arch ]] && pass 'platform is Arch Linux' || fail 'platform is not Arch Linux'
[[ "$(id -u)" -ne 0 ]] && pass 'verifier runs as a normal user' || fail 'verifier must not run as root'
for command in node npm git codex Xorg xinit openbox greetd tuigreet xdg-open dbus-update-activation-environment; do check command -v "$command"; done
[[ "$(node --version 2>/dev/null)" == v22.* ]] && pass 'Node major version is 22' || fail "Node 22 is required; found $(node --version 2>/dev/null || echo missing)"
for package in nodejs-lts-jod xorg-server xorg-xinit openbox greetd greetd-tuigreet networkmanager pipewire wireplumber dbus-broker xdg-desktop-portal-gtk polkit-gnome chromium thunar; do check pacman -Q "$package"; done

for repository in "$HOME/FORGE" "$root"; do
  [[ -d "$repository/.git" ]] && pass "$repository is a Git repository" || fail "$repository is not a Git repository"
  git -C "$repository" fsck --no-dangling >/dev/null 2>&1 && pass "$repository Git objects are healthy" || fail "$repository Git check failed"
done
[[ -r "$root/build/latest.env" ]] || fail 'local build/latest.env is missing'
if [[ -r "$root/build/latest.env" ]]; then
  source "$root/build/latest.env"
  for name in FORGE_SOURCE_COMMIT FORGE_LOCK_SHA256 FORGE_OS_OVERLAY_SHA256 FORGE_RUNTIME_RELATIVE_PATH FORGE_EXECUTABLE_RELATIVE_PATH FORGE_EXECUTABLE_SHA256 FORGE_APP_ASAR_SHA256 FORGE_PAYLOAD_SHA256 FORGE_RUNTIME_ID; do [[ -n "${!name:-}" ]] && pass "$name is recorded" || fail "$name is missing"; done
  build_runtime="$root/${FORGE_RUNTIME_RELATIVE_PATH:-missing}"
  installed_runtime="$(readlink -f /opt/forge/current 2>/dev/null || true)"
  [[ "$(git -C "$HOME/FORGE" rev-parse HEAD 2>/dev/null)" == "${FORGE_SOURCE_COMMIT:-}" ]] && pass 'build source commit matches FORGE HEAD' || fail 'build source commit does not match FORGE HEAD'
  [[ "$(sha256sum "$HOME/FORGE/package-lock.json" 2>/dev/null | awk '{print $1}')" == "${FORGE_LOCK_SHA256:-}" ]] && pass 'package-lock identity matches' || fail 'package-lock identity is stale'
  mapfile -t overlays < <(find "$root/overlays" -maxdepth 1 -type f -name '*.patch' -print | sort)
  actual_overlay="$(sha256sum "${overlays[@]}" 2>/dev/null | sha256sum | awk '{print $1}')"
  [[ "$actual_overlay" == "${FORGE_OS_OVERLAY_SHA256:-}" ]] && pass 'overlay identity matches' || fail 'overlay identity is stale'
  [[ -d "$build_runtime" ]] && pass 'packaged build runtime exists' || fail 'packaged build runtime is missing'
  [[ "$installed_runtime" == "/opt/forge/releases/${FORGE_RUNTIME_ID:-missing}" ]] && pass 'current runtime points to recorded content-addressed release' || fail 'current runtime pointer is stale'
  [[ "$(payload_hash "$build_runtime")" == "${FORGE_PAYLOAD_SHA256:-}" ]] && pass 'build payload hash matches record' || fail 'build payload hash mismatch'
  [[ "$(payload_hash "$installed_runtime")" == "${FORGE_PAYLOAD_SHA256:-}" ]] && pass 'installed payload hash matches record' || fail 'installed payload is stale'
  [[ "$(sha256sum "$build_runtime/resources/app.asar" 2>/dev/null | awk '{print $1}')" == "${FORGE_APP_ASAR_SHA256:-}" ]] && pass 'build app.asar matches record' || fail 'build app.asar mismatch'
  [[ "$(sha256sum "$installed_runtime/resources/app.asar" 2>/dev/null | awk '{print $1}')" == "${FORGE_APP_ASAR_SHA256:-}" ]] && pass 'installed app.asar matches record' || fail 'installed app.asar is stale'
  cmp -s "$build_runtime/resources/app.asar" "$installed_runtime/resources/app.asar" && pass 'installed app.asar is byte-identical to build' || fail 'installed app.asar differs from build'
  [[ "$(sha256sum "$installed_runtime/${FORGE_EXECUTABLE_RELATIVE_PATH:-forge}" 2>/dev/null | awk '{print $1}')" == "${FORGE_EXECUTABLE_SHA256:-}" ]] && pass 'installed executable matches record' || fail 'installed executable mismatch'
fi

for pair in "$root/session/forge-xsession:/usr/local/bin/forge-xsession" "$root/session/forge-session:/usr/local/bin/forge-session" "$root/session/forge-session-client:/usr/local/libexec/forge-session-client" "$root/config/greetd-config.toml:/etc/greetd/config.toml"; do
  [[ -x "${pair#*:}" || "${pair#*:}" == /etc/greetd/config.toml ]] || fail "mandatory installed component is missing: ${pair#*:}"
  cmp -s "${pair%%:*}" "${pair#*:}" && pass "${pair#*:} matches repository" || fail "${pair#*:} is stale"
done
grep -q '^user = "greeter"$' /etc/greetd/config.toml 2>/dev/null && pass 'greetd uses dedicated greeter account' || fail 'greetd is not configured for greeter account'
getent passwd greeter >/dev/null && pass 'greeter account exists' || fail 'greeter account is missing'
grep -q '/usr/local/bin/forge-xsession' /etc/greetd/config.toml 2>/dev/null && pass 'greetd selects FORGE session' || fail 'greetd session command is wrong'
! rg -q 'startx|\.xinitrc' "$root/session" && pass 'production session has no startx or .xinitrc dependency' || fail 'legacy startx dependency remains in production session'
rg -q '"/tmp/\.X\$\{candidate\}-lock".*"/tmp/\.X11-unix/X\$\{candidate\}"' "$root/session/forge-xsession" && pass 'X session allocates an unoccupied display' || fail 'X session still assumes a fixed display'
rg -q '/usr/lib/Xorg "\:\$display_number"' "$root/session/forge-xsession" && pass 'selected X display is passed explicitly to Xorg' || fail 'selected X display is not passed to Xorg'
[[ ! -e /etc/profile.d/forge-autostart.sh && ! -e /etc/forge/session.env ]] && pass 'legacy tty1 profile autostart is absent' || fail 'legacy tty1 profile autostart remains installed'
! rg -q 'PACKAGED_RUNTIME_ACCEPTED|GRAPHICAL_LOGIN_ACCEPTED' "$root/scripts" "$root/session" && [[ ! -e "$root/docs/ACCEPTANCE.md" ]] && pass 'acceptance gating is absent' || fail 'acceptance gating remains'
rg -q "'FORGE_OS_SESSION'.*'FORGE_SHELL_MODE'.*'FORGE_OS_VERSION'" "$HOME/FORGE/packages/shell/src/index.ts" && pass 'FORGE child environment contract is implemented' || fail 'FORGE child environment contract is incomplete'

check systemctl is-enabled NetworkManager.service
check systemctl is-enabled greetd.service
[[ "$(systemctl get-default 2>/dev/null)" == graphical.target ]] && pass 'default target is graphical.target' || fail 'default target is not graphical.target'
systemctl is-enabled getty@tty2.service >/dev/null 2>&1 && pass 'tty2 recovery getty is enabled' || fail 'tty2 recovery getty is not enabled'
systemctl is-active getty@tty2.service >/dev/null 2>&1 && pass 'tty2 recovery getty is active' || warn 'tty2 getty is enabled but not currently active'
[[ -L /etc/systemd/system/display-manager.service && "$(readlink -f /etc/systemd/system/display-manager.service)" == /usr/lib/systemd/system/greetd.service ]] && pass 'display-manager alias selects greetd' || fail 'display-manager.service does not select greetd'
if [[ -e /opt/forge/current/chrome-sandbox ]]; then
  [[ "$(stat -c '%U:%G %a' /opt/forge/current/chrome-sandbox)" == 'root:root 4755' ]] && pass 'chrome-sandbox is root-owned mode 4755' || fail "chrome-sandbox permissions are unsafe: $(stat -c '%U:%G %a' /opt/forge/current/chrome-sandbox)"
else fail 'chrome-sandbox is missing'; fi
[[ -r /etc/forge-os-version && "$(</etc/forge-os-version)" == "$(<"$root/VERSION")" ]] && pass 'installed FORGE-OS version matches repository' || fail 'installed FORGE-OS version is stale'
[[ -r "$root/docs/RECOVERY.md" ]] && pass 'recovery documentation exists' || fail 'recovery documentation is missing'
printf 'SUMMARY: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
(( failures == 0 ))
