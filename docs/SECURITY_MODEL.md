# Security model

Linux remains the authority for users, PAM authentication, permissions, services, networking, filesystems, and hardware. Tuigreet runs as the unprivileged dedicated `greeter` account; the authenticated graphical session and FORGE run as the selected normal user. Autologin is not configured.

Graphical startup sets greetd `source_profile = false`, preventing shell profile files from becoming an implicit privileged/session configuration surface. Tuigreet is restricted to FORGE-owned session directories and its X-session wrapper is disabled, so the production X boundary is the reviewed repository-owned `forge-xsession` launcher rather than an implicit `startx` wrapper.

The installer uses sudo only for packages, service configuration, and root-owned system/runtime files. Content-addressed runtime directories are root-owned. Chromium's `chrome-sandbox` is root-owned mode `4755`, and FORGE is never launched with permanent `--no-sandbox`.

Session logs record stages, runtime identity, executable/workspace selection, and exit status but never passwords, tokens, API keys, or full environment dumps. FORGE child-process filtering passes only explicit safe session variables and continues to reject secret-like requested variables.

Machine-generated desktop rollback state is stored beneath the user's XDG state directory instead of the Git checkout. Repository builds and ISO artifacts must not contain credentials or local user configuration backups.

Recovery access on tty2 is a required security and availability control. The graphical disable path restores console operation without deleting the installed runtime or user data.
