#!/usr/bin/env bash
set -uo pipefail
failures=0
check() { if "$@" >/dev/null 2>&1; then printf 'PASS: %s\n' "$*"; else printf 'FAIL: %s\n' "$*"; failures=$((failures + 1)); fi; }
for unit in dbus-broker NetworkManager power-profiles-daemon irqbalance bluetooth; do check systemctl is-active "$unit.service"; done
check systemctl is-enabled greetd.service
check test -x /usr/local/bin/forge-xsession
check test -r /etc/greetd/config.toml
check test -x /opt/forge/current/forge
printf 'Kernel: running %s; installed %s\n' "$(uname -r)" "$(pacman -Q linux 2>/dev/null | awk '{print $2}')"
printf 'CPU driver: %s; governor: %s\n' "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver 2>/dev/null || echo unavailable)" "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo unavailable)"
printf 'SUMMARY: %d failure(s)\n' "$failures"
(( failures == 0 ))
