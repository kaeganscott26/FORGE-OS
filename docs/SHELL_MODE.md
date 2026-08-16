# FORGE-OS shell mode

Shell mode is enabled only when the session exports `FORGE_OS_SESSION=1`, `FORGE_SHELL_MODE=1`, `XDG_CURRENT_DESKTOP=FORGE`, and `XDG_SESSION_TYPE=wayland`. Standalone macOS, Windows, and ordinary host-desktop packages retain the shared workspace/UI behavior but do not expose Linux system mutations.

The FORGE-OS top bar owns Applications, System, Workspace Intelligence, clock, and Session. Workspace Intelligence is a separate native popover; the right rail is chat-only. Opening a workspace immediately indexes bounded files/memory, and the filesystem watcher debounces automatic reindexing and context events.

Native system sections are Network, Audio, Display, Power, Applications, Updates, Security, Recovery, and Advanced. Status comes from fixed main-process calls to NetworkManager, PipeWire, KScreen, power-profiles-daemon, immutable runtime state, and security/recovery diagnostics. Fixed actions exist for networking, volume/mute, power profiles, repository application installation, and the verified updater; the renderer never provides a shell command.

Application discovery parses XDG desktop entries without a shell, removes field codes, filters hidden entries, and refreshes every 15 seconds. Package frontends refresh desktop caches after successful transactions.

FORGE Explorer is the default file manager. It keeps paths workspace-contained, supports create/copy/paste/rename/delete, inspects text, metadata, binary, executable, Arch package, and Debian package types, and requires confirmation plus an explicit user/administrator mode before launch. Package/executable actions use fixed FORGE helpers; Dolphin is not the primary workflow.

The Agent Actions surface advertises the full release capability profile, but it does not grant a global bypass. Exact scope, working directory, target, network disclosure, expected effect, result, and rollback evidence remain visible and audited. Session permissions are short-lived exact scopes; destructive and remote writes require fresh approval.
