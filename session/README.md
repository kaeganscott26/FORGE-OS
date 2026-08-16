# 🖥️ FORGE-OS Runtime & Session Architecture

This directory contains the launchers, desktop entries, and session helpers that decide **how the installed FORGE runtime is hosted by Linux**.

FORGE itself remains the durable workspace/runtime boundary. Session selection changes the surrounding compositor, desktop services, compatibility layer, and OS-facing UI without requiring a different FORGE build.

> **Core invariant:** exactly one top-level component should own the graphical session and compositor. Host-owned and FORGE-owned session profiles are both valid, but they should not accidentally try to own KWin at the same time.

## 🧭 Session families

| Session family | Ownership | FORGE role | Status |
| --- | --- | --- | --- |
| **Standalone FORGE application** | Host OS / host desktop | Normal application | ✅ Supported |
| **FORGE hosted by Plasma Wayland** | Plasma/KWin owns session | Primary application/workspace | 🧪 Supported development profile; reference-machine override |
| **FORGE native KWin Wayland shell** | FORGE session launcher owns KWin | OS UX / shell | ✅ Canonical `0.2.x` FORGE-OS profile |
| **Native KWin Wayland + Electron XWayland** | FORGE session launcher owns KWin | OS UX / shell; Electron compatibility fallback | ✅ Compatibility profile |
| **Plasma 6 / KWin X11** | KWin X11 owns session | Primary workspace | 🗃️ Historical `0.1.2`–`0.1.3` |
| **X11 / Openbox** | Xorg + Openbox owns session | Primary workspace | 🗃️ Historical `0.1.1` |
| **TTY recovery** | systemd/getty | No graphical FORGE shell | ✅ Recovery path |

## 🟢 Canonical FORGE-owned Wayland session

The repository default is:

```bash
/usr/local/bin/forge-wayland-session
```

Boot/session ownership is:

```text
greetd / tuigreet
  -> forge-wayland-session
  -> KWin Wayland (+ XWayland compatibility)
  -> forge-wayland-client
  -> KDE support services + plasmashell beneath FORGE
  -> forge-session
  -> /opt/forge/current/<recorded FORGE executable>
```

`forge-wayland-session` exports the FORGE shell contract (`FORGE_OS_SESSION=1`, `FORGE_SHELL_MODE=1`, `XDG_CURRENT_DESKTOP=FORGE`, `XDG_SESSION_TYPE=wayland`) and starts KWin directly with `--exit-with-session` lifecycle ownership.

This profile means **FORGE owns the desktop experience and KDE/Plasma provides infrastructure underneath it**.

Related implementation:

- [`forge-wayland-session`](forge-wayland-session)
- [`forge-wayland-client`](forge-wayland-client)
- [`forge-session`](forge-session)
- [`forge-plasma-initialize`](forge-plasma-initialize)
- [Desktop Session guide](../docs/DESKTOP_SESSION.md)
- [Architecture](../ARCHITECTURE.md)

## 🔵 Plasma-hosted Wayland profile

The current reference machine has also been tested with a manual login-screen override:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

This profile establishes a conventional Plasma Wayland environment first, then hands off to the FORGE session launcher. Its intended use is development, compatibility testing, and a more conventional Linux-hosted FORGE experience.

### Important ownership warning

`startplasma-wayland` normally establishes a Plasma/KWin session, while [`forge-wayland-session`](forge-wayland-session) is itself designed to start and own KWin. Nesting the two can therefore create **duplicate session/compositor ownership** unless the handoff is explicitly normalized.

Potential symptoms include:

- duplicate or unexpected Plasma panels;
- application-launcher discovery differences;
- D-Bus or XDG environment disagreement;
- portals bound to a different session identity;
- focus/window-placement differences;
- logout returning to the wrong parent session;
- KDE services restarting UI that FORGE intentionally removed;
- a second KWin launch failing or producing inconsistent behavior.

For that reason, this command is documented as a **reference-machine/development override**, not as the canonical ISO release path. A future first-class Plasma-hosted profile should launch FORGE *inside* the already-owned Plasma session without asking FORGE to start another compositor.

## 🟡 Native Wayland + Electron XWayland fallback

The desktop remains native KWin Wayland, but FORGE's Electron window can use XWayland for compatibility:

```bash
FORGE_USE_XWAYLAND=1 /usr/local/bin/forge-wayland-session
```

Internally [`forge-session`](forge-session) switches Electron from:

```text
--ozone-platform=wayland
```

to:

```text
--ozone-platform=x11
```

This is a rendering compatibility option, **not a different compositor architecture**.

## 🗃️ Historical X11 profiles

### `0.1.2-alpha`–`0.1.3-alpha` — Plasma 6 / KWin X11

The bridge architecture used Plasma 6/KWin X11 with an Openbox fallback while retaining the X11/xinit login chain.

Login command:

```bash
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

### `0.1.1-alpha` — X11 / Openbox

The earlier session used Xorg/xinit with Openbox as the lightweight window-management substrate and FORGE as the primary workspace.

These profiles are preserved in Git history and the [Changelog](../CHANGELOG.md); they are not installed as current `0.2.x` production entries.

## 🍎🪟🐧 Standalone FORGE application profile

FORGE can also run as the normal cross-platform desktop application on macOS, Windows, or an existing Linux desktop such as Plasma, GNOME, Garuda, Debian, or Arch.

In this mode:

- the host OS owns the desktop/compositor;
- `FORGE_OS_SESSION` and `FORGE_SHELL_MODE` are absent;
- FORGE-OS-only launcher, package, power, panel, and system surfaces should remain hidden;
- the host desktop owns application launchers, settings, panels, notifications, and session lifecycle.

This profile belongs primarily to the separate FORGE repository; FORGE-OS documents it here because the same packaged runtime can participate in multiple Linux session profiles.

## ⌨️ Selecting a session from the login screen

At the FORGE-branded `tuigreet` screen:

1. Press **F2**.
2. Enter the complete session command.
3. Return to the credential prompt.
4. Authenticate normally.
5. `greetd` launches the selected command for that login.

Common commands:

```bash
# Canonical FORGE-owned Wayland shell
/usr/local/bin/forge-wayland-session

# Current reference-machine Plasma-hosted development override
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session

# Historical X11 chain (only when the retired components are actually installed)
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

A bad path or unavailable compositor returns the graphical session to the greeter. `Ctrl+Alt+F2` remains the independent recovery console.

See the [User Manual](../docs/USER_MANUAL.md) and [Recovery Guide](../docs/RECOVERY.md).

## 🎛️ Expected UI behavior by profile

| Surface | Standalone app | Plasma-hosted FORGE | Native FORGE-OS shell |
| --- | --- | --- | --- |
| FORGE workspace/files/Git/terminal/agents | ✅ | ✅ | ✅ |
| FORGE-OS Applications surfaces | ❌ | Optional / profile-dependent | ✅ |
| FORGE package-management UX | ❌ | Optional / profile-dependent | ✅ |
| FORGE panel/system chrome | ❌ | Optional; avoid duplicating Plasma | ✅ |
| FORGE OS settings integration | ❌ | Partial/delegated | ✅ |
| Host desktop panel/settings | Host-owned | Plasma-owned | Hidden/underlying unless opted in |
| Session power/logout ownership | Host-owned | Plasma-owned | FORGE/greetd-owned |

The renderer should eventually consume an explicit runtime-profile capability contract rather than infer behavior only from `process.platform`, Wayland presence, or KDE environment variables.

## 🧪 Compatibility and validation matrix

When debugging a graphical issue, move down the compatibility ladder without changing the workspace data:

```text
Native FORGE Wayland
  -> Native KWin Wayland + Electron XWayland
  -> Plasma-hosted FORGE
  -> historical X11 profile (development/recovery only)
  -> tty2 recovery
```

This helps isolate whether a problem belongs to Electron/Ozone, KWin, Plasma services, session environment propagation, graphics drivers, or FORGE itself.

Before a stable ISO release, the canonical FORGE-owned profile must pass the [Release Checklist](../docs/RELEASE_CHECKLIST.md) without requiring an F2 override.

## 🔗 Related documentation

- [FORGE-OS README](../README.md)
- [Architecture](../ARCHITECTURE.md)
- [Build State](../BUILD_STATE.md)
- [Documentation Hub](../docs/README.md)
- [Desktop Session](../docs/DESKTOP_SESSION.md)
- [Shell Mode](../docs/SHELL_MODE.md)
- [User Manual](../docs/USER_MANUAL.md)
- [Security Model](../docs/SECURITY_MODEL.md)
- [Recovery](../docs/RECOVERY.md)
- [Release Checklist](../docs/RELEASE_CHECKLIST.md)
- [Implementation Gaps](../docs/IMPLEMENTATION_GAPS.md)
- [Changelog](../CHANGELOG.md)
- [Wayland development notes](../Dev_Notes/Wayland_Stack.md)
