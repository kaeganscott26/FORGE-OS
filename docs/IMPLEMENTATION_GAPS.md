# Remaining release gaps

The requested source implementation is present. These are acceptance or distribution gaps, not hidden placeholders:

1. Run an unskipped bootstrap/install on a disposable clean Arch target and verify every manifest package, unit, desktop default, Fish shell, Ollama skills copy, and installed hash.
2. Boot the generated ISO in a VM and on reference hardware. Validate one KWin owner, GPU rendering, XWayland, NetworkManager, PipeWire, portals, external-window focus, suspend/resume, logout/relogin, on-demand tty2 recovery, and rollback.
3. Add a guided disk/partition installer before describing the ISO as an end-user installer rather than a bootable live/recovery image.
4. Produce Windows and macOS packages on native runners. Verify version, commit, deterministic build date, and shared runtime hash across all three platforms.
5. Establish signing keys/certificates and a signed stable binary/OS update feed. The current FORGE-OS updater intentionally remains a trusted-clean-source workflow.
6. Exercise negative updater/rollback cases: dirty tree, divergent origin, wrong manifest/hash, interrupted activation, unavailable last-known-good, and repeat update after rollback.

No source-only check can replace these physical, native-runner, signing, and remote publication gates.
