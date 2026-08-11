# Release checklist

1. Confirm both worktrees and intended commits.
2. Run FORGE typecheck, lint, tests, and build.
3. Run `scripts/build-forge.sh`; inspect `build/latest.env` identities.
4. Run `scripts/install-forge-os.sh` and `tests/verify.sh`.
5. Confirm build and installed `app.asar` are byte-identical and the payload hash matches.
6. From the physical UI, test PAM login, terminal environment, Chromium, Thunar, Codex, logout, login again, and `Ctrl+Alt+F2` recovery.
7. Run `scripts/build-iso.sh`; verify its content-addressed runtime and session layout.
8. Commit and push the two repositories separately. Never commit `build/latest.env` or enable autologin.
