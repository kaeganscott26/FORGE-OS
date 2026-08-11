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

forge_source="${FORGE_SOURCE:-$HOME/FORGE}"

require_current_main() {
  local repository="$1"
  local label="$2"
  [[ -d "$repository/.git" ]] || { echo "$label is not a Git repository: $repository" >&2; exit 1; }
  [[ "$(git -C "$repository" branch --show-current)" == main ]] || { echo "$label must be on main for a production FORGE-OS install." >&2; exit 1; }
  [[ -z "$(git -C "$repository" status --porcelain)" ]] || { echo "$label has uncommitted changes; refusing to package a commit that does not describe the working tree." >&2; exit 1; }
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

# Production installation must never silently package a stale local checkout.
# Fetch and compare both repositories before doing package, runtime, or system
# changes. The installer intentionally refuses dirty/diverged trees rather than
# modifying or discarding developer work.
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
fi
"$root/scripts/install-runtime.sh"

source "$root/build/latest.env"
[[ "$FORGE_SOURCE_COMMIT" == "$(git -C "$forge_source" rev-parse origin/main)" ]] || { echo 'Built runtime does not match current FORGE origin/main.' >&2; exit 1; }
version="$(<"$root/VERSION")"
issue="$(mktemp)"
trap 'rm -f -- "$issue"' EXIT
sed -e "s/@VERSION@/$version/g" -e "s/@SOURCE_COMMIT@/${FORGE_SOURCE_COMMIT:0:12}/g" "$root/config/issue" >"$issue"
for command in greetd tuigreet Xorg xinit openbox; do command -v "$command" >/dev/null || { echo "Required command is missing: $command" >&2; exit 1; }; done
for file in session/forge-xsession session/forge-session-client session/forge-session; do bash -n "$root/$file"; done

sudo install -d -o root -g root -m 0755 /usr/local/libexec /etc/greetd
sudo install -o root -g root -m 0755 "$root/session/forge-xsession" /usr/local/bin/forge-xsession
sudo install -o root -g root -m 0755 "$root/session/forge-session" /usr/local/bin/forge-session
sudo install -o root -g root -m 0755 "$root/session/forge-session-client" /usr/local/libexec/forge-session-client
sudo install -o root -g root -m 0644 "$root/session/forge.desktop" /usr/share/xsessions/forge.desktop
sudo install -o root -g root -m 0644 "$root/config/greetd-config.toml" /etc/greetd/config.toml
sudo install -o root -g root -m 0644 "$issue" /etc/issue
printf '%s\n' "$version" | sudo tee /etc/forge-os-version >/dev/null
sudo chown root:root /etc/forge-os-version
sudo chmod 0644 /etc/forge-os-version
install -d -m 0700 "$target_home/.local/state/forge"

sudo rm -f /etc/profile.d/forge-autostart.sh /etc/forge/session.env
if [[ -f "$target_home/.xinitrc" ]] && grep -q '/usr/local/bin/forge-session' "$target_home/.xinitrc" && grep -q 'FORGE_OS_SESSION=1' "$target_home/.xinitrc"; then rm -f "$target_home/.xinitrc"; fi
for pair in "$root/session/forge-xsession:/usr/local/bin/forge-xsession" "$root/session/forge-session:/usr/local/bin/forge-session" "$root/session/forge-session-client:/usr/local/libexec/forge-session-client" "$root/config/greetd-config.toml:/etc/greetd/config.toml"; do
  sudo cmp -s "${pair%%:*}" "${pair#*:}" || { echo "Installed file mismatch: ${pair#*:}" >&2; exit 1; }
done
[[ -x /opt/forge/current/forge && -r /opt/forge/current/resources/app.asar ]] || { echo 'Installed runtime is incomplete.' >&2; exit 1; }
[[ "$(sha256sum /opt/forge/current/resources/app.asar | awk '{print $1}')" == "$FORGE_APP_ASAR_SHA256" ]] || { echo 'Refusing to enable greetd with stale app.asar.' >&2; exit 1; }
getent passwd greeter >/dev/null || { echo 'The dedicated greeter account is missing.' >&2; exit 1; }

sudo systemctl enable getty@tty2.service
sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target
"$root/scripts/configure-user-desktop.sh"
"$root/tests/verify.sh"
echo 'FORGE-OS installation verified. Reboot manually when ready.'
