# Architecture Decisions

## ADR-001: Immutable packaged runtime

Normal startup must not target the mutable development checkout. Native builds
are recorded by source commit and SHA-256, copied to
`/opt/forge/releases/<commit>`, root-owned, and selected through
`/opt/forge/current`.

## ADR-002: xinit and Openbox session

Xorg and Openbox are the smallest documented Electron substrate. FORGE runs as
the normal user. A failure returns from `startx` to the console, while other
getty-backed virtual terminals remain available. No display manager or root
graphical service is justified.

## ADR-003: Acceptance before login startup

The packaged executable must first pass a manual X test: workspace open,
edit/save, integrated PTY `pwd`, restart, and workspace-state persistence.
Session source and rollback exist before any login startup mutation.

## ADR-004: Replaceable agents

The launcher opens the `FORGE-OS` workspace; it does not start Codex or encode a
provider dependency. CLI agents inherit the normal-user workspace terminal.
Workspace-owned `.forge/metadata.sqlite` remains the persistent state authority.

## ADR-005: Separate repositories and versions

FORGE owns the cross-platform application. FORGE-OS owns Linux integration and
consumes an explicitly pinned FORGE commit/artifact. FORGE-OS begins its own
0.x lifecycle; source is not duplicated or included as a Git submodule.

## ADR-006: Staged greetd login path

greetd with tuigreet is the minimal staged display/login manager. PAM remains
the authentication authority. Installation, enablement, disablement, and
rollback are separate operations; enablement requires a human-created marker.
The `startx` path and recovery VTs remain intact.
