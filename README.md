# 🔥 FORGE-OS

> **Experimental:** FORGE-OS is an Arch Linux-based reference implementation,
> not yet a stable general-purpose distribution. Use test hardware or a machine
> with verified backups.

This repository is the reproducible operating-system integration layer for the
FORGE Linux experiment on Arch Linux. Arch remains responsible for the kernel,
hardware, package management, networking, systemd, authentication, and normal
Unix permissions. FORGE is being developed as the persistent user-facing
workspace/runtime above that substrate.

The FORGE application source remains in `../FORGE`. Workspace state remains in
each project's `.forge/metadata.sqlite`; this repository does not create a
competing memory store.

FORGE and FORGE-OS are intentionally versioned and published separately:

- [FORGE](https://github.com/kaeganscott26/FORGE) is the cross-platform
  application/runtime.
- FORGE-OS is the Linux package, session, recovery, and future distribution
  integration layer.

The current integration record pins the consumed FORGE source commit and
artifact hashes in `build/latest.env` and `BUILD_STATE.md`. FORGE source is not
copied into this repository.

Current FORGE-OS integration version: **0.1.0-alpha**. See `VERSION` for the
machine-readable value. The project is licensed under the MIT License.

## 🧭 Start here

- [📘 User manual](docs/USER_MANUAL.md)
- [🏗️ Architecture](ARCHITECTURE.md)
- [✅ Acceptance](docs/ACCEPTANCE.md)
- [🛟 Recovery](docs/RECOVERY.md)
- [🚢 ISO release checklist](docs/RELEASE_CHECKLIST.md)
- [🧾 Implementation log and human actions](docs/IMPLEMENTATION_LOG.md)
- [📝 Changelog](CHANGELOG.md)

## 🛡️ Safety boundary

- Do not repartition, format, or erase storage.
- Do not rewrite firmware or the bootloader without a separately reviewed need.
- Run FORGE as the normal user, never as root.
- Preserve a usable TTY recovery path.
- Keep installed integration files reproducible from this repository.
- Remove blanket passwordless sudo before calling the system stable.
- Destructive storage operations are outside unattended automation.

Current observed state and the next dependency-ready work are recorded in
`BUILD_STATE.md`.

## 🚀 Install workflow

```text
scripts/bootstrap-arch.sh
  -> scripts/build-forge.sh
  -> scripts/install-runtime.sh
  -> scripts/install-session.sh
  -> tests/verify.sh
  -> manual packaged-app acceptance with startx
  -> optional scripts/enable-autostart.sh
```

Use `scripts/enable-forge-os.sh` for the reproducible installation sequence.
After human acceptance, `scripts/enable-graphical-login.sh` makes the next boot
present the FORGE-OS login and launch the FORGE UI. Build release media with
`scripts/build-iso.sh`; see `docs/RELEASE_CHECKLIST.md` before publishing.
