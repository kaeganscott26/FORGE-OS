# Documentation hub

Active guides describe the current FORGE-owned Wayland architecture. Retired experiments live in Git history and the changelog, not current instructions.

**Start with [Current implementation](CURRENT_IMPLEMENTATION.md).** It is reconciled against `main` and is the canonical current-state summary when older build notes, reviews, or historical implementation records disagree.

| Topic | Guide |
| --- | --- |
| Current behavior across session, Flatpak discovery, runtime ownership, updates, recovery, and local AI hosting | [Current implementation](CURRENT_IMPLEMENTATION.md) |
| Boot, runtime ownership, F2/F4, standalone/host profiles | [Runtime/session contract](../session/README.md) |
| OS/application responsibility and runtime identity | [Architecture](../ARCHITECTURE.md) |
| Installation, package commands, daily use | [User manual](USER_MANUAL.md) |
| Flatpak/XDG application discovery and structured launching | [Flatpak application discovery](FORGE_OS_FLATPAK_APPLICATION_DISCOVERY.md) |
| Shell-only UI and native settings | [Shell mode](SHELL_MODE.md) |
| Graphical tty2 diagnostics and rollback | [Recovery](RECOVERY.md) |
| Privilege, updater, package, and agent boundaries | [Security model](SECURITY_MODEL.md) |
| Durable design choices | [Decisions](DECISIONS.md) |
| Remaining release blockers | [Implementation gaps](IMPLEMENTATION_GAPS.md) |
| Stable artifact and hardware gates | [Release checklist](RELEASE_CHECKLIST.md) |

Repository structure:

- `config/`: greetd, recovery, KWin/KDE, portals, Fish, mirrors, XDG/Flatpak environment, and system units.
- `manifests/`: authoritative host package and service policy.
- `scripts/`: bootstrap, package frontends, runtime build/install/update/rollback, desktop setup, environment wiring, and ISO construction.
- `session/`: production and recovery session entry points plus desktop entries.
- `tests/`: non-mutating source gates, application-discovery integration checks, and installed-machine verification.
- `overlays/`: temporary FORGE compatibility patches included in runtime identity.

Generic shared application features belong in the sibling FORGE repository. Boot, Arch integration, compositor/login ownership, native recovery, host dependencies, XDG/Flatpak exposure, and ISO release work belong here.

When an implementation changes, update the narrowest applicable guide and reconcile [Current implementation](CURRENT_IMPLEMENTATION.md). Historical evidence should remain historical rather than being silently rewritten.
