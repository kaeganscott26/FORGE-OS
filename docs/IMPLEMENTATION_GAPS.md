# 🧪 Implementation Gaps

This file tracks unresolved engineering work that still affects distribution quality. Resolved debugging notes should be removed rather than accumulating here.

## 🔴 Restore the authoritative Arch package manifest

[`scripts/bootstrap-arch.sh`](../scripts/bootstrap-arch.sh) currently reads:

```text
manifests/arch-packages.txt
```

That file is absent from the current repository. The repository contains `manifests/arch-packages.sh`, but the bootstrap script does not consume it, and the current shell-script content is not a valid line-oriented replacement for the missing manifest.

This is a **fresh-install/update blocker** whenever the authoritative installer runs package bootstrap without `--skip-packages`.

Resolution should do one of the following deliberately:

- restore a valid `manifests/arch-packages.txt` matching the package set required by `tests/verify.sh`; or
- change `bootstrap-arch.sh`, ISO tooling, installer documentation, and tests together to a new authoritative manifest format.

After repair, validate a clean package bootstrap on Arch and ensure the installer, ISO builder, verifier, and documentation all consume the same package source of truth.

`--skip-packages` is only appropriate when the required packages are already present; it is not a substitute for restoring the distribution manifest.

## ⚖️ Normalize the Plasma-hosted FORGE profile

The canonical `0.2.x` FORGE-OS path is FORGE-owned:

```text
greetd -> forge-wayland-session -> KWin Wayland -> FORGE
```

The current reference machine has also used this F2 override:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

That profile is useful for development and compatibility testing, but it is not yet a fully normalized host-owned session because `startplasma-wayland` normally establishes Plasma/KWin while `forge-wayland-session` is also designed to start KWin.

A first-class Plasma-hosted profile should:

- detect that a compositor/session already exists;
- launch FORGE into that environment without creating a second KWin instance;
- define which UI surfaces belong to Plasma versus FORGE;
- preserve D-Bus, XDG portals, PolicyKit, notifications, file dialogs, and logout behavior from the host session;
- expose a clear runtime-profile identity to FORGE.

See [`session/README.md`](../session/README.md).

## 🎛️ Explicit runtime-profile capability contract

FORGE currently distinguishes shell mode primarily through environment/session state such as `FORGE_OS_SESSION=1` and `FORGE_SHELL_MODE=1`. As the number of supported session presentations grows, OS-facing UI should be governed by an explicit runtime profile rather than broad Linux/KDE/Wayland inference.

The profile should express capabilities such as:

- session owner (`host` or `forge`);
- compositor/backend (`kwin-wayland`, `xwayland`, historical X11, etc.);
- shell UI enabled/disabled;
- application launcher ownership;
- package-management UI ownership;
- panel/system-tray ownership;
- power/logout ownership;
- settings integration level;
- portal/notification ownership.

This prevents standalone FORGE, Plasma-hosted FORGE, and native FORGE-OS from exposing conflicting system UI.

## 📦 Package installation UX and application discovery

The current package helper securely validates Arch package names and delegates privileged installation to PolicyKit/pacman, but the user experience still needs consolidation.

Current gaps:

- package installation opens an external terminal/window instead of a native FORGE surface;
- newly installed applications may appear in KDE/Qt application discovery before they appear in FORGE's Applications UI;
- FORGE should refresh/watch XDG application directories after package transactions;
- the user-facing command surface should converge on a stable `forge install ...` namespace while pacman remains the underlying package authority;
- install/remove/search/info/update operations need consistent UI and error reporting.

FORGE should remain a normal user process; privilege escalation stays isolated behind PolicyKit/native package services.

## 🎨 Desktop UX polish

The native Wayland shell still needs distribution-quality consistency across:

- FORGE renderer theming;
- KWin window decorations/effects;
- Qt and GTK themes;
- icons and cursor theme;
- wallpaper/login branding;
- application launcher behavior;
- panels/tray/clock/network/audio/battery surfaces;
- notifications;
- portals and file dialogs;
- external application focus/window placement;
- Settings surfaces for network, audio, displays, power, applications, storage, appearance, updates, security, recovery, and advanced controls.

The goal is not to reimplement mature Linux services; FORGE should provide the user-facing control plane while KWin/Plasma/systemd/NetworkManager/PipeWire/PolicyKit/pacman remain the underlying infrastructure.

## 🧠 Upstream FORGE `file.read` continuation normalization

FORGE agents can legitimately continue a bounded `file.read` using a returned `offset`. Model-generated continuation calls may repeat earlier `startLine` / `endLine` values while also supplying that offset. Upstream FORGE currently rejects that mixed request shape with `offset cannot be combined with line ranges`.

FORGE-OS temporarily carries [`overlays/0002-tolerate-file-read-continuation-arguments.patch`](../overlays/0002-tolerate-file-read-continuation-arguments.patch) so packaged FORGE runtimes remain usable while the upstream contract is corrected.

The overlay:

- normalizes numeric-string range values to integers;
- treats a supplied continuation `offset` as authoritative;
- discards repeated line-range values when `offset` is present;
- adds regression coverage for the mixed continuation shape.

This behavior belongs upstream in FORGE. Once the upstream fix lands and passes FORGE validation, remove the compatibility overlay and rebuild FORGE-OS so the overlay/runtime identity changes intentionally.

## 💿 Distribution installer and release pipeline

The repository includes ArchISO-style image tooling intended to use the same runtime/session layout as the physical installation. A polished end-user distribution still needs:

- repaired/validated package-manifest bootstrap;
- guided disk installation and partitioning UX;
- hardware compatibility documentation;
- signed release artifacts and/or a signed update channel;
- automated release provenance;
- a signed binary/OS update channel that does not require local source checkouts;
- broader multi-hardware validation.

The current development/reference updater is source-based: it updates clean trusted checkouts with fast-forward-only Git operations and runs the verified installer. A future signed artifact channel should preserve the same provenance, authentication, recovery, and no-downgrade guarantees.

## 🧪 Stable ISO validation

The earlier X11 runtime was physically demonstrated. The current KWin Wayland path still requires full cold-boot, native Electron, XWayland compatibility, KDE portal/PipeWire, wallpaper/panel persistence, compositor-failure, logout/relogin, package-bootstrap, package-install/application-refresh, and ISO validation using the [Release Checklist](RELEASE_CHECKLIST.md).

Stable validation must use the canonical direct FORGE-owned session without requiring an F2 override.

## 📚 Maintenance rule

Keep this file short and current. When a gap is resolved, remove it and record the completed change in the [Changelog](../CHANGELOG.md). Historical debugging detail belongs in Git history rather than current user documentation.
