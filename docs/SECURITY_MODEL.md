# Security model

Linux remains the authority for users, PAM authentication, permissions, services, networking, and hardware. tuigreet runs as the unprivileged dedicated `greeter` account; the authenticated session and FORGE run as the selected normal user. Autologin is not configured.

The installer uses sudo only for packages, service configuration, and root-owned files. Immutable runtime directories are root-owned. The Chromium helper is root-owned mode `4755`, and FORGE is never launched with permanent `--no-sandbox`.

Session logs record stages, runtime identity, and exit status but never credentials or environment contents that may contain secrets. FORGE child-process filtering passes only explicit safe session variables and continues to block secret-like requested variables.

Recovery access on tty2 is a required security and availability control.
