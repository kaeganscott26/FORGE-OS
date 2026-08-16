# 🤝 Contributing to FORGE-OS

Thanks for helping improve FORGE-OS. Keep changes aligned with the project boundary: generic FORGE application work belongs in the separate FORGE repository, while Arch integration, boot/session behavior, packaging, recovery, hardware configuration, and ISO work belong here.

## 🧱 Preserve the production invariants

Contributions must preserve:

- PAM authentication;
- normal-user FORGE execution;
- canonical post-auth command `/usr/local/bin/forge-wayland-session`;
- exactly one top-level graphical session/compositor owner;
- content-addressed runtime verification;
- root-owned Electron sandbox permissions;
- tty2 recovery access;
- one authoritative installation path;
- FORGE remaining the foreground shell over KWin Wayland and Plasma visual services in native shell mode;
- workspace executable paths remaining canonical and workspace-contained;
- package installation remaining authenticated and free of renderer-supplied shell commands;
- FORGE-OS updates remaining visible, fast-forward-only, and routed through the authoritative installer.

Do not introduce permanent autologin, profile-driven graphical startup, an X11 production session, acceptance-marker gating, permanent `--no-sandbox`, arbitrary renderer-controlled update commands, or a second competing installer.

### Host-owned desktop profiles

A conventional Plasma/GNOME/etc. session may be supported as a **host-owned FORGE profile**, but it must be explicitly separated from the canonical FORGE-owned shell architecture.

A host-owned profile must not ask FORGE to start a second compositor. The current reference-machine `startplasma-wayland ... forge-wayland-session` F2 wrapper is documented as a development override with known duplicate-KWin/session ownership risk, not as the stable default.

See [`session/README.md`](session/README.md) before changing session commands or desktop ownership.

## 🎛️ Runtime-aware UI

Changes to launcher, package, panel, settings, power/session, notification, or other OS-facing UI must specify which runtime profiles expose the feature:

- standalone FORGE;
- host-owned Linux desktop / Plasma-hosted FORGE;
- native FORGE-OS shell.

Avoid relying only on broad Linux/KDE/Wayland detection when the behavior depends on who owns the desktop/session.

## ✅ Validate changes

Run the relevant shell syntax checks and `tests/verify.sh`. FORGE application changes should also pass the complete FORGE repository quality gates before being incorporated into a FORGE-OS build.

Physical graphics, boot, login, audio, networking, package-install/application-refresh, portal, or hardware behavior that cannot be proven in repository tests must be called out explicitly and validated against the [Release Checklist](docs/RELEASE_CHECKLIST.md).

## 📚 Before changing architecture

Review:

- [Runtime & Session Architecture](session/README.md)
- [Documentation Hub](docs/README.md)
- [Architecture](ARCHITECTURE.md)
- [Current Build State](BUILD_STATE.md)
- [Architectural Decisions](docs/DECISIONS.md)
- [Security Model](docs/SECURITY_MODEL.md)
- [Implementation Gaps](docs/IMPLEMENTATION_GAPS.md)
- [Release Checklist](docs/RELEASE_CHECKLIST.md)
