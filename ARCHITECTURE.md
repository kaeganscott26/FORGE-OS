# FORGE OS Architecture

## System boundary

```text
firmware and bootloader
        -> Linux kernel and Arch userspace
        -> systemd, NetworkManager, graphics and audio services
        -> minimal recoverable graphical session
        -> FORGE desktop workspace runtime
        -> workspace-owned files, Git, tasks, memory and audit evidence
        -> replaceable terminal/provider agents
```

Linux remains the low-level operating substrate. FORGE does not replace the
kernel, init system, package manager, filesystem, networking stack, drivers, or
Unix permission model.

## Repository ownership

- `~/FORGE` owns the Electron application and its provider-neutral intelligence,
  capability, storage, task, terminal, IPC, and renderer implementations.
- `~/FORGE-OS` owns reproducible Linux session launchers, installation/update
  logic, system integration, verification, rollback instructions, and observed
  build history.
- A project's `.forge/metadata.sqlite` remains the durable project-state store.

System-installed files must be derived from tracked files here. Development
launches are bootstrap evidence only; an automatic session must target a tested,
immutable packaged FORGE artifact identified by source commit and SHA-256.

## Recovery invariants

- FORGE runs as the normal user.
- Failure to launch FORGE must return to or preserve access to a console.
- Recovery virtual terminals remain enabled.
- Session logs are inspectable without FORGE.
- Automatic startup has a documented disable/rollback path.
- Privileged actions are narrow and explicit in the stable system.

## Desktop ownership boundary

- Xorg/Openbox owns window management and provides a recovery-friendly
  graphical substrate and fallback launcher.
- FORGE owns the visible shell, application discovery and launch, workspace,
  terminal, Git, agents, browser/research, status, settings, and OS UX.
- greetd is the staged login broker. PAM owns authentication; greetd is not
  enabled until a separate human acceptance record exists.
- A future Wayland/labwc port may replace the substrate after the X11 reference
  implementation is accepted without changing the FORGE shell contract.

See `docs/SECURITY_MODEL.md` for renderer, desktop-file, workspace, secret, and
privilege boundaries.

FORGE shell mode and its typed main-process boundary are documented in
`docs/SHELL_MODE.md`. System/session operations are a closed action set; the
renderer cannot supply executables, arguments, systemd units, or sudo strings.
