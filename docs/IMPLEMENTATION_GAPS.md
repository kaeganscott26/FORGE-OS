# Implementation gaps

This file records remaining work that is not represented as a Codex prompt. It should stay short and be deleted when the items are resolved.

## FORGE numeric `file.read` normalization

The former FORGE-OS overlay `overlays/0002-accept-numeric-file-read-ranges.patch` was removed because it no longer applied cleanly to current FORGE and was blocking packaging. The behavior it attempted to add is a generic FORGE agent-tools improvement, not an operating-system integration requirement, and it is not required for FORGE-OS graphical boot.

The remaining upstream FORGE work is:

- update `packages/agent-tools/src/index.ts` so numeric-string values for `file.read` range fields are normalized to integers before validation;
- retain the rule that `offset` cannot be combined with line ranges;
- add a regression test in `packages/agent-tools/test/runtime.test.ts` for string-valued numeric ranges;
- run FORGE typecheck, lint, tests, and build;
- commit/push the FORGE change.

Do not reintroduce this as a FORGE-OS overlay. FORGE-OS packaging must remain independent of this non-OS behavior fix.

## Human-only validation

Repository editing cannot prove physical graphics/login behavior. The repository-owned `session/forge-xsession` has now been physically demonstrated to launch Xorg through Arch's public X launcher and reach the FORGE-OS UI on the reference AMD laptop. The remaining validation is that the installed `/usr/local/bin/forge-xsession` is refreshed by the installer and the same path survives a cold boot through greetd/PAM without manual intervention.

Before an ISO is declared stable, validate cold boot, PAM login, persistent FORGE session, integrated-terminal environment, application launch, logout/relogin, and tty2 recovery on the reference hardware.

## Distribution installer

`build-iso.sh` produces a bootable ArchISO-style image with the FORGE runtime/session layout. A polished end-user disk installer, partitioning UX, hardware compatibility matrix, signed release pipeline, and upgrade channel are separate distribution work and should begin only after the live/reference-machine session is stable.
