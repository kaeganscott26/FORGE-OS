---
name: obsidian-vault-statistics-plugin
description: "Status bar item with vault statistics such as number of notes, files, attachments, and links."
source: obsidian-vault-statistics-plugin
---

# Vault Statistics

## Plugin metadata

- **id:** `obsidian-vault-statistics-plugin`
- **source:** vault-native
- **plugin-type:** community
- **status:** disabled
- **class:** PARTIAL
- **has-settings:** false
- **needs-setup:** true

# Vault Statistics

**Description:** Status bar item with vault statistics such as number of notes, files, attachments, and links.
**Status:** Disabled
**Plugin ID:** obsidian-vault-statistics-plugin

## Setup Required

Plugin is disabled. Use enable_plugin to activate it first.
Guide the user to configure this plugin via Obsidian Settings if needed.

## Configuration File

Settings path: `.obsidian/plugins/obsidian-vault-statistics-plugin/data.json`

To configure this plugin programmatically:
1. Read the config: read_file(".obsidian/plugins/obsidian-vault-statistics-plugin/data.json")
2. Understand the settings structure and modify values as needed
3. Write changes: write_file(".obsidian/plugins/obsidian-vault-statistics-plugin/data.json", updatedJSON)

Do NOT ask the user to open Settings UI. Modify data.json directly.

## Documentation

For detailed plugin documentation (commands, options, dependencies):
read_file(".vault-operator/data/skills/obsidian-vault-statistics-plugin.readme.md")

## Usage

This plugin is currently disabled. Use enable_plugin("obsidian-vault-statistics-plugin") to activate it first.
After enabling, the plugin's commands will become available for execute_command.
