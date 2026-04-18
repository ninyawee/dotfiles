---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# TypeScript/JavaScript Hooks

> This file extends [common/hooks.md](../common/hooks.md) with TypeScript/JavaScript specific content.

Code-quality automations (formatting with Prettier/Biome, `tsc --noEmit`, `console.log` detection) are handled by **pre-commit hooks** at the project level, not Claude Code hooks.

Only infrastructure hooks (sudo confirmation, zellij status) run in the Claude Code harness — see `~/.claude/CLAUDE.md` "Hooks" section.
