# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is a Dorothy dotfiles repository - a sophisticated shell configuration ecosystem managed with chezmoi. Dorothy provides a framework for managing shell environments, custom commands, and system configurations across multiple platforms (Linux, macOS, Windows/WSL2).

## Build/Lint/Test Commands
- PowerShell tests: `Invoke-Pester .` (from within test directory)
- Run specific test: `Invoke-Pester -Path ./path/to/test_file.ps1`
- Apply dotfile changes: `chezmoi apply`
- Preview changes: `chezmoi diff`
- Dorothy commands are in `commands/` and are directly executable

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

## Dorothy-Specific Patterns
- Commands should be self-contained executable scripts
- Use Dorothy's built-in utilities where available (e.g., `setup-util-*` pattern)
- Configuration files in `config/` are sourced automatically by Dorothy
- Follow the `setup-*` naming pattern for installation scripts

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
- Dorothy root is located at `/home/ben/.local/share/dorothy/`
- Example: `setup-util` command is located at `/home/ben/.local/share/dorothy/commands/setup-util`