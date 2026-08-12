# Implementation gaps

This file records remaining work that is not represented as a Codex prompt. It should stay short and be deleted when the items are resolved.

## FORGE `file.read` continuation normalization

FORGE agents can legitimately continue a bounded `file.read` using the returned `offset`. In practice, model-generated continuation calls may repeat the earlier `startLine` / `endLine` fields while also supplying that offset. Current upstream FORGE rejects the entire request with `offset cannot be combined with line ranges`, which can abort broad workspace scans.

FORGE-OS currently carries `overlays/0002-tolerate-file-read-continuation-arguments.patch` as a temporary compatibility fix so the packaged FORGE runtime remains usable during the OS experiment. The overlay:

- normalizes numeric-string range values to integers;
- treats a supplied continuation `offset` as authoritative;
- discards repeated `startLine` / `endLine` values when `offset` is present instead of failing validation;
- adds regression coverage for the mixed continuation argument shape.

This behavior belongs upstream in FORGE, not permanently in FORGE-OS. The remaining upstream work is to implement the same contract in `packages/agent-tools/src/index.ts`, retain the regression test under `packages/agent-tools/test`, run FORGE typecheck/lint/tests/build, commit/push the FORGE change, then remove this overlay in a later FORGE-OS commit and rebuild so the overlay identity changes intentionally.

The overlay is compatibility scaffolding only; it is not part of the graphical boot architecture.

## Human-only validation

Repository editing cannot prove physical graphics/login behavior. The repository-owned `session/forge-xsession` has now been physically demonstrated to launch Xorg through Arch's public X launcher and reach the FORGE-OS UI on the reference AMD laptop. The remaining validation is that the installed `/usr/local/bin/forge-xsession` is refreshed by the installer and the same path survives a cold boot through greetd/PAM without manual intervention.

Before an ISO is declared stable, validate cold boot, PAM login, persistent FORGE session, integrated-terminal environment, application launch, logout/relogin, and tty2 recovery on the reference hardware.

## Distribution installer

`build-iso.sh` produces a bootable ArchISO-style image with the FORGE runtime/session layout. A polished end-user disk installer, partitioning UX, hardware compatibility matrix, signed release pipeline, and upgrade channel are separate distribution work and should begin only after the live/reference-machine session is stable.
