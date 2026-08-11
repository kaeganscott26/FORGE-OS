#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$root/scripts/bootstrap-arch.sh"
"$root/scripts/configure-hardware.sh"
"$root/scripts/build-forge.sh" "${FORGE_SOURCE:-$HOME/FORGE}"
"$root/scripts/install-runtime.sh"
"$root/scripts/install-session.sh"
"$root/scripts/configure-user-desktop.sh"
"$root/scripts/install-graphical-login.sh"
echo 'Run startx and docs/ACCEPTANCE.md, then enable-graphical-login.sh. Reboot manually.'
