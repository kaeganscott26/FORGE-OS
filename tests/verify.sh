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

"$root/tests/session-dispatcher.sh" && pass 'canonical session dispatcher tests pass' || fail 'canonical session dispatcher tests failed'

source /etc/os-release 2>/dev/null || true
[[ "${ID:-}" == arch ]] && pass 'platform is Arch Linux' || fail 'platform is not Arch Linux'
[[ "$(id -u)" -ne 0 ]] && pass 'verifier runs as a normal user' || fail 'verifier must not run as root'
for command in node npm git codex kwin_wayland plasmashell qdbus6 krunner kdialog konsole systemsettings greetd tuigreet xdg-open dbus-update-activation-environment; do check command -v "$command"; done
[[ "$(node --version 2>/dev/null)" == v22.* ]] && pass 'Node major version is 22' || fail "Node 22 is required; found $(node --version 2>/dev/null || echo missing)"
while IFS= read -r package; do check pacman -Q "$package"; done < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$root/manifests/arch-packages.txt")
for package in xorg-server xorg-xinit openbox kwin-x11 thunar thunar-volman dunst xclip polkit-gnome; do
  pacman -Q "$package" >/dev/null 2>&1 && fail "retired X11/XFCE shell package remains installed: $package" || pass "retired X11/XFCE shell package is absent: $package"
done

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
  [[ -n "${FORGE_SOURCE_COMMIT:-}" ]] && pass 'build source commit is retained as provenance' || fail 'build source provenance is missing'
  [[ "$(node -p "require(process.argv[1]).version" "$HOME/FORGE/package.json" 2>/dev/null)" == "${FORGE_VERSION:-}" ]] && pass 'FORGE application version matches record' || fail 'FORGE application version is stale'
  [[ "$(sha256sum "$HOME/FORGE/package.json" 2>/dev/null | awk '{print $1}')" == "${FORGE_PACKAGE_SHA256:-}" ]] && pass 'package manifest identity matches' || fail 'package manifest identity is stale'
  [[ "$(sha256sum "$HOME/FORGE/package-lock.json" 2>/dev/null | awk '{print $1}')" == "${FORGE_LOCK_SHA256:-}" ]] && pass 'package-lock identity matches' || fail 'package-lock identity is stale'
  [[ "$("$root/scripts/runtime-source-hash.sh" "$HOME/FORGE" 2>/dev/null)" == "${FORGE_RUNTIME_SOURCE_SHA256:-}" ]] && pass 'runtime source content matches build' || fail 'runtime source content is stale'
  [[ "$(<"$root/VERSION")" == "${FORGE_OS_VERSION:-}" ]] && pass 'FORGE-OS version matches build record' || fail 'FORGE-OS build version is stale'
  [[ -n "${FORGE_OS_COMMIT:-}" ]] && pass 'FORGE-OS source commit is retained as provenance' || fail 'FORGE-OS source provenance is missing'
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
  "$root/session/forge-wayland-session:/usr/local/bin/forge-wayland-session" \
  "$root/session/startplasma-wayland:/usr/local/bin/startplasma-wayland" \
  "$root/session/forge-session:/usr/local/bin/forge-session" \
  "$root/session/forge-wayland-client:/usr/local/libexec/forge-wayland-client" \
  "$root/session/forge-recovery-session:/usr/local/bin/forge-recovery-session" \
  "$root/session/forge-recovery-client:/usr/local/libexec/forge-recovery-client" \
  "$root/scripts/forge-runtime-rollback-activate:/usr/local/libexec/forge-runtime-rollback-activate" \
  "$root/session/forge-plasma-initialize:/usr/local/libexec/forge-plasma-initialize" \
  "$root/scripts/forge-app-launcher:/usr/local/bin/forge-app-launcher" \
  "$root/scripts/forge-open:/usr/local/bin/forge-open" \
  "$root/scripts/forge-workspace-runner:/usr/local/bin/forge-workspace-runner" \
  "$root/scripts/forge-install-program:/usr/local/bin/forge-install-program" \
  "$root/scripts/forge-app-install:/usr/local/bin/forge-app-install" \
  "$root/scripts/forge-install-pkg:/usr/local/bin/forge-install-pkg" \
  "$root/scripts/forge-runtime-rollback:/usr/local/bin/forge-runtime-rollback" \
  "$root/scripts/forge-workspace-bootstrap.sh:/usr/local/bin/forge-workspace-bootstrap" \
  "$root/scripts/forge-refresh-mirrors:/usr/local/bin/forge-refresh-mirrors" \
  "$root/scripts/install-wayland-stacks.sh:/usr/local/bin/install-wayland-stacks.sh" \
  "$root/scripts/forge-panel-manager:/usr/local/bin/forge-panel-manager" \
  "$root/scripts/forge-os-update:/usr/local/bin/forge-os-update" \
  "$root/config/kwinrc:/etc/xdg/kwinrc" \
  "$root/config/kdeglobals:/etc/xdg/kdeglobals" \
  "$root/config/forge-portals.conf:/usr/share/xdg-desktop-portal/forge-portals.conf" \
  "$root/config/mirrorlist:/usr/share/forge-os/mirrorlist" \
  "$root/config/forge-dr460nized.fish:/usr/share/forge-os/forge-dr460nized.fish" \
  "$root/config/forge-starship.toml:/usr/share/forge-os/forge-starship.toml" \
  "$root/session/forge-app-launcher.desktop:/usr/share/applications/forge-app-launcher.desktop" \
  "$root/session/forge-explorer.desktop:/usr/share/applications/forge-explorer.desktop" \
  "$root/session/forge-system-settings.desktop:/usr/share/applications/forge-system-settings.desktop" \
  "$root/session/forge-workspace-runner.desktop:/usr/share/applications/forge-workspace-runner.desktop" \
  "$root/session/forge-install-program.desktop:/usr/share/applications/forge-install-program.desktop" \
  "$root/session/forge-panel-manager.desktop:/usr/share/applications/forge-panel-manager.desktop" \
  "$root/session/forge.desktop:/usr/share/forge-os/wayland-sessions/forge.desktop" \
  "$root/config/greetd-config.toml:/etc/greetd/config.toml" \
  "$root/config/forge-recovery.service:/etc/systemd/system/forge-recovery.service"; do
  installed="${pair#*:}"
  [[ -e "$installed" ]] || { fail "mandatory installed component is missing: $installed"; continue; }
  cmp -s "${pair%%:*}" "$installed" && pass "$installed matches repository" || fail "$installed is stale"
done

[[ ! -e /usr/share/xsessions/forge.desktop && ! -e /usr/share/forge-os/xsessions/forge.desktop ]] && pass 'legacy FORGE X session entries are absent' || fail 'legacy FORGE X session entry remains installed'
grep -q '^source_profile = false$' /etc/greetd/config.toml 2>/dev/null && pass 'greetd does not source shell profiles' || fail 'greetd profile sourcing is still enabled'
grep -q '^user = "greeter"$' /etc/greetd/config.toml 2>/dev/null && pass 'greetd uses dedicated greeter account' || fail 'greetd is not configured for greeter account'
getent passwd greeter >/dev/null && pass 'greeter account exists' || fail 'greeter account is missing'
grep -Fq -- "--cmd 'startplasma-wayland forge-wayland-session forge-wayland-client'" /etc/greetd/config.toml 2>/dev/null && pass 'greetd defaults to canonical FORGE runtime chain' || fail 'greetd default session command is wrong'
grep -Fq -- "--cmd 'startplasma-wayland forge-wayland-session forge-wayland-client'" "$root/config/greetd-config.toml" && pass 'repository greetd defaults to canonical FORGE runtime chain' || fail 'repository greetd default session command is wrong'
grep -q -- '--xsessions /usr/share/forge-os/disabled-xsessions' /etc/greetd/config.toml 2>/dev/null && pass 'tuigreet does not expose X11 sessions' || fail 'tuigreet still exposes an X11 session directory'
grep -q -- '--sessions /usr/share/forge-os/wayland-sessions' /etc/greetd/config.toml 2>/dev/null && pass 'tuigreet Wayland sessions are isolated from system defaults' || fail 'tuigreet still discovers global Wayland sessions'
grep -Fq 'Exec=startplasma-wayland forge-wayland-session forge-wayland-client' "$root/session/forge.desktop" && pass 'desktop entry uses canonical FORGE runtime chain' || fail 'desktop entry has wrong runtime command'
grep -Fq 'forge_session=/usr/local/bin/forge-wayland-session' "$root/session/startplasma-wayland" &&
grep -Fq 'exec "$forge_session"' "$root/session/startplasma-wayland" &&
  pass 'FORGE owns canonical Plasma command dispatch' ||
  fail 'canonical runtime dispatcher is missing'
grep -Fq 'kwin_wayland --xwayland --exit-with-session' "$root/session/forge-wayland-session" && pass 'session starts KWin Wayland with XWayland compatibility' || fail 'KWin Wayland integration is missing'
grep -Fq 'plasmashell --no-respawn' "$root/session/forge-wayland-client" && pass 'Plasma visual and panel services start beneath FORGE' || fail 'Plasma shell services are missing'
grep -Fq -- '--ozone-platform=wayland' "$root/session/forge-session" && pass 'FORGE defaults to native Wayland rendering' || fail 'FORGE native Wayland flags are missing'
if grep -Fq '/usr/local/bin/forge-os-update' "$HOME/FORGE/apps/desktop/src/main/updater.ts"; then
  pass 'FORGE update action delegates to the FORGE-OS updater'
else
  pass 'FORGE application updater is independent from FORGE-OS system updater'
fi
grep -Fq 'https://github.com/kaeganscott26/FORGE-OS' "$root/scripts/forge-os-update" && pass 'FORGE-OS updater pins the trusted repositories' || fail 'FORGE-OS updater origin policy is missing'
grep -Fq "Warning: power-profiles-daemon could not be started; continuing the update." "$root/scripts/configure-hardware.sh" && pass 'optional power profile daemon failure does not abort updates' || fail 'power profile daemon failure can abort updates'
grep -Fq "Warning: unable to select the performance power profile; continuing the update." "$root/scripts/configure-hardware.sh" && pass 'power profile DBus failure does not abort updates' || fail 'power profile DBus failure can abort updates'
if grep -ERq 'xinit|kwin_x11|openbox|XDG_SESSION_TYPE=x11' "$root/session" "$root/config/greetd-config.toml"; then
  fail 'legacy X11 session stack remains in production configuration'
elif (( $? == 1 )); then
  pass 'production configuration has no legacy X11 session stack'
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
if [[ -r "$HOME/FORGE/apps/desktop/resources/ollama/skills.json" ]]; then
  cmp -s "$HOME/FORGE/apps/desktop/resources/ollama/skills.json" "$HOME/.config/ollama/skills.json" &&
    pass 'Ollama-local skills match FORGE capabilities' ||
    fail 'Ollama-local skill parity is stale'
else
  pass 'optional Ollama-local skill bundle is absent from FORGE'
fi

if [[ -r "$HOME/FORGE/apps/desktop/resources/ollama/skills/local-model-tooling/SKILL.md" ]]; then
  cmp -s "$HOME/FORGE/apps/desktop/resources/ollama/skills/local-model-tooling/SKILL.md"     "$HOME/.config/ollama/skills/local-model-tooling/SKILL.md" &&
    pass 'Ollama-local tooling skill matches FORGE contract' ||
    fail 'Ollama-local tooling skill is stale'
else
  pass 'optional Ollama-local tooling skill is absent from FORGE'
fi

for stale in \
  "$root/scripts/install-forge-os.sh" \
  "$root/docs/CODEX_VERIFIER_FIX_PROMPT.md" \
  "$root/UserFiles/screenshot.png" \
  "$root/build/user-desktop-backup/mimeapps.list"; do
  [[ ! -e "$stale" ]] && pass "stale repository artifact absent: ${stale#$root/}" || fail "stale repository artifact remains: ${stale#$root/}"
done

check systemctl is-enabled NetworkManager.service
check systemctl is-enabled ollama.service
check systemctl is-enabled greetd.service
[[ "$(systemctl get-default 2>/dev/null)" == graphical.target ]] && pass 'default target is graphical.target' || fail 'default target is not graphical.target'
systemctl is-enabled forge-recovery.service >/dev/null 2>&1 &&
  pass 'FORGE recovery service is enabled for graphical.target' ||
  fail 'FORGE recovery service is not enabled'
systemctl is-active forge-recovery.service >/dev/null 2>&1 && pass 'tty2 native recovery environment is active' || warn 'tty2 native recovery environment is enabled but not currently active'
systemctl is-enabled getty@tty2.service >/dev/null 2>&1 && fail 'legacy tty2 getty conflicts with native recovery' || pass 'legacy tty2 getty is disabled'
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
