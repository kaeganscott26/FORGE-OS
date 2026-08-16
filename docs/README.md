# Documentation hub

Active guides describe the current FORGE-owned Wayland architecture. Retired experiments live in Git history and the changelog, not current instructions.

| Topic | Guide |
| --- | --- |
| Boot, runtime ownership, F2/F4, standalone/host profiles | [Runtime/session contract](../session/README.md) |
| OS/application responsibility and runtime identity | [Architecture](../ARCHITECTURE.md) |
| Installation, package commands, daily use | [User manual](USER_MANUAL.md) |
| Shell-only UI and native settings | [Shell mode](SHELL_MODE.md) |
| Graphical tty2 diagnostics and rollback | [Recovery](RECOVERY.md) |
| Privilege, updater, package, and agent boundaries | [Security model](SECURITY_MODEL.md) |
| Durable design choices | [Decisions](DECISIONS.md) |
| Remaining release blockers | [Implementation gaps](IMPLEMENTATION_GAPS.md) |
| Stable artifact and hardware gates | [Release checklist](RELEASE_CHECKLIST.md) |

Repository structure:

- `config/`: greetd, recovery, KWin/KDE, portals, Fish, mirrors, and system units.
- `manifests/`: authoritative host package list.
- `scripts/`: bootstrap, package frontends, runtime build/install/update/rollback, desktop setup, and ISO construction.
- `session/`: production and recovery session entry points plus desktop entries.
- `tests/`: non-mutating source gates and installed-machine verification.
- `overlays/`: temporary FORGE compatibility patches included in runtime identity.

Generic shared application features belong in the sibling FORGE repository. Boot, Arch integration, compositor/login ownership, native recovery, host dependencies, and ISO release work belong here.
