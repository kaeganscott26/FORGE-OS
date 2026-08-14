#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skip_packages=false
use_current_build=false
for argument in "$@"; do
  case "$argument" in
    --skip-packages) skip_packages=true ;;
    --use-current-build) use_current_build=true ;;
    *) echo "Unknown option: $argument" >&2; exit 64 ;;
  esac
done

target_user="${FORGE_USER:-${SUDO_USER:-$USER}}"
target_home="$(getent passwd "$target_user" | cut -d: -f6)"
[[ "$(id -u)" -ne 0 ]] || { echo 'Run this as the target desktop user; sudo is invoked only for system files.' >&2; exit 1; }
[[ -n "$target_home" && -d "$target_home" && "$target_user" != root ]] || { echo "Invalid desktop user: $target_user" >&2; exit 1; }
forge_source="${FORGE_SOURCE:-$target_home/FORGE}"

require_current_main() {
  local repository="$1" label="$2"
  [[ -d "$repository/.git" ]] || { echo "$label is not a Git repository: $repository" >&2; exit 1; }
  [[ "$(git -C "$repository" branch --show-current)" == main ]] || { echo "$label must be on main for a production FORGE-OS install." >&2; exit 1; }
  [[ -z "$(git -C "$repository" status --porcelain)" ]] || { echo "$label has uncommitted changes; refusing to package a tree that differs from its commit." >&2; exit 1; }
  git -C "$repository" fetch --quiet origin main || { echo "Unable to refresh origin/main for $label." >&2; exit 1; }
  local local_head remote_head
  local_head="$(git -C "$repository" rev-parse HEAD)"
  remote_head="$(git -C "$repository" rev-parse origin/main)"
  [[ "$local_head" == "$remote_head" ]] || {
    echo "$label is not current with origin/main." >&2
    echo "  local:  $local_head" >&2
    echo "  remote: $remote_head" >&2
    echo "Run: git -C '$repository' pull --ff-only" >&2
    exit 1
  }
  printf '%s current at %s\n' "$label" "$local_head"
}

require_current_main "$root" FORGE-OS
require_current_main "$forge_source" FORGE

if [[ "$skip_packages" == false ]]; then "$root/scripts/bootstrap-arch.sh"; fi
"$root/scripts/configure-hardware.sh"

if [[ "$use_current_build" == false ]]; then
  "$root/scripts/build-forge.sh" "$forge_source"
else
  [[ -r "$root/build/latest.env" ]] || { echo 'No current local build record exists.' >&2; exit 1; }
  source "$root/build/latest.env"
  [[ "$FORGE_SOURCE_COMMIT" == "$(git -C "$forge_source" rev-parse HEAD)" ]] || { echo 'Current build does not match FORGE HEAD.' >&2; exit 1; }
  [[ "${FORGE_OS_COMMIT:-}" == "$(git -C "$root" rev-parse HEAD)" && "${FORGE_OS_VERSION:-}" == "$(<"$root/VERSION")" ]] || { echo 'Current build does not match this FORGE-OS revision/version.' >&2; exit 1; }
  [[ "${FORGE_PACKAGE_SHA256:-}" == "$(sha256sum "$forge_source/package.json" | awk '{print $1}')" ]] || { echo 'Current build does not match the FORGE package manifest.' >&2; exit 1; }
  [[ "${FORGE_LOCK_SHA256:-}" == "$(sha256sum "$forge_source/package-lock.json" | awk '{print $1}')" ]] || { echo 'Current build does not match the FORGE lockfile.' >&2; exit 1; }
fi

"$root/scripts/install-runtime.sh"
source "$root/build/latest.env"
[[ "$FORGE_SOURCE_COMMIT" == "$(git -C "$forge_source" rev-parse origin/main)" ]] || { echo 'Built runtime does not match current FORGE origin/main.' >&2; exit 1; }
[[ "$FORGE_PACKAGE_SHA256" == "$(sha256sum "$forge_source/package.json" | awk '{print $1}')" ]] || { echo 'Built runtime does not match the current FORGE package manifest.' >&2; exit 1; }
[[ "$FORGE_LOCK_SHA256" == "$(sha256sum "$forge_source/package-lock.json" | awk '{print $1}')" ]] || { echo 'Built runtime does not match the current FORGE lockfile.' >&2; exit 1; }

version="$(<"$root/VERSION")"
issue="$(mktemp)"
trap 'rm -f -- "$issue"' EXIT
sed -e "s/@VERSION@/$version/g" -e "s/@SOURCE_COMMIT@/${FORGE_SOURCE_COMMIT:0:12}/g" "$root/config/issue" >"$issue"

for command in greetd tuigreet kwin_wayland plasmashell qdbus6 krunner kdialog konsole systemsettings dbus-update-activation-environment; do
  command -v "$command" >/dev/null || { echo "Required command is missing: $command" >&2; exit 1; }
done
tuigreet --help 2>&1 | grep -F -- '--no-xsession-wrapper' >/dev/null || { echo 'Installed tuigreet does not support --no-xsession-wrapper.' >&2; exit 1; }
for file in session/forge-wayland-session session/forge-wayland-client session/forge-plasma-initialize session/forge-session scripts/forge-panel-manager; do bash -n "$root/$file"; done

sudo install -d -o root -g root -m 0755 \
  /usr/local/libexec \
  /etc/greetd \
  /etc/xdg \
  /usr/share/applications \
  /usr/share/xdg-desktop-portal \
  /usr/share/forge-os/wayland-sessions
sudo install -o root -g root -m 0755 "$root/session/forge-wayland-session" /usr/local/bin/forge-wayland-session
sudo install -o root -g root -m 0755 "$root/session/forge-session" /usr/local/bin/forge-session
sudo install -o root -g root -m 0755 "$root/session/forge-wayland-client" /usr/local/libexec/forge-wayland-client
sudo install -o root -g root -m 0755 "$root/session/forge-plasma-initialize" /usr/local/libexec/forge-plasma-initialize
for tool in forge-app-launcher forge-open forge-workspace-runner forge-install-program forge-panel-manager forge-os-update; do
  sudo install -o root -g root -m 0755 "$root/scripts/$tool" "/usr/local/bin/$tool"
done
sudo install -o root -g root -m 0644 "$root/config/kwinrc" /etc/xdg/kwinrc
sudo install -o root -g root -m 0644 "$root/config/kdeglobals" /etc/xdg/kdeglobals
sudo install -o root -g root -m 0644 "$root/config/forge-portals.conf" /usr/share/xdg-desktop-portal/forge-portals.conf
for desktop in forge-app-launcher.desktop forge-system-settings.desktop forge-workspace-runner.desktop forge-install-program.desktop forge-panel-manager.desktop; do
  sudo install -o root -g root -m 0644 "$root/session/$desktop" "/usr/share/applications/$desktop"
done
sudo install -o root -g root -m 0644 "$root/session/forge.desktop" /usr/share/forge-os/wayland-sessions/forge.desktop
sudo rm -f /usr/share/xsessions/forge.desktop /usr/share/forge-os/xsessions/forge.desktop \
  /usr/local/bin/forge-xsession /usr/local/libexec/forge-session-client
sudo install -o root -g root -m 0644 "$root/config/greetd-config.toml" /etc/greetd/config.toml
sudo install -o root -g root -m 0644 "$issue" /etc/issue
printf '%s\n' "$version" | sudo tee /etc/forge-os-version >/dev/null
sudo chown root:root /etc/forge-os-version
sudo chmod 0644 /etc/forge-os-version
install -d -m 0700 "$target_home/.local/state/forge"

sudo rm -f /etc/profile.d/forge-autostart.sh /etc/forge/session.env
if [[ -f "$target_home/.xinitrc" ]] && grep -q '/usr/local/bin/forge-session' "$target_home/.xinitrc" && grep -q 'FORGE_OS_SESSION=1' "$target_home/.xinitrc"; then
  rm -f "$target_home/.xinitrc"
fi

for pair in \
  "$root/session/forge-wayland-session:/usr/local/bin/forge-wayland-session" \
  "$root/session/forge-session:/usr/local/bin/forge-session" \
  "$root/session/forge-wayland-client:/usr/local/libexec/forge-wayland-client" \
  "$root/session/forge-plasma-initialize:/usr/local/libexec/forge-plasma-initialize" \
  "$root/scripts/forge-app-launcher:/usr/local/bin/forge-app-launcher" \
  "$root/scripts/forge-open:/usr/local/bin/forge-open" \
  "$root/scripts/forge-workspace-runner:/usr/local/bin/forge-workspace-runner" \
  "$root/scripts/forge-install-program:/usr/local/bin/forge-install-program" \
  "$root/scripts/forge-panel-manager:/usr/local/bin/forge-panel-manager" \
  "$root/scripts/forge-os-update:/usr/local/bin/forge-os-update" \
  "$root/config/kwinrc:/etc/xdg/kwinrc" \
  "$root/config/kdeglobals:/etc/xdg/kdeglobals" \
  "$root/config/forge-portals.conf:/usr/share/xdg-desktop-portal/forge-portals.conf" \
  "$root/session/forge-app-launcher.desktop:/usr/share/applications/forge-app-launcher.desktop" \
  "$root/session/forge-system-settings.desktop:/usr/share/applications/forge-system-settings.desktop" \
  "$root/session/forge-workspace-runner.desktop:/usr/share/applications/forge-workspace-runner.desktop" \
  "$root/session/forge-install-program.desktop:/usr/share/applications/forge-install-program.desktop" \
  "$root/session/forge-panel-manager.desktop:/usr/share/applications/forge-panel-manager.desktop" \
  "$root/session/forge.desktop:/usr/share/forge-os/wayland-sessions/forge.desktop" \
  "$root/config/greetd-config.toml:/etc/greetd/config.toml"; do
  sudo cmp -s "${pair%%:*}" "${pair#*:}" || { echo "Installed file mismatch: ${pair#*:}" >&2; exit 1; }
done

installed_executable="/opt/forge/current/${FORGE_EXECUTABLE_RELATIVE_PATH}"
[[ -x "$installed_executable" && -r /opt/forge/current/resources/app.asar ]] || { echo 'Installed runtime is incomplete.' >&2; exit 1; }
[[ "$(sha256sum "$installed_executable" | awk '{print $1}')" == "$FORGE_EXECUTABLE_SHA256" ]] || { echo 'Installed FORGE executable does not match the build record.' >&2; exit 1; }
[[ "$(sha256sum /opt/forge/current/resources/app.asar | awk '{print $1}')" == "$FORGE_APP_ASAR_SHA256" ]] || { echo 'Refusing to enable greetd with stale app.asar.' >&2; exit 1; }
getent passwd greeter >/dev/null || { echo 'The dedicated greeter account is missing.' >&2; exit 1; }

grep -q '^source_profile = false$' /etc/greetd/config.toml || { echo 'greetd profile sourcing is not disabled.' >&2; exit 1; }
grep -q -- "--cmd '/usr/local/bin/forge-wayland-session'" /etc/greetd/config.toml || { echo 'greetd does not default to FORGE Wayland.' >&2; exit 1; }
grep -q -- '--sessions /usr/share/forge-os/wayland-sessions' /etc/greetd/config.toml || { echo 'tuigreet is not isolated to the FORGE Wayland session directory.' >&2; exit 1; }

sudo systemctl disable getty@tty1.service >/dev/null 2>&1 || true
sudo systemctl enable getty@tty2.service
sudo systemctl enable greetd.service
sudo ln -sfn /usr/lib/systemd/system/greetd.service /etc/systemd/system/display-manager.service
sudo systemctl daemon-reload
sudo systemctl set-default graphical.target
"$root/scripts/configure-user-desktop.sh"
"$root/tests/verify.sh"
echo 'FORGE-OS installation verified. Reboot manually when ready.'
