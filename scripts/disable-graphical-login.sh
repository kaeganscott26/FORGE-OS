#!/usr/bin/env bash
set -euo pipefail
sudo systemctl disable greetd.service
echo 'greetd disabled. Existing console gettys and startx session were preserved.'
