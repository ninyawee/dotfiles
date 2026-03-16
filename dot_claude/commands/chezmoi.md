---
allowed-tools: Bash(chezmoi add:*), Bash(chezmoi diff:*), Bash(chezmoi status:*)
description: Add changed dotfiles to chezmoi
---

## Context

- Chezmoi status: !`chezmoi status`
- Files modified this session: !`git -C ~/.local/share/chezmoi diff --name-only HEAD 2>/dev/null; echo "---"; chezmoi status`

## Your task

Add all files you modified during this session to chezmoi using `chezmoi add <file>...`. Only add files you actually changed — do not blindly add everything. If unsure, ask the user.

Do not use any other tools or do anything else.
