# 🔐 Security Model

FORGE-OS keeps Linux as the authority for users, PAM authentication, permissions, services, networking, filesystems, and hardware. FORGE owns the desktop experience without replacing the operating system's security model.

## 👤 User and login boundary

- `tuigreet` runs as the unprivileged dedicated `greeter` account.
- PAM authenticates the selected normal user.
- The FORGE graphical session runs as that authenticated user.
- Production autologin is not configured.
- `greetd` uses `source_profile = false`, so shell profiles cannot silently become part of graphical-session startup.

The verified post-authentication command is:

```bash
/usr/local/bin/forge-wayland-session
```

Tuigreet discovers only the FORGE-owned Wayland entry. KWin runs rootlessly as the authenticated user; XWayland is a compatibility service, not a login/session backend.

## 🧱 Privilege boundary

The installer invokes `sudo` only for package installation, service configuration, and root-owned system/runtime files. FORGE itself is not run as root.

Workspace program launching is limited to canonical paths beneath the active FORGE workspace and never evaluates a shell command string. Non-executable files go through `xdg-open`; executable files must already have their executable bit set. Package installation accepts validated repository package names and uses `pkexec /usr/bin/pacman`, preserving an explicit authentication boundary.

The renderer cannot supply an update command, repository, branch, or install path. In a FORGE-OS session the update action can only launch the fixed `/usr/local/bin/forge-os-update` helper. That helper runs visibly as the authenticated user, pins the official GitHub origins, rejects dirty/non-`main`/divergent/untrusted checkouts, uses fast-forward-only pulls, and invokes the single authoritative installer. Privileged package and system-file changes remain behind the installer's authentication prompts; updates never reboot automatically.

Content-addressed runtime directories under `/opt/forge` are root-owned. Electron's `chrome-sandbox` is root-owned mode `4755`; permanent `--no-sandbox` is prohibited by the release policy.

## 🧾 Logs and secrets

Session logs may record startup stages, runtime identity, executable/workspace selection, and exit status. They must not record passwords, tokens, API keys, or complete environment dumps.

FORGE child-process environment handling should pass only explicit session variables and continue rejecting secret-like requested variables.

## 🗃️ Local state

Machine-generated rollback state and user-specific desktop configuration belong beneath the user's XDG state directory, not in Git. Build output, ISO artifacts, credentials, and local configuration backups must not be committed.

## 🛟 Recovery as an availability control

`getty@tty2.service` is a required recovery path. `Ctrl+Alt+F2` must remain usable when the graphical stack fails. The graphical-disable flow returns the system to console operation without deleting the installed runtime or user data.

## 📦 Release security gates

A stable ISO must satisfy the security checks in the [Release Checklist](RELEASE_CHECKLIST.md), including sandbox permissions, absence of embedded secrets, working recovery access, and no permanent autologin.

See also [Architecture](../ARCHITECTURE.md) and [Recovery](RECOVERY.md).
