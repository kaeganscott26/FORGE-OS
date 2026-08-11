# Changelog

## Unreleased

- Added an ArchISO builder, checksum generation, and ISO release checklist.
- Added AMD microcode/Vulkan, performance, IRQ, Bluetooth, DBus, and platform verification integration.
- Added a complete setup/configuration/recovery manual and orchestrated enablement command.

- Docked the FORGE-OS system controls above the application chrome so they no
  longer cover browser tabs or the address bar.
- Kept the Browser launcher visible at compact window widths and improved its
  active-state and responsive styling.
- Corrected PTY graphical-session environment inheritance in FORGE source.
- Added minimal XDG portal, notification, polkit, browser, file-manager,
  NetworkManager, PipeWire, UPower, and greetd dependencies.
- Added an acceptance-gated greetd/tuigreet FORGE X session with rollback.
- Added desktop-session and security-model documentation.
- Excluded live `.forge` workspace state from future commits.
- Added FORGE-OS shell mode with safe desktop discovery/launch, clock, System
  Overview, settings destinations, and controlled session actions.
- Added reversible XDG browser/file-manager configuration tooling.

- Added an Arch package manifest for the minimal graphical/build stack.
- Added the benchmarked package mirror order used to recover the slow bootstrap.
- Added `libxcrypt-compat` for electron-builder's bundled FPM DEB backend.
- Added deterministic packaged-runtime staging under `/opt/forge`.
- Added a logged, normal-user xinit/Openbox session boundary.
- Added an acceptance-gated, easily disabled TTY1 login handoff.
- Added bootstrap, build, install, rollback, and verification tools.
- Documented architectural decisions and console recovery.
