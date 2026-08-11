# Release checklist

## Physical-machine candidate

1. Confirm both repositories are clean on `main` and current with `origin/main`.
2. Run `./scripts/install-forge-linux.sh`; do not bypass verifier failures.
3. Confirm `tests/verify.sh` reports zero failures.
4. Cold reboot the physical machine.
5. Confirm the FORGE-branded login appears without an Arch tty1 login or manual `startx`.
6. Authenticate through PAM and confirm the session remains in FORGE instead of returning to the greeter.
7. In the FORGE terminal verify `DISPLAY`, `XDG_CURRENT_DESKTOP`, `XDG_SESSION_TYPE`, `FORGE_OS_SESSION`, `FORGE_SHELL_MODE`, and `FORGE_OS_VERSION`.
8. Launch Chromium and Thunar from FORGE.
9. Test logout -> greeter -> login again.
10. Confirm `Ctrl+Alt+F2` still provides an independent recovery console.
11. Confirm build and installed executable/`app.asar`/payload hashes match the local build record.

## ISO release candidate

1. Run `scripts/build-iso.sh` only after the physical-machine candidate passes.
2. Verify `build/iso/SHA256SUMS` and retain the checksum with the artifact.
3. Boot the ISO on the reference machine and at least one separate machine or VM with different graphics/network hardware.
4. Repeat login, session, terminal-environment, application-launch, logout/relogin, networking, audio, and tty2 recovery checks from the ISO.
5. Verify the ISO's `/opt/forge/current` runtime identity and `chrome-sandbox` permissions.
6. Test installation/update behavior separately from live-ISO boot if an installer is added; do not claim installability from a live image alone.
7. Record known hardware limitations and minimum requirements.
8. Tag a FORGE-OS prerelease only after the tested ISO checksum is final and both source repositories are pushed.

Never commit `build/latest.env`, local desktop backups, credentials, or machine-specific runtime state. Never enable autologin or permanent `--no-sandbox`.
