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
overlay_hash() {
  local overlay relative
  while IFS= read -r overlay; do
    relative="${overlay#"$root/"}"
    printf 'FILE %s\n' "$relative"
    sha256sum "$overlay" | awk '{print $1}'
  done < <(find "$root/overlays" -maxdepth 1 -type f -name '*.patch' -print | sort)
}

source /etc/os-release 2>/dev/null || true
[[ "${ID:-}" == arch ]] && pass 'platform is Arch Linux' || fail 'platform is not Arch Linux'
[[ "$(id -u)" -ne 0 ]] && pass 'verifier runs as a normal user' || fail 'verifier must not run as root'
for command in node npm git codex X Xorg xinit openbox openbox-session kwin_x11 krunner kdialog systemsettings greetd tuigreet xdg-open dbus-update-activation-environment; do check command -v "$command"; done
[[ "$(node --version 2>/dev/null)" == v22.* ]] && pass 'Node major version is 22' || fail "Node 22 is required; found $(node --version 2>/dev/null || echo missing)"
for package in nodejs-lts-jod xorg-server xorg-xinit openbox kwin-x11 plasma-workspace systemsettings kdialog breeze kvantum xdg-desktop-portal-kde greetd greetd-tuigreet networkmanager pipewire wireplumber dbus-broker xdg-desktop-portal-gtk polkit-gnome chromium thunar; do check pacman -Q "$package"; done

for repository in "$HOME/FORGE" "$root"; do
  [[ -d "$repository/.git" ]] && pass "$repository is a Git repository" || fail "$repository is not a Git repository"
  git -C "$repository" fsck --no-dangling >/dev/null 2>&1 && pass "$repository Git objects are healthy" || fail "$repository Git check failed"
done

[[ -r "$root/build/latest.env" ]] || fail 'local build/latest.env is missing'
if [[ -r "$root/build/latest.env" ]]; then
  source "$root/build/latest.env"
  for name in FORGE_SOURCE_COMMIT FORGE_BUILD_DATE FORGE_LOCK_SHA256 FORGE_OS_OVERLAY_SHA256 FORGE_RUNTIME_RELATIVE_PATH FORGE_EXECUTABLE_RELATIVE_PATH FORGE_EXECUTABLE_SHA256 FORGE_APP_ASAR_SHA256 FORGE_PAYLOAD_SHA256 FORGE_RUNTIME_ID; do
    [[ -n "${!name:-}" ]] && pass "$name is recorded" || fail "$name is missing"
  done
  build_runtime="$root/${FORGE_RUNTIME_RELATIVE_PATH:-missing}"
  installed_runtime="$(readlink -f /opt/forge/current 2>/dev/null || true)"
  [[ "$(git -C "$HOME/FORGE" rev-parse HEAD 2>/dev/null)" == "${FORGE_SOURCE_COMMIT:-}" ]] && pass 'build source commit matches FORGE HEAD' || fail 'build source commit does not match FORGE HEAD'
  [[ "$(sha256sum "$HOME/FORGE/package-lock.json" 2>/dev/null | awk '{print $1}')" == "${FORGE_LOCK_SHA256:-}" ]] && pass 'package-lock identity matches' || fail 'package-lock identity is stale'
  actual_overlay="$(overlay_hash | sha256sum | awk '{print $1}')"
  [[ "$actual_overlay" == "${FORGE_OS_OVERLAY_SHA256:-}" ]] && pass 'path-independent overlay identity matches' || fail 'overlay identity is stale'
  [[ -d "$build_runtime" ]] && pass 'packaged build runtime exists' || fail 'packaged build runtime is missing'
  [[ "$installed_runtime" == "/opt/forge/releases/${FORGE_RUNTIME_ID:-missing}" ]] && pass 'current runtime points to recorded content-addressed release' || fail 'current runtime pointer is stale'
  [[ "$(payload_hash "$build_runtime")" == "${FORGE_PAYLOAD_SHA256:-}" ]] && pass 'build payload hash matches record' || fail 'build payload hash mismatch'
  [[ "$(payload_hash "$installed_runtime")" == "${FORGE_PAYLOAD_SHA256:-}" ]] && pass 'installed payload hash matches record' || fail 'installed payload is stale'
  [[ "$(sha256sum "$build_runtime/resources/app.asar" 2>/dev/null | awk '{print $1}')" == "${FORGE_APP_ASAR_SHA256:-}" ]] && pass 'build app.asar matches record' || fail 'build app.asar mismatch'
  [[ "$(sha256sum "$installed_runtime/resources/app.asar" 2>/dev/null | awk '{print $1}')" == "${FORGE_APP_ASAR_SHA256:-}" ]] && pass 'installed app.asar matches record' || fail 'installed app.asar is stale'
  cmp -s "$build_runtime/resources/app.asar" "$installed_runtime/resources/app.asar" && pass 'installed app.asar is byte-identical to build' || fail 'installed app.asar differs from build'
  [[ "$(sha256sum "$installed_runtime/${FORGE_EXECUTABLE_RELATIVE_PATH:-missing}" 2>/dev/null | awk '{print $1}')" == "${FORGE_EXECUTABLE_SHA256:-}" ]] && pass 'installed executable matches record' || fail 'installed executable mismatch'
fi

for pair in \
  "$root/session/forge-xsession:/usr/local/bin/forge-xsession" \
  "$root/session/forge-session:/usr/local/bin/forge-session" \
  "$root/session/forge-session-client:/usr/local/libexec/forge-session-client" \
  "$root/scripts/forge-app-launcher:/usr/local/bin/forge-app-launcher" \
  "$root/scripts/forge-open:/usr/local/bin/forge-open" \
  "$root/scripts/forge-workspace-runner:/usr/local/bin/forge-workspace-runner" \
  "$root/scripts/forge-install-program:/usr/local/bin/forge-install-program" \
  "$root/config/kwinrc:/etc/xdg/kwinrc" \
  "$root/config/kdeglobals:/etc/xdg/kdeglobals" \
  "$root/config/forge-portals.conf:/usr/share/xdg-desktop-portal/forge-portals.conf" \
  "$root/session/forge-app-launcher.desktop:/usr/share/applications/forge-app-launcher.desktop" \
  "$root/session/forge-system-settings.desktop:/usr/share/applications/forge-system-settings.desktop" \
  "$root/session/forge-workspace-runner.desktop:/usr/share/applications/forge-workspace-runner.desktop" \
  "$root/session/forge-install-program.desktop:/usr/share/applications/forge-install-program.desktop" \
  "$root/session/forge.desktop:/usr/share/forge-os/xsessions/forge.desktop" \
  "$root/config/greetd-config.toml:/etc/greetd/config.toml"; do
  installed="${pair#*:}"
  [[ -e "$installed" ]] || { fail "mandatory installed component is missing: $installed"; continue; }
  cmp -s "${pair%%:*}" "$installed" && pass "$installed matches repository" || fail "$installed is stale"
done

[[ ! -e /usr/share/xsessions/forge.desktop ]] && pass 'legacy global FORGE X session entry is absent' || fail 'legacy global FORGE X session entry remains installed'
grep -q '^source_profile = false$' /etc/greetd/config.toml 2>/dev/null && pass 'greetd does not source shell profiles' || fail 'greetd profile sourcing is still enabled'
grep -q '^user = "greeter"$' /etc/greetd/config.toml 2>/dev/null && pass 'greetd uses dedicated greeter account' || fail 'greetd is not configured for greeter account'
getent passwd greeter >/dev/null && pass 'greeter account exists' || fail 'greeter account is missing'
grep -Fq -- "--cmd '/usr/bin/xinit /usr/local/libexec/forge-session-client'" /etc/greetd/config.toml 2>/dev/null && pass 'greetd uses verified FORGE runtime command' || fail 'greetd default session command is wrong'
grep -Fq -- "--cmd '/usr/bin/xinit /usr/local/libexec/forge-session-client'" "$root/config/greetd-config.toml" && pass 'repository greetd default uses verified FORGE runtime command' || fail 'repository greetd default session command is wrong'
if grep -Fq -- "--cmd '/usr/bin/openbox-session'" "$root/config/greetd-config.toml"; then
  fail 'repository greetd default points directly to openbox-session'
else
  pass 'repository greetd default does not bypass forge-session-client'
fi
grep -q -- '--no-xsession-wrapper' /etc/greetd/config.toml 2>/dev/null && pass 'tuigreet X session wrapper is disabled' || fail 'tuigreet can still inject the default startx wrapper'
grep -q -- '--xsessions /usr/share/forge-os/xsessions' /etc/greetd/config.toml 2>/dev/null && pass 'tuigreet X sessions are isolated to FORGE directory' || fail 'tuigreet still discovers global X sessions'
grep -q -- '--sessions /usr/share/forge-os/wayland-sessions' /etc/greetd/config.toml 2>/dev/null && pass 'tuigreet Wayland sessions are isolated from system defaults' || fail 'tuigreet still discovers global Wayland sessions'
grep -Fq 'exec /usr/bin/xinit /usr/local/libexec/forge-session-client' "$root/session/forge-xsession" && pass 'forge-xsession aliases verified xinit path' || fail 'forge-xsession does not use verified xinit path'
grep -Fq 'Exec=/usr/bin/xinit /usr/local/libexec/forge-session-client' "$root/session/forge.desktop" && pass 'desktop entry uses verified xinit path' || fail 'desktop entry has wrong runtime command'
grep -Fq 'kwin_x11 --replace' "$root/session/forge-session-client" && pass 'session attempts Plasma 6 KWin window management' || fail 'KWin integration is missing'
grep -Fq 'openbox-session &' "$root/session/forge-session-client" && pass 'session retains Openbox fallback' || fail 'Openbox fallback is missing'
if grep -ERq 'startx|\.xinitrc' "$root/session" /usr/local/bin/forge-xsession /usr/local/bin/forge-session /usr/local/libexec/forge-session-client; then
  fail 'legacy startx dependency remains in production session'
elif (( $? == 1 )); then
  pass 'production session has no startx or .xinitrc dependency'
else
  fail 'production session dependency search could not be completed'
fi
[[ ! -e /etc/profile.d/forge-autostart.sh && ! -e /etc/forge/session.env ]] && pass 'legacy tty1 profile autostart is absent' || fail 'legacy tty1 profile autostart remains installed'
if grep -ERq 'PACKAGED_RUNTIME_ACCEPTED|GRAPHICAL_LOGIN_ACCEPTED' "$root/scripts" "$root/session"; then
  fail 'acceptance gating remains'
elif (( $? != 1 )); then
  fail 'acceptance gating search could not be completed'
elif [[ -e "$root/docs/ACCEPTANCE.md" ]]; then
  fail 'acceptance gating remains'
else
  pass 'acceptance gating is absent'
fi
grep -Eq "'FORGE_OS_SESSION'.*'FORGE_SHELL_MODE'.*'FORGE_OS_VERSION'" "$HOME/FORGE/packages/shell/src/index.ts" && pass 'FORGE child environment contract is implemented' || fail 'FORGE child environment contract is incomplete'
grep -q 'FORGE_BUILD_COMMIT' "$HOME/FORGE/apps/desktop/electron.vite.config.ts" && pass 'FORGE supports explicit packaged build identity' || fail 'FORGE packaged build identity contract is missing'

for stale in \
  "$root/scripts/install-forge-os.sh" \
  "$root/docs/CODEX_VERIFIER_FIX_PROMPT.md" \
  "$root/UserFiles/screenshot.png" \
  "$root/build/user-desktop-backup/mimeapps.list"; do
  [[ ! -e "$stale" ]] && pass "stale repository artifact absent: ${stale#$root/}" || fail "stale repository artifact remains: ${stale#$root/}"
done

check systemctl is-enabled NetworkManager.service
check systemctl is-enabled greetd.service
[[ "$(systemctl get-default 2>/dev/null)" == graphical.target ]] && pass 'default target is graphical.target' || fail 'default target is not graphical.target'
systemctl is-enabled getty@tty2.service >/dev/null 2>&1 && pass 'tty2 recovery getty is enabled' || fail 'tty2 recovery getty is not enabled'
systemctl is-active getty@tty2.service >/dev/null 2>&1 && pass 'tty2 recovery getty is active' || warn 'tty2 getty is enabled but not currently active'
[[ -L /etc/systemd/system/display-manager.service && "$(readlink -f /etc/systemd/system/display-manager.service)" == /usr/lib/systemd/system/greetd.service ]] && pass 'display-manager alias selects greetd' || fail 'display-manager.service does not select greetd'
if [[ -e /opt/forge/current/chrome-sandbox ]]; then
  [[ "$(stat -c '%U:%G %a' /opt/forge/current/chrome-sandbox)" == 'root:root 4755' ]] && pass 'chrome-sandbox is root-owned mode 4755' || fail "chrome-sandbox permissions are unsafe: $(stat -c '%U:%G %a' /opt/forge/current/chrome-sandbox)"
else
  fail 'chrome-sandbox is missing'
fi
[[ -r /etc/forge-os-version && "$(</etc/forge-os-version)" == "$(<"$root/VERSION")" ]] && pass 'installed FORGE-OS version matches repository' || fail 'installed FORGE-OS version is stale'
[[ -r "$root/docs/RECOVERY.md" ]] && pass 'recovery documentation exists' || fail 'recovery documentation is missing'
printf 'SUMMARY: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
(( failures == 0 ))
