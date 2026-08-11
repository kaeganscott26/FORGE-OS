# Current build state

Updated 2026-08-11 after the full repository consistency audit.

## Repository state

The tracked architecture now uses one default-enabled graphical path: greetd/tuigreet on VT1, PAM authentication, repository-owned `forge-xsession`, one explicit xinit/Xorg boundary, `forge-session-client`, Openbox, and the content-addressed packaged FORGE runtime. Shell profile sourcing, tuigreet's implicit X11 `startx` wrapper, global session discovery, acceptance markers, tty1 profile autostart, `.xinitrc`, and manual `startx` are excluded from production startup.

Build identity is now portable across checkout paths and the FORGE source commit is injected explicitly during exported-source packaging. Runtime executable and `app.asar` paths/hashes are recorded and verified before greetd is enabled.

## Last physical observation before this audit

The machine successfully booted directly to the FORGE-branded tuigreet screen. Authentication started Xorg, but the graphical session returned to the greeter instead of remaining in FORGE. That test occurred before the current fixes for greetd profile sourcing, tuigreet X-session isolation/wrapper behavior, and the expanded runtime diagnostics. Therefore the next physical reboot is a required validation, not a presumed success.

## Human validation still required

After pulling both repositories and running `./scripts/install-forge-linux.sh`, verify on the physical machine:

- cold boot reaches the FORGE login without an Arch console step;
- login does not loop;
- FORGE remains visible and fills the session;
- integrated terminal receives the XDG/D-Bus/FORGE environment contract;
- Chromium and Thunar launch;
- logout returns to the greeter and login works again;
- `Ctrl+Alt+F2` remains a usable independent recovery console;
- `tests/verify.sh` reports zero failures before an ISO is treated as release candidate.

Host-specific runtime identities are intentionally generated locally in ignored `build/latest.env` rather than frozen in this document.
