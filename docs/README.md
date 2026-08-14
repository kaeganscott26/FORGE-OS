# 📚 FORGE-OS Documentation Hub

Welcome to the FORGE-OS documentation. This directory is organized around three audiences: users running FORGE-OS, developers maintaining the platform, and release maintainers producing distributable images.

These guides describe the current `0.2.1-alpha` FORGE-owned Wayland session and integrated source-based updater.

## 🚀 Start here

| Goal | Guide |
| --- | --- |
| Install or use **Check for updates** on a development/reference machine | [User Manual](USER_MANUAL.md) |
| Understand boot, login, and the desktop session | [Desktop Session](DESKTOP_SESSION.md) |
| Understand the OS/application boundary | [Architecture](../ARCHITECTURE.md) |
| Recover from a broken graphical session | [Recovery](RECOVERY.md) |
| Prepare and validate an ISO release | [Release Checklist](RELEASE_CHECKLIST.md) |
| Review unresolved engineering work | [Implementation Gaps](IMPLEMENTATION_GAPS.md) |
| Review important architectural choices | [Decisions](DECISIONS.md) |
| Review the security model | [Security Model](SECURITY_MODEL.md) |
| Understand FORGE shell-mode behavior | [Shell Mode](SHELL_MODE.md) |

## 🧭 Repository map

- [`config/`](../config/) — greetd, issue branding, and system configuration templates.
- [`manifests/`](../manifests/) — declared Arch package dependencies.
- [`overlays/`](../overlays/) — temporary FORGE patches required by the OS integration layer.
- [`scripts/`](../scripts/) — bootstrap, build, authenticated update, install, ISO, recovery, and desktop helpers.
- [`session/`](../session/) — FORGE graphical-session entry points.
- [`tests/`](../tests/) — production invariant verification.
- [`BUILD_STATE.md`](../BUILD_STATE.md) — current physical/runtime validation status.
- [`CHANGELOG.md`](../CHANGELOG.md) — project change history.

## 🧱 Project boundary

FORGE-OS is the Arch Linux integration and distribution layer for the separate FORGE application repository. Arch owns the kernel, system services, drivers, networking, audio, package management, and hardware integration. FORGE owns the visible workspace and desktop experience.

Generic application fixes belong in the FORGE repository. Boot, session, packaging, hardware integration, recovery, and ISO concerns belong here.

## ✅ Documentation policy

Current documentation must describe the production path only. Historical experiments, temporary debugging prompts, machine-generated state, and obsolete installation paths should not remain mixed into active guides. Unresolved engineering work belongs in [Implementation Gaps](IMPLEMENTATION_GAPS.md); historical behavior belongs in Git history and the [Changelog](../CHANGELOG.md).
