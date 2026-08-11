# Implementation gaps

This file records remaining work that is not represented as a Codex prompt. It should stay short and be deleted when the items are resolved.

## Application fix still carried as an OS overlay

`overlays/0002-accept-numeric-file-read-ranges.patch` is a generic FORGE agent-tools fix, not an operating-system integration change. It should be migrated into the FORGE repository:

- update `packages/agent-tools/src/index.ts` so numeric-string values for `file.read` range fields are normalized to integers before validation;
- retain the rule that `offset` cannot be combined with line ranges;
- add/retain a regression test in `packages/agent-tools/test/runtime.test.ts` for string-valued numeric ranges;
- run FORGE typecheck, lint, tests, and build;
- commit/push FORGE;
- delete the FORGE-OS overlay and rebuild so the overlay identity changes intentionally.

The current overlay remains functional until that migration is completed.

## Human-only validation

Repository editing cannot prove physical graphics/login behavior. After the next install, the user must validate cold boot, PAM login, persistent FORGE session, integrated-terminal environment, application launch, logout/relogin, and tty2 recovery on the reference hardware before an ISO is declared stable.

## Distribution installer

`build-iso.sh` produces a bootable ArchISO-style image with the FORGE runtime/session layout. A polished end-user disk installer, partitioning UX, hardware compatibility matrix, signed release pipeline, and upgrade channel are separate distribution work and should begin only after the live/reference-machine session is stable.
