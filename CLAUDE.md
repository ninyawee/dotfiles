# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Lint/Test Commands
- PowerShell tests: `Invoke-Pester .` (from within test directory)
- Run specific test: `Invoke-Pester -Path ./path/to/test_file.ps1`

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

## Environment
- Repository is managed with chezmoi dotfile manager
- Uses mise as a tool version manager
- Shell environments include bash, zsh, and PowerShell