# FORGE-OS shell mode

Shell mode is enabled only when the session exports `FORGE_OS_SESSION=1`, `FORGE_SHELL_MODE=1`, `XDG_CURRENT_DESKTOP=FORGE`, and `XDG_SESSION_TYPE=wayland`. Standalone macOS, Windows, and ordinary host-desktop packages retain the shared workspace/UI behavior but do not expose Linux system mutations.

The FORGE-OS top bar owns Applications, System quick actions, the clock, and Session. Workspace Intelligence and chat remain in the shared FORGE right rail. Memory reindexing is currently explicit through **Reindex**; the desktop runtime does not start automatic filesystem-watch reindexing.

Native system sections are Network, Audio, Display, Power, Applications, Updates, Security, Recovery, and Advanced. Status comes from fixed main-process calls to NetworkManager, PipeWire, KScreen, power-profiles-daemon, immutable runtime state, and security/recovery diagnostics. Fixed actions exist for networking, volume/mute, power profiles, repository application installation, and the verified updater; the renderer never provides a shell command.

Application discovery parses XDG desktop entries without a shell, removes field codes, filters hidden entries, and refreshes every 15 seconds. Package frontends refresh desktop caches after successful transactions.

FORGE Explorer is the default file manager. It keeps paths workspace-contained and supports routed create/copy/paste/rename/delete plus UTF-8 text editing. Planned metadata, binary, executable, Arch-package, Debian-package, and user/administrator launch modes are not implemented in the current shared renderer. Dolphin is not the primary workflow.

The Agent Actions surface advertises the full release capability profile, but it does not grant a global bypass. Exact scope, working directory, target, network disclosure, expected effect, result, and rollback evidence remain visible and audited. Session permissions are short-lived exact scopes; destructive and remote writes require fresh approval.
