#!/usr/bin/env bash
set -euo pipefail
sudo systemctl disable --now greetd.service
sudo systemctl set-default multi-user.target
sudo systemctl enable --now getty@tty1.service
sudo systemctl enable --now getty@tty2.service
echo 'greetd disabled. Console login is available on tty1 and tty2; installed runtime and user data were preserved.'
