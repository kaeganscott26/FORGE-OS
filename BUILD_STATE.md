# Current build state

Updated 2026-08-11 after physical login-loop diagnosis on the reference AMD laptop.

## Repository state

The tracked architecture uses one default-enabled graphical path: greetd/tuigreet on VT1, PAM authentication, repository-owned `forge-xsession`, one explicit xinit/Xorg boundary, `forge-session-client`, Openbox, and the content-addressed packaged FORGE runtime. Shell profile sourcing, tuigreet's implicit X11 `startx` wrapper, global session discovery, acceptance markers, tty1 profile autostart, `.xinitrc`, and manual `startx` are excluded from production startup.

Build identity is portable across checkout paths and the FORGE source commit is injected explicitly during exported-source packaging. Runtime executable and `app.asar` paths/hashes are recorded and verified before greetd is enabled.

## Latest physical diagnosis

The machine cold-boots directly to the FORGE-branded tuigreet screen and PAM authentication reaches `forge-xsession`, but Xorg previously terminated before `forge-session-client` became ready. The session log reproduced the decisive failure on each retry:

```text
amdgpu_device_initialize: amdgpu_query_info(ACCEL_WORKING) failed (-13)
Fatal server error:
AddScreen/ScreenInit failed for driver 0
```

Inspection of the reference machine showed that Arch's normal X entry point is `/usr/bin/X -> Xorg`; `/usr/bin/Xorg` is the distribution launcher, `/usr/lib/Xorg.wrap` is the setuid wrapper, and `/usr/lib/Xorg` is the private real server binary. FORGE-OS was explicitly passing `/usr/lib/Xorg` to xinit, bypassing the distribution launcher/wrapper path that the previously working manual Arch X startup used.

`session/forge-xsession` now passes `/usr/bin/X` to xinit instead. The verifier explicitly rejects direct `/usr/lib/Xorg` use. This repair requires another physical login test; repository inspection alone cannot prove the GPU/VT handoff succeeds.

## Human validation still required

After pulling FORGE-OS and reinstalling the current session, verify on the physical machine:

- cold boot reaches the FORGE login without an Arch console step;
- PAM login no longer produces the AMDGPU `-13` initialization failure;
- login does not loop;
- FORGE remains visible and fills the session;
- integrated terminal receives the XDG/D-Bus/FORGE environment contract;
- Chromium and Thunar launch;
- logout returns to the greeter and login works again;
- `Ctrl+Alt+F2` remains a usable independent recovery console;
- `tests/verify.sh` reports zero failures before an ISO is treated as release candidate.

Host-specific runtime identities are intentionally generated locally in ignored `build/latest.env` rather than frozen in this document.
