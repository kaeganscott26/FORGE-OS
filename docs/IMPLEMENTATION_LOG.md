# Implementation log

## 2026-08-11 boot/session consolidation

- Removed acceptance markers, tty1 profile autostart, manual-startx setup, `.xinitrc` installation, and split session installers.
- Added one complete installer that builds, installs, preflights, enables greetd, selects graphical target, and preserves tty2 recovery.
- Made runtime releases content-addressed and verified full payload plus `app.asar` before pointer activation.
- Corrected Electron sandbox installation and ISO runtime layout.
- Moved the FORGE PTY/tool environment fix and shell-window behavior into the FORGE repository.
- Replaced warning-based checks with mandatory production invariants.

Automated checks cannot truthfully replace the final physical reboot/login/application tests listed in the release checklist.
