# Console-login handoff for the accepted FORGE session.
# Installed into /etc/profile.d only after packaged runtime acceptance.
if [ -r /etc/forge/session.env ]; then
  . /etc/forge/session.env
fi

if [ "${USER:-}" = "${FORGE_SESSION_USER:-}" ] && \
   [ "$(tty 2>/dev/null)" = /dev/tty1 ] && \
   [ -z "${DISPLAY:-}" ] && \
   [ ! -e "$HOME/.config/forge/disable-autostart" ] && \
   command -v startx >/dev/null 2>&1; then
  startx
  status=$?
  printf 'FORGE graphical session exited with status %s; console remains available.\n' "$status"
  unset status
fi
