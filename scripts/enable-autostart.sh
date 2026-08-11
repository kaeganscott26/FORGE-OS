#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
acceptance="$repository_root/build/acceptance.env"
[[ -r "$acceptance" ]] || { echo 'Manual packaged-runtime acceptance is not recorded.' >&2; exit 1; }
source "$acceptance"
[[ "${PACKAGED_RUNTIME_ACCEPTED:-}" == yes ]] || { echo 'Packaged runtime is not accepted.' >&2; exit 1; }

sudo install -d -o root -g root -m 0755 /etc/forge
sudo install -o root -g root -m 0644 "$repository_root/config/session.env" /etc/forge/session.env
sudo install -o root -g root -m 0644 "$repository_root/session/forge-autostart.sh" /etc/profile.d/forge-autostart.sh
echo 'TTY1 login handoff enabled. Other gettys remain unchanged.'
