---
name: realclaudian
description: "Embeds Claude Code, Codex, and other coding agents as AI collaborators in your vault. Your vault becomes their working directory, giving them capabilities for file reads and writes, search, bash commands, and multi-step workflows."
source: realclaudian
---

# Claudian

## Plugin metadata

- **id:** `realclaudian`
- **source:** vault-native
- **plugin-type:** community
- **status:** disabled
- **class:** PARTIAL
- **has-settings:** false
- **needs-setup:** true

# Claudian

**Description:** Embeds Claude Code, Codex, and other coding agents as AI collaborators in your vault. Your vault becomes their working directory, giving them capabilities for file reads and writes, search, bash commands, and multi-step workflows.
**Status:** Disabled
**Plugin ID:** realclaudian

## Setup Required

Plugin is disabled. Use enable_plugin to activate it first.
Guide the user to configure this plugin via Obsidian Settings if needed.

## Configuration File

Settings path: `.obsidian/plugins/realclaudian/data.json`

To configure this plugin programmatically:
1. Read the config: read_file(".obsidian/plugins/realclaudian/data.json")
2. Understand the settings structure and modify values as needed
3. Write changes: write_file(".obsidian/plugins/realclaudian/data.json", updatedJSON)

Do NOT ask the user to open Settings UI. Modify data.json directly.

## Documentation

For detailed plugin documentation (commands, options, dependencies):
read_file(".vault-operator/data/skills/realclaudian.readme.md")

## Usage

This plugin is currently disabled. Use enable_plugin("realclaudian") to activate it first.
After enabling, the plugin's commands will become available for execute_command.
