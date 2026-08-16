#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
legacy_recovery_link=/etc/systemd/system/graphical.target.wants/forge-recovery.service

# 0.2.2 briefly enabled graphical recovery at every graphical boot. Recovery is
# now an on-demand tty2 alias; remove the obsolete target link before installing
# the current unit so the old activation model cannot survive an upgrade.
if [[ -e "$legacy_recovery_link" || -L "$legacy_recovery_link" ]]; then
  sudo rm -f -- "$legacy_recovery_link"
  sudo systemctl daemon-reload
fi

exec "$root/scripts/install-forge-linux.sh" "$@"
