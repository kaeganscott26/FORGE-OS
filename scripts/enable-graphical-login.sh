#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
acceptance="$repository_root/build/graphical-login-acceptance.env"
[[ -r "$acceptance" ]] || { echo 'Human graphical-login acceptance is not recorded.' >&2; exit 1; }
source "$acceptance"
[[ "${GRAPHICAL_LOGIN_ACCEPTED:-}" == yes ]] || { echo 'Graphical login is not accepted.' >&2; exit 1; }
[[ -x /usr/local/bin/forge-xsession && -r /etc/greetd/config.toml ]] || { echo 'Run install-graphical-login.sh first.' >&2; exit 1; }
sudo systemctl enable greetd.service
echo 'greetd will start on the next human-controlled boot. No reboot was performed.'
