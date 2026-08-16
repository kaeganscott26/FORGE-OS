# 📚 FORGE-OS Documentation Hub

Welcome to the FORGE-OS documentation. This directory is organized around users running FORGE-OS, developers maintaining the platform, and release maintainers producing distributable images.

These guides describe the current `0.2.1-alpha` architecture: a canonical FORGE-owned KWin Wayland shell, a documented Plasma-hosted development profile, runtime/session switching from `tuigreet`, and the integrated source-based updater.

## 🚀 Start here

| Goal | Guide |
| --- | --- |
| Understand every available runtime/session profile and its ownership rules | [Runtime & Session Architecture](../session/README.md) |
| Install or use **Check for updates** on a development/reference machine | [User Manual](USER_MANUAL.md) |
| Understand boot, login, and the canonical desktop session | [Desktop Session](DESKTOP_SESSION.md) |
| Understand the OS/application boundary | [Architecture](../ARCHITECTURE.md) |
| Understand FORGE shell-only UI behavior | [Shell Mode](SHELL_MODE.md) |
| Recover from a broken graphical session | [Recovery](RECOVERY.md) |
| Prepare and validate an ISO release | [Release Checklist](RELEASE_CHECKLIST.md) |
| Review unresolved engineering/UX work | [Implementation Gaps](IMPLEMENTATION_GAPS.md) |
| Review important architectural choices | [Decisions](DECISIONS.md) |
| Review the security model | [Security Model](SECURITY_MODEL.md) |

## 🧭 Repository map

- [`config/`](../config/) — greetd, issue branding, portal, and system configuration templates.
- [`manifests/`](../manifests/) — declared Arch package dependencies.
- [`overlays/`](../overlays/) — temporary FORGE patches required by the OS integration layer.
- [`scripts/`](../scripts/) — bootstrap, build, authenticated update, install, ISO, recovery, package, and desktop helpers.
- [`session/`](../session/) — FORGE graphical-session entry points, desktop entries, and the authoritative [runtime/session guide](../session/README.md).
- [`tests/`](../tests/) — production invariant verification.
- [`BUILD_STATE.md`](../BUILD_STATE.md) — current physical/runtime validation status and active UX gaps.
- [`CHANGELOG.md`](../CHANGELOG.md) — project change history.
- [`Dev_Notes/`](../Dev_Notes/) — current development notes only; obsolete runtime experiments are removed rather than left as active guidance.

## 🧱 Project boundary

FORGE-OS is the Arch Linux integration and distribution layer for the separate FORGE application repository. Arch owns the kernel, system services, drivers, networking, audio, package management, and hardware integration. FORGE owns the visible workspace and desktop experience when shell mode is active.

The same FORGE runtime can also run as a normal standalone application or inside a host-owned Linux desktop. Session selection changes the graphical host, not the workspace identity.

Generic application fixes belong in the FORGE repository. Boot, session, packaging, hardware integration, recovery, and ISO concerns belong here.

## ⚖️ Session ownership rule

Exactly one top-level component should own the graphical session/compositor:

- **Host-owned:** Plasma/GNOME/etc. owns the session and FORGE runs inside it.
- **FORGE-owned:** `forge-wayland-session` owns KWin/session lifecycle and FORGE becomes the OS UX layer.

The current reference-machine Plasma wrapper is useful for development but is not treated as equivalent to the canonical direct FORGE-owned path until duplicate compositor ownership is normalized. See [Runtime & Session Architecture](../session/README.md).

## ✅ Documentation policy

Current documentation must describe the current architecture and clearly label historical/runtime-development paths. Temporary debugging prompts, machine-generated state, superseded scripts, and obsolete installation instructions should not remain mixed into active guides.

Unresolved work belongs in [Implementation Gaps](IMPLEMENTATION_GAPS.md) and [`Dev_Notes/knownUxBugs.md`](../Dev_Notes/knownUxBugs.md); historical behavior belongs in Git history and the [Changelog](../CHANGELOG.md).
