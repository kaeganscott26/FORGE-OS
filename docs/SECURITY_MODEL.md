# 🔐 Security Model

FORGE-OS keeps Linux as the authority for users, PAM authentication, permissions, services, networking, filesystems, and hardware. FORGE owns the desktop experience without replacing the operating system's security model.

## 👤 User and login boundary

- `tuigreet` runs as the unprivileged dedicated `greeter` account.
- PAM authenticates the selected normal user.
- The FORGE graphical session runs as that authenticated user.
- Production autologin is not configured.
- `greetd` uses `source_profile = false`, so shell profiles cannot silently become part of graphical-session startup.

The canonical post-authentication command is:

```bash
/usr/local/bin/forge-wayland-session
```

Tuigreet discovers only the FORGE-owned Wayland entry by default. KWin runs rootlessly as the authenticated user; XWayland is a compatibility service, not a login/session backend.

## ⌨️ F2 session-command selection

The greeter can accept an alternate complete session command through **F2** for development, compatibility testing, personalization, or recovery.

That ability changes which user-session program is launched **after successful PAM authentication**. It does not grant root privileges and does not bypass Linux file/process permissions, but it can bypass FORGE shell UX/policy by deliberately launching a different desktop/session.

Therefore:

- the stable ISO default remains `/usr/local/bin/forge-wayland-session`;
- stable acceptance must not require F2;
- alternate session commands are an authenticated-user capability, not a privileged system-management interface;
- documentation must distinguish host-owned development profiles from the canonical FORGE-owned shell.

See [`session/README.md`](../session/README.md).

## ⚖️ Session/compositor ownership

Exactly one top-level component should own the graphical session/compositor.

The canonical FORGE-owned session starts KWin itself. A host-owned Plasma profile should instead launch FORGE into an already-running Plasma/KWin environment.

The current reference-machine wrapper:

```bash
/usr/lib/plasma-dbus-run session-if-needed /usr/bin/startplasma-wayland /usr/local/bin/forge-wayland-session
```

is treated as a development override because both the outer Plasma session and the inner FORGE launcher can attempt KWin/session ownership. This is primarily a reliability/isolation concern, but inconsistent D-Bus/portal/session ownership can also weaken assumptions made by security-sensitive desktop services.

## 🧱 Privilege boundary

The installer invokes `sudo` only for package installation, service configuration, and root-owned system/runtime files. FORGE itself is not run as root.

Workspace program launching is limited to canonical paths beneath the active FORGE workspace and never evaluates a shell command string. Non-executable files go through `xdg-open`; executable files must already have their executable bit set.

Package installation accepts validated repository package names and uses PolicyKit with `/usr/bin/pacman`, preserving an explicit authentication boundary. Future `forge install ...` UX must keep this privilege separation rather than turning FORGE into a root process or accepting renderer-controlled shell strings.

The renderer cannot supply an update command, repository, branch, or install path. In a FORGE-OS session the update action can only launch the fixed `/usr/local/bin/forge-os-update` helper. That helper runs visibly as the authenticated user, pins trusted origins, rejects dirty/non-`main`/divergent/untrusted checkouts, uses fast-forward-only pulls, and invokes the authoritative installer. Privileged changes remain behind authentication prompts; updates never reboot automatically.

Content-addressed runtime directories under `/opt/forge` are root-owned. Electron's `chrome-sandbox` is root-owned mode `4755`; permanent `--no-sandbox` is prohibited by release policy.

## 🎛️ Runtime-profile UI boundary

OS-facing capabilities should be enabled by explicit runtime profile:

- standalone FORGE should not expose FORGE-OS-only package/power/panel/session controls;
- host-owned Plasma/GNOME profiles should not duplicate or override host desktop security/session surfaces by accident;
- native FORGE-OS shell mode may expose typed, allowlisted OS IPC behind the existing authentication and privilege boundaries.

## 🧾 Logs and secrets

Session logs may record startup stages, runtime identity, executable/workspace selection, and exit status. They must not record passwords, tokens, API keys, or complete environment dumps.

FORGE child-process environment handling should pass only explicit session variables and continue rejecting secret-like requested variables.

## 🗃️ Local state

Machine-generated rollback state and user-specific desktop configuration belong beneath the user's XDG state directory, not in Git. Build output, ISO artifacts, credentials, and local configuration backups must not be committed.

## 🛟 Recovery as an availability control

`getty@tty2.service` is a required recovery path. `Ctrl+Alt+F2` must remain usable when the graphical stack fails. The graphical-disable flow returns the system to console operation without deleting the installed runtime or user data.

## 📦 Release security gates

A stable ISO must satisfy the checks in the [Release Checklist](RELEASE_CHECKLIST.md), including sandbox permissions, absence of embedded secrets, working recovery access, no permanent autologin, authenticated package operations, and a canonical direct session that does not rely on a nested compositor wrapper.

## 🔗 Related documentation

- [Runtime & Session Architecture](../session/README.md)
- [Architecture](../ARCHITECTURE.md)
- [Desktop Session](DESKTOP_SESSION.md)
- [Recovery](RECOVERY.md)
- [Release Checklist](RELEASE_CHECKLIST.md)
