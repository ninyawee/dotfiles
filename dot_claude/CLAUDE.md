# CLAUDE.md Global

## Core Philosophy

You are Claude Code. I use specialized agents and skills for complex tasks.

**Key Principles:**
1. **Agent-First**: Delegate to specialized agents for complex work
2. **Parallel Execution**: Use Task tool with multiple agents when possible
3. **Plan Before Execute**: Use Plan Mode for complex operations
4. **Test-Driven**: Write tests before implementation
5. **Security-First**: Never compromise on security

---

## Modular Rules

Detailed guidelines are in `~/.claude/rules/`:

| Rule File | Contents |
|-----------|----------|
| security.md | Security checks, fnox secret management |
| coding-style.md | Immutability, file organization, error handling |
| testing.md | TDD workflow, 80% coverage requirement |
| git-workflow.md | Commit format, PR workflow, worktrees |
| agents.md | Agent orchestration, when to use which agent |
| patterns.md | API response, repository patterns |
| performance.md | Model selection, context management |
| hooks.md | Hooks System |
| tooling.md | CLI preferences (mise, bun, uv, gws) |
| conventions.md | Typing notation, notes, screenshots |

## Hooks

Active hooks are registered in two places:
- **`~/.claude/settings.json`** `"hooks"` key — directly loaded by Claude Code (authoritative)
- **`~/.claude/hooks/hooks.json`** — plugin hooks (requires plugin registration in `enabledPlugins`)

Hook scripts live in `~/.claude/scripts/hooks/`. Active hooks:

| Hook | Source | Type | What It Does |
|------|--------|------|-------------|
| sudo-confirm.js | settings.json | PreToolUse/Bash | Intercepts `sudo`, shows zenity confirmation, executes with askpass, returns output to Claude |
| zellij-tab-status | hooks.json | multiple lifecycle events | Updates zellij tab status indicator (working/ready/needs-input) |

Code-quality automations (formatting, typechecking, lint warnings) are handled by **pre-commit** at the project level, not Claude Code hooks.

The sudo hook (`sudo-confirm.js` + `sudo-askpass.sh`) enables privileged command execution:
1. Zenity confirmation popup (Allow/Block)
2. Zenity password dialog (only when sudo cache expired)
3. Executes command and returns output to Claude

---

## Available Agents

Located in `~/.claude/agents/`:

| Agent | Purpose |
|-------|---------|
| planner | Feature implementation planning |
| architect | System design and architecture |
| tdd-guide | Test-driven development |
| code-reviewer | Code review for quality/security |
| code-architect | Feature architecture design from codebase patterns |
| code-explorer | Codebase analysis, execution tracing, dependency mapping |
| security-reviewer | Security vulnerability analysis |
| e2e-runner | Playwright E2E testing |
| refactor-cleaner | Dead code cleanup |
| doc-updater | Documentation updates |
| chief-of-staff | Multi-channel communication triage (email, Slack, LINE) |
| database-reviewer | PostgreSQL/Supabase schema, queries, performance |
| go-reviewer | Go code review (idiomatic, concurrency, errors) |
| python-reviewer | Python code review (PEP 8, type hints, security) |

---

## Personal Preferences

### Privacy
- Always redact logs; never paste secrets (API keys/tokens/passwords/JWTs)
- Review output before sharing - remove any sensitive data

### Code Style
- No emojis in code, comments, or documentation
- Many small files over few large files
- 200-400 lines typical, 800 max per file

### Git
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Always test locally before committing
- Small, focused commits

---

**Philosophy**: Agent-first design, parallel execution, plan before action, test before code, security always.
