# FORGE-OS Flatpak application discovery

## Root cause

**OBSERVED:** The canonical Wayland session scripts assigned `XDG_DATA_DIRS` to a Nix-only prefix plus the inherited/default value. A clean greetd launch can therefore omit `/var/lib/flatpak/exports/share` and the user's Flatpak export directory. Plasma and any XDG desktop-entry consumer inherit that session environment.

**OBSERVED:** The current shell has `XDG_CURRENT_DESKTOP=FORGE`, `DESKTOP_SESSION=forge`, and an `XDG_DATA_DIRS` containing Flatpak paths. `flatpak list --app` reports 17 installed applications and `/var/lib/flatpak/exports/share/applications` contains their exported `.desktop` symlinks. The requested `find -type f` check reports zero because Flatpak exports are symlinks, not regular files.

**INFERRED:** When Flatpak exports exist, the missing/overwritten XDG path affects Plasma and FORGE independently. FORGE already scans XDG application directories, so it does not depend on Plasma's cache.

## Running environment

**OBSERVED before source change (current shell):**

```text
XDG_DATA_DIRS=$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share:/usr/local/share:/usr/share:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share
XDG_DATA_HOME=
XDG_CONFIG_HOME=
XDG_CURRENT_DESKTOP=FORGE
XDG_SESSION_DESKTOP=
DESKTOP_SESSION=forge
```

The clean session's effective value before this change was not durable: `session/forge-wayland-session` and `session/forge-recovery-session` rebuilt it from Nix paths and `${XDG_DATA_DIRS:-/usr/local/share:/usr/share}`.

**CHANGED:** Both session entry points now prepend, deduplicate, and preserve:

```text
$XDG_DATA_HOME/flatpak/exports/share (or $HOME/.local/share/flatpak/exports/share)
/var/lib/flatpak/exports/share
/usr/local/share
/usr/share
${existing XDG_DATA_DIRS}
```

Nix profile directories remain preserved after the standard entries.

## Plasma

**CHANGED:** The session now exports the Flatpak-aware path before KWin, D-Bus activation, and Plasma start. Existing Plasma processes cannot be retrofitted with a changed environment.

**UNVERIFIED:** This host has no exported Flatpak desktop entries, so `kbuildsycoca6` and launcher visibility could not be verified against a real installed app. After installing/repairing an app export, run `kbuildsycoca6` once, or log out and back in. A full reboot is not required unless the session itself cannot be restarted.

## FORGE

**CHANGED:** `@forge/os-integration` enumerates `$XDG_DATA_HOME/applications` followed by every `$XDG_DATA_DIRS/<entry>/applications`, with `/usr/local/share:/usr/share` fallback. It parses Flatpak entries as ordinary `Type=Application` entries, removes freedesktop field codes and Flatpak `@@`/`@@u` forwarding markers from structured arguments, uses `shell:false`, rejects malformed entries safely, honors `Hidden`, `NoDisplay`, `OnlyShowIn`, and `NotShowIn`, and retains the `TryExec`, `DBusActivatable`, and startup metadata.

**CHANGED:** Duplicate desktop IDs use deterministic XDG precedence: the first readable directory wins. Thus user data precedes each `XDG_DATA_DIRS` entry, and earlier entries override later copies.

**VERIFIED:** Opening the FORGE launcher already triggers an application scan; the existing implementation does not continuously poll. Refreshing the launcher is the safe refresh action after a Flatpak transaction.

## Persistence and files changed

**CHANGED:** The shared `session/forge-xdg-environment` helper is installed by the normal installer, clean-install path, and ISO build. No generated build directory was modified.

Files changed:

- `session/forge-xdg-environment`
- `session/forge-wayland-session`
- `session/forge-recovery-session`
- `scripts/install-forge-linux.sh`
- `scripts/forge-clean-install`
- `scripts/build-iso.sh`
- sibling FORGE repository `packages/os-integration/src/index.ts`
- sibling FORGE repository `packages/os-integration/test/os-integration.test.ts`

## Tests and runtime verification

**VERIFIED:** FORGE integration tests: 7 passed, 0 failed. FORGE TypeScript typecheck passed. Bash syntax checks passed. The helper produced a deduplicated path with Flatpak exports first while preserving `/foo/share` in a fixture.

**VERIFIED:** Current system Flatpak IDs including OpenCode, GitKraken, Postman, Minder, Android Studio, SmartSynchronize, Bottles, Visu, Stoplight Studio, FireDragon, Elisa, and DB Browser for SQLite have matching system export symlinks.

**UNVERIFIED:** Plasma launcher visibility after a new session remains pending; the current graphical processes predate this source change.

## Remaining limitations

Icon names are preserved from desktop entries for normal icon-theme resolution, but the FORGE UI currently renders text-only launcher buttons. The session must be logged out/in (or restarted) for Plasma and already-running FORGE processes to receive the corrected environment.
