# Contributing

Keep FORGE application changes in the separate FORGE repository and Linux
integration here. Preserve normal-user execution, TTY recovery, `startx`
fallback, deterministic installation, and human gates around persistent boot
changes. Never add destructive storage automation or blanket sudo rules.

Run `tests/verify.sh` and the corresponding FORGE source checks. Record manual
graphical observations separately from automated verification.
