#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repository_root/build/latest.env"
version="$(<"$repository_root/VERSION")"
short_commit="${FORGE_SOURCE_COMMIT:0:12}"
rendered_issue="$(mktemp)"
trap 'rm -f -- "$rendered_issue"' EXIT
command -v greetd >/dev/null 2>&1 || { echo 'Install the tracked package manifest first (greetd is missing).' >&2; exit 1; }
command -v tuigreet >/dev/null 2>&1 || { echo 'tuigreet is required before staging greetd.' >&2; exit 1; }
sed -e "s/@VERSION@/$version/g" -e "s/@SOURCE_COMMIT@/$short_commit/g" "$repository_root/config/issue" >"$rendered_issue"

sudo install -o root -g root -m 0755 "$repository_root/session/forge-xsession" /usr/local/bin/forge-xsession
sudo install -o root -g root -m 0644 "$repository_root/session/forge.desktop" /usr/share/xsessions/forge.desktop
sudo install -d -o root -g root -m 0755 /etc/greetd
sudo install -o root -g root -m 0644 "$repository_root/config/greetd-config.toml" /etc/greetd/config.toml
sudo install -o root -g root -m 0644 "$rendered_issue" /etc/issue
echo 'Graphical login files staged. greetd remains disabled; startx remains the accepted path.'
