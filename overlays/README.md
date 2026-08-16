# FORGE compatibility overlays

No overlay is currently required. Former navigation, ranged-read, and FORGE-OS updater patches were implemented in the FORGE source repository so standalone and OS-integrated builds share behavior.

If a temporary patch is unavoidable, place a zero-fuzz `*.patch` here, document its upstream issue, and include its ordered path/content identity in every runtime build. Remove it as soon as the upstream source contains the fix.
