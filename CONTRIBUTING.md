# 🤝 Contributing to FORGE-OS

Thanks for helping improve FORGE-OS. Keep changes aligned with the project boundary: generic FORGE application work belongs in the separate FORGE repository, while Arch integration, boot/session behavior, packaging, recovery, hardware configuration, and ISO work belong here.

## 🧱 Preserve the production invariants

Contributions must preserve:

- PAM authentication;
- normal-user FORGE execution;
- the verified post-auth command `/usr/bin/xinit /usr/local/libexec/forge-session-client`;
- content-addressed runtime verification;
- root-owned Electron sandbox permissions;
- tty2 recovery access;
- one authoritative installation path.

Do not introduce permanent autologin, profile-driven graphical startup, manual `startx` setup, acceptance-marker gating, permanent `--no-sandbox`, or a second competing installer.

## ✅ Validate changes

Run the relevant shell syntax checks and `tests/verify.sh`. FORGE application changes should also pass the complete FORGE repository quality gates before being incorporated into a FORGE-OS build.

Physical graphics, boot, login, audio, networking, or hardware behavior that cannot be proven in repository tests must be called out explicitly and validated against the [Release Checklist](docs/RELEASE_CHECKLIST.md).

## 📚 Before changing architecture

Review:

- [Documentation Hub](docs/README.md)
- [Architecture](ARCHITECTURE.md)
- [Architectural Decisions](docs/DECISIONS.md)
- [Security Model](docs/SECURITY_MODEL.md)
- [Implementation Gaps](docs/IMPLEMENTATION_GAPS.md)
