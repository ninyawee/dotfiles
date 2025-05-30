# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
 - a sophisticated shell configuration ecosystem managed with chezmoi. Dorothy provides a custom commands, and system configurations across multiple platforms (Linux, macOS, Windows/WSL2).

## Build/Lint/Test Commands
- Apply dotfile changes: `chezmoi apply`
- Preview changes: `chezmoi diff`

## Architecture & Structure
- **commands/**: Custom Dorothy commands (executable scripts)
- **commands.local/**: User-specific commands (gitignored)
- **config/**: Shell and tool configurations loaded by Dorothy
- **config.local/**: User-specific configurations (gitignored)
- **setup/**: Installation and setup scripts for various tools
- **chezmoi_files/**: Chezmoi-managed dotfile templates
- **.tmpl files**: Chezmoi templates that get processed during `chezmoi apply`
- **.age files**: Age-encrypted sensitive data (1Password integration)

## Code Style Guidelines
- Shell scripts should use shebang `#!/usr/bin/env bash`
- PowerShell uses Pester testing framework
- Script files should be executable and use kebab-case for names
- Exit with error codes (0 success, non-zero failure)
- Always validate required environment variables or conditions early
- Use comments to explain "why" not "what"
- Keep functions focused on a single responsibility
- For Bash scripts, prefer `fd` over `find` when available
- Use double quotes for string interpolation, single quotes otherwise
- PowerShell functions should use PascalCase (e.g., `Add-1PassFileOrFolder`)


## Chezmoi Template Variables
- Templates can access chezmoi variables (e.g., `{{ .chezmoi.os }}`)
- Use `run_onchange_*.sh.tmpl` for scripts that run when their content changes
- Encrypted files use `.age` extension with 1Password as the encryption backend

## Environment
- Repository is managed with chezmoi dotfile manager
- Uses mise as a tool version manager
- Shell environments include bash, zsh, nushell, and PowerShell
- 1Password CLI (`op`) integration for secrets management
- Atuin for shell history management

## Repository Paths

## Personal Tool Management Changes
- Moved away from Dorothy's interactive login form and most of its setup/installer scripts
- Now using:
  * mise with configuration at `@dot_config/mise/config.toml.tmpl`
  * webi
  * apt
  * winget
  * homebrew
- Simplified tool and environment management approach

## Guidelines
- Prefer `$HOME` over hardcoded paths (e.g. `/home/ben`)