# Security Model

FORGE runs as the logged-in normal user. Linux/PAM authenticates the user;
systemd/logind and polkit remain the authority for session and privileged
operations. The renderer has context isolation and only typed, allowlisted IPC.

Threat boundaries:

- A compromised renderer must not receive Node, arbitrary process, filesystem,
  systemd, or root access.
- Workspace content and agent requests are untrusted input and cannot broaden
  tool or OS privileges.
- Desktop files are untrusted metadata. Their `Exec` values must be parsed into
  executable/argument arrays and never interpolated into a shell.
- Tokens, passwords, Wi-Fi secrets, environment secrets, and keyring values are
  excluded from logs, project metadata, and AI context.
- Storage mutation, package updates, service changes, shutdown, and reboot need
  narrow allowlisted adapters and explicit user confirmation where disruptive.
- FORGE must never become a generic `sudo` frontend or arbitrary root daemon.

The current graphical-login scripts only stage tracked files. Enabling remains
human-gated and rollback preserves runtime and workspace data.
