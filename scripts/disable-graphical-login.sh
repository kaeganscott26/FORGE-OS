#!/usr/bin/env bash
set -euo pipefail
sudo systemctl disable --now greetd.service
sudo systemctl enable --now getty@tty2.service
echo 'greetd disabled. The tty2 recovery console and installed runtime were preserved.'
