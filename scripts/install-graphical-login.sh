#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v greetd >/dev/null 2>&1 || { echo 'Install the tracked package manifest first (greetd is missing).' >&2; exit 1; }
command -v tuigreet >/dev/null 2>&1 || { echo 'tuigreet is required before staging greetd.' >&2; exit 1; }

sudo install -o root -g root -m 0755 "$repository_root/session/forge-xsession" /usr/local/bin/forge-xsession
sudo install -o root -g root -m 0644 "$repository_root/session/forge.desktop" /usr/share/xsessions/forge.desktop
sudo install -d -o root -g root -m 0755 /etc/greetd
sudo install -o root -g root -m 0644 "$repository_root/config/greetd-config.toml" /etc/greetd/config.toml
echo 'Graphical login files staged. greetd remains disabled; startx remains the accepted path.'
