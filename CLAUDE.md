# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
 - a sophisticated shell configuration ecosystem managed with chezmoi. Dorothy provides a custom commands, and system configurations across multiple platforms (Linux, macOS, Windows/WSL2).

## Build/Lint/Test Commands
- Apply dotfile changes: `chezmoi apply`
- Preview changes: `chezmoi diff`
- Check chezmoi status: `chezmoi status`
- Verify template syntax: `chezmoi data`
- Force refresh external files: `chezmoi apply --refresh-externals`
- Install mise tools: `mise install`
- Update mise tools: `mise up`
- Lint shell scripts: `shfmt -d .` or `shfmt -w .`
- Check Python code: `ruff check . --fix`

## Architecture & Structure
- **dot_config/**: Chezmoi-managed configuration files for various tools
  - **mise/**: Tool version management and environment configuration
  - **gh/**, **rclone/**, **espanso/**: Individual tool configurations
- **setup/**: Installation and setup scripts for various tools
- **Devs/**: Legacy Dorothy setup files and configurations
- **.tmpl files**: Chezmoi templates that get processed during `chezmoi apply`
- **.age files**: Age-encrypted sensitive data (1Password integration)
- **dot_bash_***: Shell configuration files (bashrc, bash_aliases, bash_profile)
- **dot_gitconfig.tmpl**: Git configuration template

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
- Templates can access chezmoi variables (e.g., `{{ .chezmoi.os }}`, `{{ .chezmoi.homeDir }}`)
- Use `run_onchange_*.sh.tmpl` for scripts that run when their content changes
- Encrypted files use `.age` extension with 1Password as the encryption backend
- Environment variables can be accessed in templates with `{{ env "VAR_NAME" }}`

## Environment
- Repository is managed with chezmoi dotfile manager
- Uses mise as a tool version manager
- Shell environments include bash, zsh, nushell, and PowerShell
- 1Password CLI (`op`) integration for secrets management
- Atuin for shell history management

## Tool Management Strategy
- **mise**: Primary tool version manager configured in `dot_config/mise/config.toml.tmpl`
  - Manages programming languages, runtimes, and development tools
  - Automatic environment loading via `mise.toml` files
  - Uses various backends: cargo, pipx, ubi, go install
- **Package managers**: Secondary tool installation via webi, apt, winget, homebrew
- **Encryption**: Age encryption with 1Password integration for sensitive configurations

## Key Configuration Files
- `dot_config/mise/config.toml.tmpl`: Central tool and environment management
- `.chezmoi.toml.tmpl`: Chezmoi configuration with age encryption and VS Code merge/diff
- `dot_bashrc`: Shell initialization and configuration
- `dot_bash_aliases`: Custom shell aliases and functions
- `Devs/Tools/.chezmoiexternal.toml`: External file downloads and archive extractions

## Guidelines
- Prefer `$HOME` over hardcoded paths (e.g. `/home/ben`)
- When modifying encrypted `.age` files, decrypt first, edit, then re-encrypt
- Test template changes with `chezmoi data` before applying
- Use mise for tool management instead of manual installation
- Follow existing naming patterns for new dotfiles (dot_ prefix for chezmoi)