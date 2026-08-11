# Decisions

## Graphical login is the default

greetd/tuigreet on VT1 provides a branded, PAM-authenticated login. Acceptance marker gating and tty1 shell-profile startup are obsolete.

## Explicit X session boundary

The production launcher calls `xinit` with explicit repository-owned client and Xorg paths. This retains a minimal X11/Openbox substrate without `startx` or user profile dependencies.

## Content-addressed runtime

A source commit alone cannot identify an overlaid application. Release identity therefore incorporates commit, ordered overlay hash, and full payload hash, while the build record also pins lockfile, executable, and `app.asar` hashes.

## Recovery is independent

tty2 remains an enabled getty and is not owned by the graphical session. No graphical component may be enabled unless the verifier can see the complete chain.
