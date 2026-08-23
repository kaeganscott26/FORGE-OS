---
name: calendar
description: "Calendar view of your daily notes"
source: calendar
---

# Calendar

## Plugin metadata

- **id:** `calendar`
- **source:** vault-native
- **plugin-type:** community
- **status:** disabled
- **class:** PARTIAL
- **has-settings:** false
- **needs-setup:** true

# Calendar

**Description:** Calendar view of your daily notes
**Status:** Disabled
**Plugin ID:** calendar

## Setup Required

Plugin is disabled. Use enable_plugin to activate it first.
Guide the user to configure this plugin via Obsidian Settings if needed.

## Configuration File

Settings path: `.obsidian/plugins/calendar/data.json`

To configure this plugin programmatically:
1. Read the config: read_file(".obsidian/plugins/calendar/data.json")
2. Understand the settings structure and modify values as needed
3. Write changes: write_file(".obsidian/plugins/calendar/data.json", updatedJSON)

Do NOT ask the user to open Settings UI. Modify data.json directly.

## Documentation

For detailed plugin documentation (commands, options, dependencies):
read_file(".vault-operator/data/skills/calendar.readme.md")

## Usage

This plugin is currently disabled. Use enable_plugin("calendar") to activate it first.
After enabling, the plugin's commands will become available for execute_command.
