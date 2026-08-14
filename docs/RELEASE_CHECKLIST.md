# 📦 FORGE-OS Release Checklist

Use this checklist as the release gate for any ISO described as stable. A successful local build is not enough; the boot/login/session/recovery chain must survive real hardware validation.

## 🧹 Repository readiness

- [ ] `FORGE` is clean, on `main`, and current with `origin/main`.
- [ ] `FORGE-OS` is clean, on `main`, and current with `origin/main`.
- [ ] Active docs describe only the production path.
- [ ] Temporary prompts, machine-generated files, credentials, and local runtime state are absent from Git.
- [ ] `CHANGELOG.md` reflects the release candidate.
- [ ] [`VERSION`](../VERSION) matches the intended release channel.

## 🖥️ Physical-machine candidate

- [ ] Run `./scripts/install-forge-linux.sh` without bypassing verifier failures.
- [ ] Confirm `./tests/verify.sh` reports **zero failures**.
- [ ] Cold reboot the reference machine.
- [ ] Confirm the FORGE-branded login appears without an Arch tty1 login or manual `startx`.
- [ ] Authenticate through PAM.
- [ ] Confirm the post-auth runtime launches automatically as `/usr/local/bin/forge-wayland-session`.
- [ ] Confirm FORGE remains visible and does not return immediately to the greeter.
- [ ] In the FORGE terminal verify `WAYLAND_DISPLAY`, `XDG_CURRENT_DESKTOP=FORGE`, `XDG_SESSION_TYPE=wayland`, `FORGE_OS_SESSION`, `FORGE_SHELL_MODE`, and `FORGE_OS_VERSION`.
- [ ] Launch Chromium and Dolphin from FORGE; confirm a legacy X11 application works through XWayland.
- [ ] Confirm KWin Wayland owns composition, FORGE remains foreground, Plasma supplies wallpaper/effects, and no stock Plasma panel appears.
- [ ] Add a panel with FORGE Panel Manager, customize it, relogin, and confirm the layout persists.
- [ ] Launch FORGE App Launcher and System Settings from the FORGE Applications menu.
- [ ] Open a document and run a disposable executable with Open or Run Workspace File; confirm an outside-workspace path is rejected.
- [ ] Confirm Install Arch Program requests PolicyKit authentication and accepts only repository package names.
- [ ] Validate networking and audio.
- [ ] Test logout → greeter → login again.
- [ ] Confirm `Ctrl+Alt+F2` provides the independent recovery console.
- [ ] Confirm executable, `app.asar`, payload, and installed runtime hashes match the local build record.
- [ ] Select **Check for updates** in FORGE and confirm it opens the visible FORGE-OS updater rather than the standalone Electron updater.
- [ ] Confirm the updater refuses a dirty or divergent checkout, then validate a clean fast-forward-only update and successful installer verification.
- [ ] Confirm the update does not reboot automatically and the updated Wayland session becomes active after a manual reboot.

## 💿 ISO release candidate

- [ ] Build the image with `./scripts/build-iso.sh` only after the physical-machine candidate passes.
- [ ] Confirm `build/iso/SHA256SUMS` exists and matches the final artifact.
- [ ] Boot the ISO on the reference machine.
- [ ] Boot the ISO on at least one additional machine or VM with different graphics/network hardware.
- [ ] Repeat login, session, terminal-environment, application-launch, networking, audio, logout/relogin, and tty2 recovery checks from the ISO.
- [ ] Verify the ISO runtime identity under `/opt/forge/current`.
- [ ] Verify `chrome-sandbox` is root-owned mode `4755`.
- [ ] Record minimum requirements and known hardware limitations.
- [ ] If a disk installer exists, test installation separately from live-ISO boot.

## 🔐 Security and integrity

- [ ] No permanent autologin is enabled.
- [ ] No permanent Electron `--no-sandbox` flag is used.
- [ ] No secrets or credentials are embedded in the image or repository.
- [ ] tty2 recovery remains enabled.
- [ ] The release checksum is retained alongside the published ISO.

## 🏷️ Publication

- [ ] Both source repositories are pushed.
- [ ] The final ISO checksum is frozen.
- [ ] Release notes summarize user-visible changes, known limitations, and recovery instructions.
- [ ] The tag/version reflects the actual validation level (`alpha`, `beta`, `rc`, or stable).
- [ ] Only after every stable gate above passes should the ISO be described as a stable release.

See the [Documentation Hub](README.md), [Recovery Guide](RECOVERY.md), and [Architecture](../ARCHITECTURE.md) for supporting details.
