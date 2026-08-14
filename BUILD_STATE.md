# ✅ Current Build State

**Updated: 2026-08-14**

FORGE-OS now has a physically demonstrated login path that reaches the FORGE desktop after credential verification. The decisive runtime command is the direct X11 client launch below:

```bash
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

## 🟢 Confirmed working

- System boots into the FORGE-branded greetd/tuigreet login flow.
- PAM authentication succeeds.
- The direct `xinit` + `forge-session-client` command reaches the FORGE graphical environment.
- The repository default session command has been changed to match that verified runtime path.
- `session/forge-xsession` now resolves to the same verified command instead of maintaining a separate custom display/Xorg-launch policy.
- The desktop entry and verifier are aligned with the same runtime command.
- tty2 remains the independent recovery console.

## 🧱 Production chain

```text
systemd graphical.target
  -> greetd on VT1
  -> FORGE-branded tuigreet
  -> PAM authentication
  -> /usr/bin/xinit /usr/local/libexec/forge-session-client
  -> Plasma 6 KWin X11 + desktop helpers (Openbox fallback)
  -> /usr/local/bin/forge-session
  -> /opt/forge/current/<recorded FORGE executable>
```

## 🧪 Validation still required before a stable ISO tag

The runtime path is stable enough to proceed with release-candidate work, but the repository version remains an alpha (`0.1.2-alpha`) until the complete release gate passes. Plasma 6/KWin integration is implemented with an Openbox fallback and still requires physical windowing/theme validation.

Before publishing an ISO as stable:

- cold boot after pulling and reinstalling the current repository state;
- confirm login requires no F2 command override;
- confirm FORGE remains active after login;
- verify integrated-terminal XDG/D-Bus/FORGE environment variables;
- launch Chromium and Thunar;
- validate networking and audio;
- test logout → greeter → login;
- confirm tty2 recovery;
- run `tests/verify.sh` with zero failures;
- build the ISO and verify its checksum;
- boot the ISO on the reference machine and at least one additional hardware/VM target.

Use the full [Release Checklist](docs/RELEASE_CHECKLIST.md) as the publication gate.

## 📚 Current documentation

- [README](README.md)
- [Documentation Hub](docs/README.md)
- [Architecture](ARCHITECTURE.md)
- [Desktop Session](docs/DESKTOP_SESSION.md)
- [User Manual](docs/USER_MANUAL.md)
- [Recovery](docs/RECOVERY.md)
- [Release Checklist](docs/RELEASE_CHECKLIST.md)

Historical experimental startup approaches are not part of the current production documentation. Git history and the [Changelog](CHANGELOG.md) preserve that development record.
