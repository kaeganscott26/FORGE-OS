#!/usr/bin/env bash
set -uo pipefail

failures=0
warnings=0
pass() { printf 'PASS: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL: %s\n' "$*"; failures=$((failures + 1)); }
check_command() { command -v "$1" >/dev/null 2>&1 && pass "$1 is available" || fail "$1 is unavailable"; }

source /etc/os-release 2>/dev/null || true
[[ "${ID:-}" == arch ]] && pass 'operating system is Arch Linux' || fail 'operating system is not Arch Linux'
[[ "$(id -u)" -ne 0 ]] && pass 'running as a normal user' || fail 'running as root'
for command in node npm git codex Xorg startx openbox xdg-open dbus-update-activation-environment; do check_command "$command"; done
[[ "$(node --version 2>/dev/null)" == v22.* ]] && pass 'Node major version is 22' || fail "Node version is $(node --version 2>/dev/null || echo missing)"
systemctl is-enabled NetworkManager.service >/dev/null 2>&1 && pass 'NetworkManager is enabled' || fail 'NetworkManager is not enabled'
sudo visudo -c >/dev/null 2>&1 && pass 'sudo policy parses' || fail 'sudo policy does not parse'
for package in nodejs-lts-jod xorg-server xorg-xinit openbox gtk3 mesa; do
  pacman -Q "$package" >/dev/null 2>&1 && pass "$package is installed" || fail "$package is not installed"
done
for file in session/forge-xsession session/forge.desktop config/greetd-config.toml config/issue scripts/install-graphical-login.sh scripts/enable-graphical-login.sh scripts/disable-graphical-login.sh scripts/rollback-graphical-login.sh scripts/configure-user-desktop.sh scripts/rollback-user-desktop.sh docs/SHELL_MODE.md; do
  [[ -e "$HOME/FORGE-OS/$file" ]] && pass "$file is tracked integration input" || fail "$file is absent"
done
bash -n "$HOME/FORGE-OS/session/forge-xsession" && pass 'tracked graphical-session launcher parses' || fail 'tracked graphical-session launcher has invalid shell syntax'
if [[ -e /usr/local/bin/forge-xsession ]]; then
  bash -n /usr/local/bin/forge-xsession && pass 'installed graphical-session launcher parses' || fail 'installed graphical-session launcher has invalid shell syntax'
  cmp -s "$HOME/FORGE-OS/session/forge-xsession" /usr/local/bin/forge-xsession && pass 'installed graphical-session launcher matches repository' || fail 'installed graphical-session launcher is stale'
else
  warn 'graphical-session launcher is not installed yet'
fi
systemctl is-enabled greetd.service >/dev/null 2>&1 && warn 'greetd is enabled before graphical acceptance is recorded' || pass 'greetd persistent startup is disabled'
[[ -d "$HOME/FORGE/.git" ]] && pass 'FORGE repository exists' || fail 'FORGE repository is absent'
[[ -d "$HOME/FORGE-OS/.git" ]] && pass 'FORGE-OS repository exists' || fail 'FORGE-OS repository is absent'
git -C "$HOME/FORGE" fsck --no-dangling >/dev/null 2>&1 && pass 'FORGE Git is healthy' || fail 'FORGE Git check failed'
git -C "$HOME/FORGE-OS" fsck --no-dangling >/dev/null 2>&1 && pass 'FORGE-OS Git is healthy' || fail 'FORGE-OS Git check failed'
[[ -x /usr/local/bin/forge-session ]] && pass 'session launcher is executable' || warn 'session launcher is not installed yet'
[[ -x /opt/forge/current/forge || -x /opt/forge/current/FORGE ]] && pass 'staged runtime is executable' || warn 'staged runtime is not installed yet'
[[ -x "$HOME/.xinitrc" ]] && pass 'xinit session is installed' || warn 'xinit session is not installed yet'
[[ -f /etc/sudoers.d/90-forge-experiment ]] && warn 'named temporary sudo rule is active' || pass 'named temporary sudo rule is absent'
if sudo -n true 2>/dev/null; then warn 'some non-interactive sudo authority is active'; else pass 'sudo requires authentication'; fi
systemctl is-enabled getty@.service >/dev/null 2>&1 && pass 'getty recovery template is enabled' || fail 'getty recovery template is not enabled'
[[ -r "$HOME/FORGE-OS/docs/RECOVERY.md" ]] && pass 'recovery documentation exists' || fail 'recovery documentation is absent'
printf 'SUMMARY: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
(( failures == 0 ))
