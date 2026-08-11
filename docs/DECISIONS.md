# Decisions

## Graphical login is the default

greetd/tuigreet on VT1 provides the branded PAM-authenticated login. Acceptance gating and tty1 shell-profile startup are obsolete.

## Graphical startup does not source shell profiles

`greetd` sets `source_profile = false`. `/etc/profile`, `~/.profile`, `.bash_profile`, `.bashrc`, and similar shell startup files are not part of the production graphical-session contract.

## FORGE owns the only X startup boundary

`tuigreet` is restricted to FORGE-owned session directories and uses `--no-xsession-wrapper`; it must not prepend its default `startx /usr/bin/env` wrapper. The authenticated command is `/usr/local/bin/forge-xsession`, which calls `xinit` with explicit client and Xorg paths.

## Content-addressed runtime

A FORGE source commit alone cannot identify an overlaid application. Release identity therefore incorporates the source commit, ordered path-independent overlay identity, and full payload identity, while the build record also pins lockfile, executable, and `app.asar` hashes.

## Exported builds receive explicit source identity

FORGE-OS packages a `git archive` of FORGE rather than the live checkout. `FORGE_BUILD_COMMIT` is passed explicitly during packaging so FORGE cannot accidentally discover the enclosing FORGE-OS Git repository and embed the wrong commit.

## User state does not live in Git

Desktop/MIME rollback data belongs under the user's XDG state directory, not beneath a tracked repository `build/` directory.

## Recovery is independent

tty2 remains an enabled getty and is not owned by the graphical session. The graphical disable script switches back to `multi-user.target` and restores tty1/tty2 console login. No graphical component may be considered production-ready unless the verifier sees the complete chain.
