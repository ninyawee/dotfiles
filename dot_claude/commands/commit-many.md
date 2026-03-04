---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(git reset:*)
description: Break changes into multiple logical commits by intent
---

## Context

- Current git status: !`git status`
- Full diff (staged and unstaged): !`git diff HEAD`
- Untracked files: !`git status --porcelain`
- Recent commits: !`git log --oneline -10`

## Your task

Analyze ALL pending changes (staged, unstaged, and untracked) and break them into multiple logical commits grouped by intent/purpose.

### Step 1: Analyze and plan

List the change tree — every modified, added, and deleted file — grouped into logical commit units. Present the plan as:

```
Commit 1: <type>: <description>
  - file_a.ts (modified)
  - file_b.ts (added)

Commit 2: <type>: <description>
  - file_c.py (modified)
  - file_d.py (deleted)

...
```

Show this plan to the user and WAIT for confirmation before proceeding.

### Step 2: Execute commits

For each planned commit, in order:
1. `git reset HEAD` to unstage everything (only before the first commit)
2. `git add` only the files for this commit
3. `git commit` with the planned message
4. Move to the next commit

### Rules

- Group by intent: a bug fix, a feature addition, a refactor, config changes, docs — each gets its own commit
- Follow conventional commits format (`feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`, `perf:`, `ci:`)
- Match the repository's existing commit style from recent history
- If ALL changes share a single intent, create just one commit (don't force multiple)
- Never commit files that likely contain secrets (.env, credentials, tokens)
- List the full change tree in your plan so the user can verify grouping