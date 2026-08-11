# Codex Prompt — Repair FORGE-OS Verifier Before Reboot

Use this prompt after the graphical boot/runtime consolidation pass, before declaring the machine ready to reboot.

```text
Before declaring the system READY TO REBOOT, fix tests/verify.sh.

The verifier currently depends on the `rg` command, but ripgrep is not declared in manifests/arch-packages.txt and is not installed on this physical machine.

This caused:

rg: command not found

and invalidated several checks. It is especially dangerous because checks written as:

! rg -q ...

produce false PASS results when rg itself is missing.

Do not leave the verifier in a state where a missing verification dependency can create either false PASS or false FAIL output.

Preferred fix:
- Remove the unnecessary ripgrep dependency from tests/verify.sh.
- Use standard Arch/base tools such as grep/grep -E/grep -R for these small source checks.
- If you choose to retain ripgrep instead, add ripgrep to the declared Arch manifest AND explicitly verify `command -v rg` before using it. However, prefer not adding an OS package solely for the verifier.

Repair and rerun these checks:

1. production session contains no startx or .xinitrc dependency
2. forge-xsession dynamically allocates an unused X display
3. selected X display is explicitly passed to Xorg
4. acceptance gating is completely absent
5. FORGE SAFE_PARENT_ENV contains:
   FORGE_OS_SESSION
   FORGE_SHELL_MODE
   FORGE_OS_VERSION

Do not use command negation around a command whose existence has not first been established.

Also verify the actual installed files rather than only repository source where appropriate.

After fixing the verifier:
- run ./tests/verify.sh again
- require 0 failures
- report every warning
- do not reboot automatically
- do not declare READY TO REBOOT until the verifier itself has no missing-command errors.

Also address the electron-builder `desktopName is not set` warning if there is a correct Linux packaging setting for FORGE, provided it does not disrupt the current build/session architecture.

Finally confirm:
git -C ~/FORGE status
git -C ~/FORGE log -1 --oneline
git -C ~/FORGE-OS status
git -C ~/FORGE-OS log -1 --oneline

Make sure the FORGE environment-propagation fix is committed and pushed, because the remote FORGE repository must not remain behind the runtime being installed by FORGE-OS.
```
