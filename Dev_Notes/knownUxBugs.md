# 🐞 Known FORGE-OS UX Issues

**Current as of 2026-08-15 · FORGE-OS `0.2.1-alpha`**

This file tracks user-facing issues observed on the current reference machine. Resolved items should be removed from this file and recorded in [`CHANGELOG.md`](../CHANGELOG.md).

## 📦 Package installation leaves the FORGE UX

The current `forge-install-program` flow validates package names and securely delegates to PolicyKit/pacman, but its desktop entry opens a separate terminal/window. Installation can succeed while the experience feels like leaving FORGE.

Target behavior:

- keep pacman as the package authority;
- keep privilege escalation behind PolicyKit;
- expose installation/search/remove/update through a FORGE-facing surface;
- converge the user-facing command namespace toward `forge install ...` rather than proliferating helper names.

See [Implementation Gaps](../docs/IMPLEMENTATION_GAPS.md).

## 🧭 Newly installed apps may not refresh in FORGE Applications

A newly installed package can appear in KDE/Qt application discovery while not immediately appearing in FORGE's Applications surface.

FORGE should invalidate/rescan or watch the relevant XDG application directories after package transactions, including:

```text
~/.local/share/applications
/usr/local/share/applications
/usr/share/applications
```

The install itself and application discovery should be treated as separate concerns.

## ⚖️ Plasma-hosted reference override can have competing session ownership

Reference-machine F2 command:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

This works as a useful development configuration, but `startplasma-wayland` normally starts/owns Plasma/KWin while `forge-wayland-session` is also designed to start KWin.

Potential symptoms:

- duplicate/unexpected panels;
- mismatched app discovery;
- D-Bus/XDG portal disagreement;
- focus/window placement inconsistencies;
- logout/session lifecycle surprises;
- duplicate compositor startup failure.

The canonical release path remains `/usr/local/bin/forge-wayland-session`. A future dedicated Plasma-hosted launcher should run FORGE inside the already-owned Plasma session without starting KWin twice.

See [`session/README.md`](../session/README.md).

## 🎨 Wayland shell polish remains incomplete

The underlying native Wayland architecture is in place, but the user experience still needs consistency across:

- application launcher and installed-app refresh;
- package install flow;
- panels/tray/clock/network/audio/battery surfaces;
- System Settings integration;
- notifications;
- Qt/GTK/KWin/FORGE theme consistency;
- portals/file dialogs;
- external application focus/window behavior;
- runtime-profile-specific UI visibility.

## ✅ Recovery remains available

These UX issues should not remove the independent recovery path:

```text
Ctrl+Alt+F2
```

The stable release gate is [`docs/RELEASE_CHECKLIST.md`](../docs/RELEASE_CHECKLIST.md).
