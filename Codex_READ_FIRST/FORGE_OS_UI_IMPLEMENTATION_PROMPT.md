# Codex Implementation Prompt: Build the FORGE-OS Desktop Experience

## Role

You are implementing the next stage of FORGE-OS: turning the existing recoverable Arch Linux + Xorg + Openbox + packaged FORGE runtime into a cohesive desktop experience whose Linux scaffolding is mostly invisible to the user.

Treat this document as an implementation brief, not permission to make unbounded system changes. Inspect both repositories before editing:

- `~/FORGE` — Electron application, renderer, IPC, provider-neutral intelligence, capability controls, terminal, tasks, memory, and workspace storage.
- `~/FORGE-OS` — reproducible Arch integration, package manifests, session launchers, installation/update logic, verification, recovery, and build history.

The project folder is authoritative. Preserve existing architectural decisions and recovery guarantees.

## Current verified state

The current reference stack is:

```text
firmware/bootloader
  -> Arch Linux + systemd
  -> TTY login
  -> startx
  -> Xorg + Openbox
  -> immutable packaged FORGE runtime
```

Known facts:

- FORGE runs as the normal user and must never run as root.
- The tested runtime is installed under `/opt/forge/releases/<source-commit>` and selected through `/opt/forge/current`.
- `/usr/local/bin/forge-session` is the root-owned stable launcher.
- `~/.xinitrc` starts the graphical session.
- Session logs are written to `~/.local/state/forge/session.log`.
- `tests/verify.sh` passes non-graphical checks.
- Manual packaged-app X acceptance is still the gate before login autostart may be enabled.
- TTY/getty recovery must remain available.
- There is no display manager in the current accepted baseline.
- FORGE is functional, but the visible flow still feels like an application inside Arch rather than the desktop shell.
- The integrated terminal has previously failed to inherit one or more of `DISPLAY`, `XAUTHORITY`, `XDG_RUNTIME_DIR`, and `DBUS_SESSION_BUS_ADDRESS`, even while the user systemd manager and D-Bus broker were healthy.
- PipeWire/WirePlumber audio discovery has been brought up, but optional integrations such as RTKit, UPower, BlueZ, and libcamera may not all be present.

Read these files first:

- `ARCHITECTURE.md`
- `BUILD_STATE.md`
- `README.md`
- `docs/DECISIONS.md`
- `docs/RECOVERY.md`
- `docs/ACCEPTANCE.md`
- `config/session.env`
- `session/forge-session`
- `session/xinitrc`
- `session/forge-autostart.sh`
- `scripts/install-session.sh`
- `scripts/enable-autostart.sh`
- `scripts/disable-autostart.sh`
- `scripts/rollback-session.sh`
- `tests/verify.sh`
- `manifests/arch-packages.txt`

Also inspect the relevant UI, IPC, capability, settings, terminal spawning, and persistence code in `~/FORGE`. Do not guess its architecture from this prompt.

## Product objective

Create a FORGE-first desktop UX with this eventual user-visible flow:

```text
boot -> graphical login -> FORGE session -> FORGE desktop UI
```

Linux remains the operating substrate, but routine desktop functions should be discoverable and controllable from FORGE. The user should not need to memorize shell commands for ordinary tasks.

For this milestone, retain X11/Xorg as the reference implementation. Do **not** migrate to Wayland. A future move to a lightweight Wayland compositor such as labwc may be evaluated after the X11 implementation is stable.

## Required capabilities

### 1. FORGE desktop shell

Implement a desktop-shell layer in the FORGE renderer that provides:

- A persistent top or bottom system bar.
- A clock with local date/time and a click target for a calendar/time panel.
- An applications menu populated from installed Linux desktop entries.
- A settings entry point.
- Visible network, audio, power/battery, and session status where supported.
- User-accessible actions for lock, log out/end session, restart, and power off.
- Clear degraded states when a backing service or utility is unavailable.

Do not silently hide failures. If a capability is unavailable, show why and identify the missing dependency or service without exposing raw implementation noise by default.

### 2. Linux application discovery and launching

Implement standards-based application discovery:

- Read `.desktop` entries from appropriate XDG application directories, including system and user locations.
- Respect `Hidden`, `NoDisplay`, `OnlyShowIn`, `NotShowIn`, `TryExec`, `Terminal`, icon, category, and localized name semantics where practical.
- Parse `Exec` safely; do not execute it through an interpolated shell string.
- Handle standard desktop-entry field codes deliberately.
- Launch applications as the logged-in normal user with the graphical/session environment intact.
- Support application search, categories, favorites/pinning, and recent launches.
- Resolve icons using XDG icon-theme conventions with a safe fallback.
- For `Terminal=true`, launch through a configured terminal strategy rather than ignoring the flag.
- Surface launch failures in the UI and structured logs.

Application metadata crossing Electron boundaries must go through typed, validated IPC. Do not expose unrestricted filesystem or process APIs to the renderer.

### 3. Settings UI

Add a settings area with a provider-neutral and service-aware architecture. At minimum include:

#### Appearance

- Light/dark/system theme.
- Accent color.
- Wallpaper/background selection.
- UI scaling and font-size controls.
- Panel placement and clock format.
- Persist settings per user with versioned schema and safe defaults.

#### Displays

- Enumerate connected displays using an appropriate X11 backend.
- Configure resolution, refresh rate, orientation, relative placement, and primary display.
- Preview or require confirmation for risky changes, with automatic rollback after a timeout.
- Never leave a display configuration permanently unusable after a failed apply.

#### Audio

- Display PipeWire/WirePlumber sinks, sources, defaults, volume, and mute state where available.
- Use supported tools/APIs such as `wpctl` behind a narrow adapter.
- Show an actionable unavailable state if the audio stack is absent.

#### Network

- Show NetworkManager connection status and available controls through a narrow backend.
- Prefer stable APIs (`nmcli` with machine-readable output or D-Bus) over parsing human-oriented text.
- Do not store Wi-Fi secrets in FORGE project metadata or logs.
- Any secret entry must use an appropriate OS-backed flow and must never be sent to an AI provider.

#### Bluetooth

- Detect BlueZ availability.
- Provide status and device management only when the required service is installed and active.
- Present installation/configuration guidance rather than failing when absent.

#### Power

- Integrate UPower where available for battery and power-device status.
- Provide safe suspend/restart/power-off actions through the existing OS authorization mechanism.
- Require explicit user confirmation for disruptive actions.

#### Date and time

- Show timezone, current date/time, and synchronization state.
- Separate read-only inspection from privileged modifications.
- Route privileged changes through narrowly scoped, auditable authorization.

#### Users, permissions, and capabilities

- Show the current Unix user and group memberships.
- Explain that Linux permissions remain authoritative.
- Expose FORGE application/tool capability permissions separately from Unix permissions.
- Never grant blanket sudo from the UI.
- Never edit `/etc/sudoers` directly; use validated, narrowly scoped system integration only after explicit design review.
- Record user-visible audit evidence for sensitive operations without logging secrets.

#### Services and diagnostics

- Show relevant system and user service status: NetworkManager, PipeWire, PipeWire Pulse compatibility, WirePlumber, D-Bus, UPower, Bluetooth, graphical session, and FORGE session/runtime information.
- Distinguish system units from user units.
- Provide safe start/restart actions only for an explicit allowlist.
- Display relevant bounded logs with secret redaction.
- Do not expose an arbitrary root command runner.

### 4. Correct session environment propagation

Fix the session/integrated-terminal environment at its source. The integrated terminal and externally launched graphical applications must inherit valid values for:

- `DISPLAY`
- `XAUTHORITY`
- `XDG_RUNTIME_DIR`
- `DBUS_SESSION_BUS_ADDRESS`
- relevant XDG data/config/cache paths

Requirements:

- Determine where the environment is lost by tracing `xinitrc` -> session launcher -> Electron main process -> PTY child/external application child.
- Preserve valid inherited values rather than overwriting them blindly.
- Derive fallbacks only when safe and verify that referenced paths/sockets exist.
- Reject malformed D-Bus addresses.
- Synchronize the graphical environment with the user service manager/D-Bus activation environment using the standard session mechanism where appropriate.
- Do not use `.bashrc` exports as the permanent fix.
- Add automated tests around environment construction and child-process spawning.
- Add a diagnostic view or command that reports presence/validity without leaking secrets.

### 5. Graphical login and automatic session startup

Design and stage a graphical login path, but do not enable it until all acceptance gates pass.

Requirements:

- Evaluate a minimal display manager compatible with the existing Arch/X11 stack.
- Keep authentication delegated to standard Linux/PAM mechanisms; FORGE must not implement or store system passwords.
- Add tracked package/config manifests and reproducible installation scripts.
- Configure a dedicated FORGE X session that launches the immutable tested runtime.
- Preserve a TTY recovery path and document how to reach it.
- Provide explicit enable, disable, and rollback scripts.
- A failed FORGE launch must return to the greeter or preserve console access; it must not create a crash loop.
- Do not enable automatic login by default.
- Do not enable the display manager or alter the boot target as part of implementation/testing without explicit human approval.
- Keep the existing `startx` path working until graphical-login acceptance is complete.

### 6. Theme system

Create a coherent theme model rather than scattered style toggles:

- Define versioned theme tokens for color, typography, spacing, borders, shadows, and states.
- Ship accessible light and dark defaults.
- Enforce useful contrast and keyboard-focus visibility.
- Allow user themes only through a validated declarative format; do not execute theme-provided JavaScript.
- Ensure shell surfaces, settings, terminal chrome, dialogs, menus, and notifications use the same token system.

### 7. Security and Electron boundary

Preserve or improve Electron hardening:

- Keep renderer context isolation.
- Do not enable renderer Node integration.
- Expose only narrow typed preload APIs.
- Validate all IPC input in the main process.
- Use argument arrays rather than shell interpolation for subprocesses.
- Separate read-only inspection from mutating actions.
- Require explicit confirmation for privileged or destructive actions.
- Redact passwords, tokens, Wi-Fi secrets, environment secrets, and provider credentials from logs and task evidence.
- Keep all OS-level privilege elevation narrow, reviewable, and independent from model-generated arbitrary commands.

## Repository ownership and implementation placement

Place code according to the existing boundary:

### In `~/FORGE`

- Desktop shell renderer components.
- Settings UI and state model.
- Application menu/index.
- Typed preload and IPC contracts.
- Service adapters and safe process launching owned by the app.
- Capability prompts, validation, audit integration, and tests.

### In `~/FORGE-OS`

- Package manifest additions.
- X11/display-manager/session configuration templates.
- Install/enable/disable/rollback scripts.
- System integration verification.
- Recovery and acceptance documentation.
- Build-state and decision records.

Do not create a second durable workspace-memory database. Project state remains in each project's `.forge/metadata.sqlite`. User desktop preferences should use the existing FORGE settings/persistence architecture after it is inspected; document any new storage schema.

## Implementation sequence

Work in small, reviewable phases. At the beginning, report the files and architecture you found and propose an exact change plan.

### Phase A — discovery and design

1. Inspect both repositories and current Git state.
2. Identify existing settings, IPC, capability, storage, terminal, process, and renderer patterns.
3. Map current X session startup and environment flow.
4. Record architectural decisions and threat boundaries.
5. Propose exact files to change before implementation.

### Phase B — session environment fix

1. Reproduce with a bounded environment diagnostic.
2. Fix propagation at the correct boundary.
3. Add unit/integration tests.
4. Verify user systemd and D-Bus access from the integrated terminal.
5. Verify an externally launched graphical program receives the expected display/session environment.

### Phase C — desktop shell and application launcher

1. Build panel, clock, app menu, and settings entry.
2. Implement desktop-entry indexing and safe launching.
3. Add keyboard navigation and accessibility.
4. Add tests using representative valid and malformed `.desktop` fixtures.

### Phase D — settings and service adapters

1. Implement appearance and theme settings.
2. Add read-only service/device status adapters.
3. Add safe mutating controls one subsystem at a time.
4. Add unavailable/degraded behavior and tests.
5. Add audit records for sensitive actions.

### Phase E — graphical login staging

1. Select and document the minimal display-manager approach.
2. Add reproducible tracked configs/scripts.
3. Extend verification and recovery docs.
4. Test manually without enabling persistent startup first.
5. Ask for explicit human approval before enabling a display manager or changing boot behavior.

## Testing requirements

Add tests at the appropriate layer for:

- Desktop-entry parsing, filtering, field-code handling, and safe argument construction.
- IPC schema validation and authorization failures.
- Session environment inheritance and fallback validation.
- Settings migration and corrupt-setting recovery.
- Theme validation.
- Missing-service and malformed-output behavior.
- Display-change rollback logic.
- Redaction of credentials and secrets.
- Install script idempotency where feasible.
- Enable/disable/rollback behavior without destructive side effects.

Run all existing FORGE quality gates and `FORGE-OS/tests/verify.sh`. Report exact commands and results. Do not claim manual GUI behavior passed unless a human actually performed the acceptance steps.

## Acceptance criteria

The milestone is complete only when:

1. The packaged FORGE runtime opens as the normal user in the existing X11 session.
2. The user sees a coherent desktop shell with a clock, application menu, settings, and session controls.
3. Installed GUI applications can be discovered and launched without terminal commands.
4. FORGE terminals and launched applications receive valid X11, XDG runtime, and D-Bus environment values.
5. Core settings expose useful status and controls with graceful missing-service behavior.
6. No renderer gains unrestricted Node, filesystem, process, systemd, or root access.
7. Existing workspace, terminal, task, memory, Git, and provider capabilities continue to work.
8. TTY recovery and `startx` fallback remain usable.
9. Disable and rollback procedures are documented and tested.
10. Automated checks pass and manual results are recorded in `docs/ACCEPTANCE.md`/`BUILD_STATE.md`.
11. Persistent graphical-login startup remains disabled until explicit human acceptance and approval.

## Prohibited actions

- Do not repartition, format, erase, or mount unrelated storage.
- Do not modify firmware or the bootloader.
- Do not run FORGE as root.
- Do not disable recovery TTYs.
- Do not remove the working `startx` path prematurely.
- Do not migrate to Wayland in this milestone.
- Do not add blanket passwordless sudo.
- Do not place credentials in source, logs, task state, or project metadata.
- Do not enable graphical autostart, automatic login, or reboot without explicit human approval.
- Do not silently replace immutable packaged artifacts with development builds.
- Do not execute `.desktop` commands or settings values through unvalidated shell strings.

## Deliverables

Produce:

- Implemented and tested changes in the correct repository/repositories.
- A concise architecture/design record.
- Updated package/config manifests.
- Reproducible install/update/enable/disable/rollback scripts as needed.
- Updated `tests/verify.sh` and application tests.
- Updated `docs/RECOVERY.md` and `docs/ACCEPTANCE.md`.
- Updated `BUILD_STATE.md` containing observed facts, exact versions/commits/artifact hashes, test outcomes, unresolved risks, and the next dependency-ready action.
- A final report separating automated verification from manual acceptance.

## Required behavior while working

- Preserve unrelated user changes; inspect Git status before every broad edit.
- Prefer targeted edits over rewrites.
- Stop and ask before any privileged, persistent startup, reboot, authentication, or destructive operation.
- Clearly label evidence versus inference.
- If a dependency is missing, report it and update the reproducible manifest rather than installing ad hoc without approval.
- Keep the machine recoverable at every checkpoint.
