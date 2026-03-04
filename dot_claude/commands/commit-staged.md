---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git commit:*)
description: Commit only staged changes (does not stage anything)
---

## Context

- Current git status: !`git status`
- Staged changes: !`git diff --cached`
- Recent commits: !`git log --oneline -10`

## Your task

Create a single git commit using ONLY the already-staged changes. Do NOT stage any additional files — commit exactly what is in the index right now.

If there are no staged changes, inform the user and stop.

Otherwise:
1. Analyze the staged diff to understand the intent of the changes
2. Review recent commit messages to match the repository's style
3. Create a commit with an appropriate message following conventional commits format
4. Do not use any other tools or do anything else. Do not send any other text or messages besides the commit tool call.