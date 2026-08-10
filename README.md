# FORGE OS Integration

This repository is the reproducible operating-system integration layer for the
FORGE Linux experiment on Arch Linux. Arch remains responsible for the kernel,
hardware, package management, networking, systemd, authentication, and normal
Unix permissions. FORGE is being developed as the persistent user-facing
workspace/runtime above that substrate.

The FORGE application source remains in `../FORGE`. Workspace state remains in
each project's `.forge/metadata.sqlite`; this repository does not create a
competing memory store.

## Safety boundary

- Do not repartition, format, or erase storage.
- Do not rewrite firmware or the bootloader without a separately reviewed need.
- Run FORGE as the normal user, never as root.
- Preserve a usable TTY recovery path.
- Keep installed integration files reproducible from this repository.
- Remove blanket passwordless sudo before calling the system stable.

Current observed state and the next dependency-ready work are recorded in
`BUILD_STATE.md`.
