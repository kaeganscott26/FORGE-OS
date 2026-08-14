# 🧪 Implementation Gaps

This file tracks unresolved engineering work that still affects distribution quality. Resolved debugging notes should be removed rather than accumulating here.

## 🧠 Upstream FORGE `file.read` continuation normalization

FORGE agents can legitimately continue a bounded `file.read` using a returned `offset`. Model-generated continuation calls may repeat earlier `startLine` / `endLine` values while also supplying that offset. Upstream FORGE currently rejects that mixed request shape with `offset cannot be combined with line ranges`.

FORGE-OS temporarily carries [`overlays/0002-tolerate-file-read-continuation-arguments.patch`](../overlays/0002-tolerate-file-read-continuation-arguments.patch) so packaged FORGE runtimes remain usable while the upstream contract is corrected.

The overlay:

- normalizes numeric-string range values to integers;
- treats a supplied continuation `offset` as authoritative;
- discards repeated line-range values when `offset` is present;
- adds regression coverage for the mixed continuation shape.

This behavior belongs upstream in FORGE. Once the upstream fix lands and passes FORGE validation, remove the compatibility overlay and rebuild FORGE-OS so the overlay/runtime identity changes intentionally.

## 💿 Distribution installer and release pipeline

The current repository can build an ArchISO-style image using the same runtime/session layout as the physical installation. A polished end-user distribution still benefits from additional release engineering:

- guided disk installation and partitioning UX;
- hardware compatibility documentation;
- signed release artifacts and/or a signed update channel;
- automated release provenance;
- a signed binary/OS update channel that does not require local source checkouts;
- broader multi-hardware validation.

These are distribution-quality improvements, not blockers for continued runtime/session testing.

The current development/reference updater is implemented and intentionally source-based: it updates clean trusted checkouts with fast-forward-only Git operations and runs the verified installer. A future signed artifact channel should preserve the same provenance, authentication, recovery, and no-downgrade guarantees.

## 🧪 Stable ISO validation

The earlier X11 runtime was physically demonstrated. The new KWin Wayland path requires full cold-boot, native Electron, XWayland compatibility, KDE portal/PipeWire, wallpaper/panel persistence, compositor-failure, logout/relogin, and ISO validation using the [Release Checklist](RELEASE_CHECKLIST.md).

## 📚 Maintenance rule

Keep this file short. When a gap is resolved, remove it and record the completed change in the [Changelog](../CHANGELOG.md). Historical debugging detail belongs in Git history rather than current user documentation.
