# Contributing

Generic FORGE application work belongs in the sibling FORGE repository. Arch dependencies, login/session ownership, KWin/Plasma integration, package frontends, recovery, runtime install/update/rollback, and ISO construction belong here.

Preserve these invariants:

- exact canonical command `startplasma-wayland forge-wayland-session forge-wayland-client` and unchanged installed paths;
- one compositor owner and normal-user FORGE execution;
- PAM for normal login and PolicyKit/sudo only at explicit mutation boundaries;
- content-addressed runtime verification, root-owned mode-4755 Electron sandbox, and persistent workspace/memory state;
- on-demand native tty2 recovery;
- pacman as the Arch authority, with apt/Kali/Nix isolated;
- native FORGE Explorer/settings/launcher surfaces rather than delegating the primary workflow to Dolphin/System Settings;
- no arbitrary renderer-controlled shell/update/package commands;
- no reset/discard, permanent autologin, permanent `--no-sandbox`, X11 production fallback, or competing installer.

Run `./tests/source-verify.sh` for repository work. Run `./tests/verify.sh` only against an intentionally installed candidate. Boot/session/GPU/audio/network/portal/recovery/ISO changes also require the physical gates in [the release checklist](docs/RELEASE_CHECKLIST.md).
