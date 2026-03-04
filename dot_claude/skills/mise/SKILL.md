---
name: mise-tasks
description: "Mise task configuration for project automation. Use when: (1) Creating or editing mise.toml tasks, (2) Setting up build/deploy/test automation, (3) Understanding task directives like depends, sources, outputs, confirm, (4) Configuring task pipelining or incremental builds"
---

# Mise Task Configuration

Reference for writing `mise.toml` tasks. Docs: https://mise.jdx.dev/tasks/task-configuration.html

## When to Use What

| Scenario | Approach |
|----------|----------|
| Simple one-liner | Inline `run` in `mise.toml` |
| Multi-line or complex logic | Script file in `mise-tasks/` (ensure `chmod +x`) |
| Multi-stage with dependencies | `depends`, `sources`, `outputs` directives |
| Beyond runtime/framework scope | Local `mise.toml` with full directive use |

## Core Directives

### `run` (required)

The command(s) to execute. Supports pipelining with task references:

```toml
[tasks.deploy]
run = [
  { task = "build" },                # run build first
  { tasks = ["test", "lint"] },      # then test + lint in parallel
  "echo 'deploying...'",             # then run a script
  { task = "upload" },               # then upload
]
```

### `depends`

Tasks that MUST complete before this task runs. Duplicate dependencies run only once.

```toml
[tasks.test]
depends = ["build"]
run = "bun test"

# with args and env forwarding
[tasks.deploy]
depends = [
  { task = "build", args = ["--release"], env = { NODE_ENV = "production" } }
]
run = "fly deploy"
```

### `depends_post`

Tasks that run AFTER this task completes. Useful for cleanup.

```toml
[tasks.test]
depends_post = ["cleanup-fixtures"]
run = "bun test"
```

### `sources` and `outputs`

Enable incremental execution — task skips if outputs are newer than sources.

```toml
[tasks.build]
sources = ["src/**/*.ts", "package.json"]
outputs = ["dist/**/*"]
run = "bun run build"
```

- `sources`: glob patterns for input files
- `outputs`: glob patterns for output files, or `{ auto = true }` (default, stores state in `~/.local/state/mise/task-outputs/`)

### `dir`

Working directory for execution. Defaults to config file location.

```toml
[tasks.frontend-build]
dir = "frontends/liff"
run = "bun run build"

# use caller's cwd instead of config root
[tasks.format]
dir = "{{cwd}}"
run = "prettier --write ."
```

### `confirm`

Prompt user before execution. Supports Tera templates.

```toml
[tasks.db-reset]
confirm = "This will DROP all tables. Continue?"
run = "supabase db reset"

[tasks.deploy]
confirm = "Deploy to {{ usage.environment }}?"
run = "fly deploy"
```

### `env`

Task-specific environment variables (NOT propagated to dependencies).

```toml
[tasks.test]
env = { NODE_ENV = "test", LOG_LEVEL = "debug" }
run = "bun test"
```

### `tools`

Pin tool versions for specific tasks.

```toml
[tasks.build]
tools = { node = "22", bun = "latest" }
run = "bun run build"
```

### `usage`

Define CLI arguments and flags with help text.

```toml
[tasks.deploy]
usage = '''
arg "<environment>" env="DEPLOY_ENV" help="Target environment"
flag "-f --force" env="FORCE_DEPLOY" help="Skip confirmation"
'''
confirm = "Deploy to {{ usage.environment }}?"
run = "fly deploy --app myapp-{{ env.DEPLOY_ENV }}"
```

### `wait_for`

Optional dependencies — blocks if already running, but doesn't queue them.

```toml
[tasks.test]
wait_for = ["db-migrate"]
run = "bun test"
```

## Output Control

| Directive | Effect |
|-----------|--------|
| `quiet = true` | Suppress mise execution details, keep script output |
| `silent = true` | Suppress ALL output |
| `silent = "stdout"` | Suppress only stdout |
| `silent = "stderr"` | Suppress only stderr |
| `raw = true` | Direct shell I/O (for interactive tasks) |

## Sensitive Output

### `redactions` (experimental)

Hide secrets from task output. Supports glob patterns.

```toml
[tasks.deploy]
redactions = ["API_KEY", "SECRETS_*"]
run = "deploy.sh"
```

## Visibility

```toml
[tasks.internal-helper]
hide = true              # hidden from `mise tasks` listing
alias = "ih"             # short name: `mise run ih`
description = "Internal helper, not for direct use"
```

## Global Settings

```toml
[settings]
task_output = "prefix"       # prefix | interleave | quiet | silent
# task.timeout = "5m"        # default timeout
# task.skip = ["lint"]       # globally skip tasks
```

## Pipelining Pattern (Summary)

```toml
[tasks.ci]
run = [
  { task = "install" },              # step 1: install deps
  { tasks = ["lint", "typecheck"] }, # step 2: parallel checks
  { task = "test" },                 # step 3: test
  { task = "build" },               # step 4: build
]
```

Each step waits for the previous to finish. Tasks within `tasks: [...]` run in parallel.
