---
name: vault-ai-chat
description: "AI-powered local vault memory and context-aware chat with any OpenAI-compatible API."
source: vault-ai-chat
---

# AI Vault Memory

## Plugin metadata

- **id:** `vault-ai-chat`
- **source:** vault-native
- **plugin-type:** community
- **status:** enabled
- **class:** FULL
- **has-settings:** true

### Commands

- `vault-ai-chat:open-memory` -- AI Vault Memory: Open memory search
- `vault-ai-chat:rebuild-memory` -- AI Vault Memory: Rebuild vault memory index
- `vault-ai-chat:index-current-file` -- AI Vault Memory: Index current file
- `vault-ai-chat:analyze-current-file` -- AI Vault Memory: تحلیل این یادداشت (Analyze)
- `vault-ai-chat:send-selection-to-chat` -- AI Vault Memory: ارسال بخش انتخاب‌شده به چت هوش مصنوعی
- `vault-ai-chat:ai-inline-prompt` -- AI Vault Memory: اعمال هوش مصنوعی روی متن انتخاب‌شده
- `vault-ai-chat:compare-two-files` -- AI Vault Memory: مقایسه دو فایل
- `vault-ai-chat:forget-current-file` -- AI Vault Memory: Forget current file from memory

# AI Vault Memory

**Description:** AI-powered local vault memory and context-aware chat with any OpenAI-compatible API.
**Status:** Enabled
**Plugin ID:** vault-ai-chat

## Available Commands

Available command IDs (use execute_command for Obsidian-native commands):
- `vault-ai-chat:open-memory` -- AI Vault Memory: Open memory search
- `vault-ai-chat:rebuild-memory` -- AI Vault Memory: Rebuild vault memory index
- `vault-ai-chat:index-current-file` -- AI Vault Memory: Index current file
- `vault-ai-chat:analyze-current-file` -- AI Vault Memory: تحلیل این یادداشت (Analyze)
- `vault-ai-chat:send-selection-to-chat` -- AI Vault Memory: ارسال بخش انتخاب‌شده به چت هوش مصنوعی
- `vault-ai-chat:ai-inline-prompt` -- AI Vault Memory: اعمال هوش مصنوعی روی متن انتخاب‌شده
- `vault-ai-chat:compare-two-files` -- AI Vault Memory: مقایسه دو فایل
- `vault-ai-chat:forget-current-file` -- AI Vault Memory: Forget current file from memory

## Configuration File

Settings path: `.obsidian/plugins/vault-ai-chat/data.json`

To configure this plugin programmatically:
1. Read the config: read_file(".obsidian/plugins/vault-ai-chat/data.json")
2. Understand the settings structure and modify values as needed
3. Write changes: write_file(".obsidian/plugins/vault-ai-chat/data.json", updatedJSON)

Do NOT ask the user to open Settings UI. Modify data.json directly.

## Current Configuration

These are the plugin's current settings (sensitive values redacted):

```
settings:
  language: en
  apiBaseUrl: https://api.openai.com/v1
  chatModel: gpt-5.2-codex
  chunkSize: 1000
  chunkOverlap: 180
  resultCount: 8
  autoIndex: true
  excludedFolders: Templates,Archive
  systemPrompt: You are AI Vault Memory, a precise Obsidian knowledge assistant. Reply in the user's language. Use only provided context when making claims about the vault. Cite vault material as [[path]]. State clearly when context is insufficient.
  enableStreaming: true
```
(1 sensitive field(s) redacted)

For full settings, read: `.obsidian/plugins/vault-ai-chat/data.json`

## Documentation

For detailed plugin documentation (commands, options, dependencies):
read_file(".vault-operator/data/skills/vault-ai-chat.readme.md")

## Usage

When the user asks for functionality related to AI Vault Memory:
1. Read the plugin documentation (.readme.md) to understand capabilities and dependencies
2. Read the config file (.obsidian/plugins/vault-ai-chat/data.json). If it does not exist, that is normal -- create it with the required settings
3. Configure the plugin by writing data.json with the values needed for the task
4. Execute the task using the appropriate tool:
   - For Obsidian-native commands (including file export): use execute_command
   - For CLI-based conversion needing Pandoc/LaTeX: use execute_recipe
   - For data queries: use call_plugin_api
5. If a command opens a UI dialog, tell the user what to click.

CRITICAL RULES:
- Prefer native Obsidian commands over external tools when both can accomplish the task.
- NEVER create fake output files. If the user asks for a PDF/DOCX/image export, use execute_recipe -- do NOT write content to a .pdf file yourself.
- If a dependency is missing (e.g. Pandoc), tell the user what to install.
IMPORTANT: After reading this file, ALWAYS take action or respond. Never end silently.
