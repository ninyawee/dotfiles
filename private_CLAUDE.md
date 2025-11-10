# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Dotfile management system using chezmoi with Omakub as the base configuration. Optimized for Graphite keyboard layout and Ubuntu desktop environments. Includes legacy Dorothy setup files for multi-platform support (Linux, macOS, Windows/WSL2).

## Common Commands
- **Apply changes**: `chezmoi apply` or `cma` (alias)
- **Edit and apply**: `chezmoi edit --apply <file>` or `cme <file>` (alias)
- **Add encrypted file**: `chezmoi add --encrypt <file>` or `cmae <file>` (alias)
- **Preview changes**: `chezmoi diff`
- **Check status**: `chezmoi status`
- **Verify template syntax**: `chezmoi data`
- **Refresh externals**: `chezmoi apply --refresh-externals`
- **Install mise tools**: `mise install` or `m install` (alias)
- **Update mise tools**: `mise up` or `m up` (alias)
- **Encrypt file with sops**: `mise run encrypt <file>` or `me <file>` (alias)
- **Decrypt file with sops**: `mise run decrypt <file>`
- **Lint shell scripts**: `shfmt -d .` or `shfmt -w .`
- **Check Python code**: `ruff check . --fix`

## Architecture & Structure
- **dot_config/**: Chezmoi-managed configuration files
  - **mise/**: Tool version management, environment variables, and custom tasks
    - `config.toml.tmpl`: Main mise configuration with 50+ tools
    - `tasks/`: Custom mise tasks for encryption/decryption workflows
  - **espanso/**, **lazygit/**, **zellij/**, **helix/**, etc.: Tool-specific configs
- **dot_bash_aliases**: Extensive alias definitions (cm, m, u, lg, z, etc.)
- **dot_bashrc**: Sources Omakub defaults and Cargo environment
- **dot_profile**: Standard login shell profile
- **dot_gitconfig.tmpl**: Git config with git-town aliases and delta integration
- **dot_local/bin/**: Custom scripts and external downloads via `.chezmoiexternal.toml`
- **.chezmoiscripts/**: Chezmoi run scripts (e.g., `run_onchange_after_load-tactile-dconf.sh`)
- **setup/**: Installation scripts for Ubuntu/desktop environments
- **Devs/**: Legacy Dorothy setup files (mostly unused, kept for reference)
- **.age files**: Age-encrypted sensitive configs (Yubico, espanso, rclone, mise local config)

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


## Chezmoi Template System
- **Template variables**: Access with `{{ .chezmoi.os }}`, `{{ .chezmoi.homeDir }}`, etc.
- **Environment variables**: `{{ env "VAR_NAME" }}`
- **Executable scripts**: Use `executable_` prefix instead of `chmod +x`
  - Example: `executable_configure-keyboard-layout` is automatically made executable
  - Chezmoi handles permissions on apply; never manually chmod files in the source directory
- **Run-once scripts**: Use `.chezmoiscripts/run_onchange_*` pattern
  - Hash tracking: Include `{{ include "file" | sha256sum }}` to trigger on file changes
  - Example: `run_onchange_after_load-tactile-dconf.sh` runs after config changes
- **External files**: Define in `.chezmoiexternal.toml` for URL-based downloads
  - Support for scripts, archives, and periodic refresh (e.g., `refreshPeriod = "168h"`)
- **Encryption**: Age encryption with sops integration
  - Files ending in `.age` are automatically encrypted/decrypted
  - Age key: `~/.config/sops/age/keys.txt`
  - Recipients configured in mise env vars (`MY_SOPS_RECIPIENTS`)

## Environment & Dependencies
- **Base system**: Ubuntu with Omakub configuration framework
- **Dotfile manager**: chezmoi with age encryption and VS Code merge/diff integration
- **Tool manager**: mise (50+ tools including languages, CLIs, and development tools)
- **Primary shell**: bash (with zsh, nushell support via Devs/)
- **Key integrations**:
  - Omakub for base shell configuration
  - Starship prompt
  - Atuin for shell history
  - git-town for Git workflow
  - Age + sops for encryption (not 1Password)

## Tool Management Strategy
- **mise**: Primary tool manager in `dot_config/mise/config.toml.tmpl`
  - **Languages**: Python 3.12, Node (LTS), Go, Rust, Java, Bun, Deno
  - **Build tools**: cargo-binstall, just, uv
  - **Development**: aider-chat, helix, lazygit, lazydocker, gh, delta
  - **CLI utilities**: fd, ripgrep, bat, eza, fzf, zoxide, sd, watchexec
  - **Terminals**: zellij, television, mprocs
  - **Installation backends**: native, cargo, pipx (with uvx), ubi, go install
  - **Custom tasks**: Encryption/decryption workflows via mise tasks
  - **Settings**: Python compilation enabled, npm uses bun, pipx uses uvx
- **Secondary installers**: apt, webi (in setup/ scripts)

## Key Configuration Files
- `dot_config/mise/config.toml.tmpl`: Central tool management, environment variables, custom tasks
- `.chezmoi.toml.tmpl`: Age encryption config, VS Code merge/diff integration
- `dot_bashrc`: Sources Omakub + Cargo environment
- `dot_bash_aliases`: Comprehensive aliases (chezmoi, mise, git, editors, etc.)
- `dot_gitconfig.tmpl`: Git config with git-town workflow aliases and delta
- `dot_local/bin/.chezmoiexternal.toml`: External binary downloads (e.g., wsl-open)
- `dot_config/mise/tasks/`: Custom mise tasks for encryption workflows

## Guidelines
- Prefer `$HOME` over hardcoded paths (e.g. `/home/ben`)
- When modifying encrypted `.age` files, decrypt first, edit, then re-encrypt
- Test template changes with `chezmoi data` before applying
- Use mise for tool management instead of manual installation
- Follow existing naming patterns for new dotfiles (dot_ prefix for chezmoi)