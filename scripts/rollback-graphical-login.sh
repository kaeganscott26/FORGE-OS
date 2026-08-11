#!/usr/bin/env bash
set -euo pipefail
sudo systemctl disable greetd.service 2>/dev/null || true
sudo rm -f /usr/local/bin/forge-xsession /usr/share/xsessions/forge.desktop
echo 'FORGE graphical-login integration removed; startx and runtime data were preserved.'
