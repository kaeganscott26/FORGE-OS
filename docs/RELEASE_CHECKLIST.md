# 🚢 ISO Release Checklist

- [ ] `tests/verify.sh` and `scripts/check-platform.sh` pass after reboot.
- [ ] Every item in `docs/ACCEPTANCE.md` is human-recorded.
- [ ] ISO boots in UEFI mode and on the ASUS FX705DY.
- [ ] Login, FORGE UI, DBus, networking, audio, GPU, storage, suspend, and recovery TTY work.
- [ ] `sha256sum -c build/iso/SHA256SUMS` passes.
- [ ] Tag matches `VERSION`; release notes identify experimental status and rollback.
- [ ] ISO and `SHA256SUMS` are uploaded only to the FORGE-OS release.
