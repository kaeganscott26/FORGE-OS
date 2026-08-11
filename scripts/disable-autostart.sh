#!/usr/bin/env bash
set -euo pipefail

sudo rm -f /etc/profile.d/forge-autostart.sh /etc/forge/session.env
echo 'TTY1 FORGE handoff disabled. Session runtime and workspace data were preserved.'
