# Tooling Preferences

## Task Runner: mise

`mise` is the preferred task runner (over `just`/Makefile):

- `mise.toml` for shared config, `mise.local.toml` for personal config (git-ignored)
- Short tasks go inline in `mise.toml`; longer scripts go in `mise-tasks/` dir (ensure executable permission, auto-discovered)
- Scripts in `mise-tasks/` can be any language as long as executable — shell scripts and uv shebang scripts are common
- Use directives: `depends`, `sources`, `outputs`, `redactions`, `dir`, `confirm`

### Task Pipelining

Mix sequential and parallel steps in a single task:

```toml
[tasks.grouped]
run = [
  { task = "t1" },          # run t1 (with its dependencies)
  { tasks = ["t2", "t3"] }, # run t2 and t3 in parallel (with their dependencies)
  "echo end",               # then run a script
]
```

### fnox-env Plugin

Auto-inject fnox vars into mise tasks (no `fnox exec` wrapper needed):

```toml
[plugins]
fnox-env = "https://github.com/jdx/mise-env-fnox"

[tools]
fnox = "latest"

[env]
_.fnox-env = { tools = true }
```

## JavaScript/TypeScript: bun

- Prefer `bun` over `npm` or `node`

## Python: uv

- Prefer `uv` over `python` or `pip`
- Package management: `uv add [package]` to add dependencies to `pyproject.toml`
- Script execution: `uv run --with httpx script.py`
- Preferred: uv shebang header for standalone scripts:

```python
#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["httpx"]
# ///
import httpx
```

## Google Services: gog CLI

`gog` CLI for Google Tasks, Calendar, Gmail:

- **Tasks**: `gog tasks lists list`, `gog tasks add [listId] --title "..." --due "YYYY-MM-DD"`, `gog tasks list [listId]`, `gog tasks done [listId] [taskId]`
- **Calendar**: `gog calendar create primary --summary "..." --from "YYYY-MM-DD" --to "YYYY-MM-DD" --all-day`, timed events with `--from "...T09:00:00" --to "...T10:00:00"`
- **Common flags**: `--dry-run`, `--json`, `--plain`
- Run `gog tasks lists list` to discover task list IDs
