# Chezmoi Dotfiles Repository

This is Ben's chezmoi-managed dotfiles repo. Source directory: `~/.local/share/chezmoi/`
Target: `~/` (home directory)

## Chezmoi Conventions

### Source-to-Target Naming
- `dot_` prefix → `.` (e.g. `dot_bashrc` → `~/.bashrc`)
- `private_` prefix → 0600 permissions
- `executable_` prefix → 0755 permissions
- `.tmpl` suffix → Go template, rendered by chezmoi
- `encrypted_` prefix → age-encrypted file
- Files without prefixes map directly to target paths

### Directory Structure
```
.chezmoi.toml.tmpl          # chezmoi config template (age encryption, merge tool)
.chezmoiignore              # files chezmoi should skip
.chezmoiscripts/            # run_once / run_onchange scripts
dot_bashrc.tmpl             # ~/.bashrc (templated, uses 1Password refs)
dot_bash_aliases             # ~/.bash_aliases
dot_profile                  # ~/.profile
dot_gitconfig.tmpl           # ~/.gitconfig
dot_claude/                  # ~/.claude/ (agents, commands, rules, skills, hooks)
dot_config/                  # ~/.config/ (mise, kanata, alacritty, lazygit, etc.)
dot_local/private_share/     # ~/.local/share/ (omakub via .chezmoiexternal.toml)
ddd/                         # ~/ddd/ (tools, keyboards, dorothy, setup files)
private_init_setup/          # initial machine setup scripts
setup/                       # ubuntu setup helpers
```

### External Dependencies (.chezmoiexternal.toml)
- `dot_local/private_share/` → omakub (git-repo)
- `ddd/tools/` → dorothy, pg-essentials, graphite-layout, openclaw, plover, keymapp, nerd-dictation, plankton, tippecanoe, android-studio, ventoy

### Encryption
- Uses `age` encryption with recipient `age1jqy4r7lltng327m9wzwtrwcd9pkjpveafmv8cjhv2tymdmcg93vqrc3y4j`
- Identity key at `~/.config/sops/age/keys.txt`
- Add encrypted files: `chezmoi add --encrypt`

### Templating
- `.tmpl` files use Go templates with chezmoi functions
- 1Password secrets via `{{ onepasswordRead "op://..." }}` (used in `dot_bashrc.tmpl`)
- chezmoi data via `{{ .chezmoi.homeDir }}` etc.

## Key Tools & Preferences

### CLI Preferences
- **Task runner:** `mise` (not just/make) — config at `dot_config/mise/config.toml`
- **JS runtime:** `bun` over npm/node
- **Python:** `uv` over pip/python directly
- **Editor:** `micro` (CLI), VS Code (GUI), Helix
- **Shell:** bash (with omakub defaults)
- **Secrets:** `fnox` with age backend for projects, 1Password CLI for system-level secrets

### System
- Ubuntu Linux with Omakub base
- Kanata for keyboard remapping
- Graphite keyboard layout + Manoonchai
- Systemd user services in `dot_config/systemd/`

## Working in This Repo

### Adding a new dotfile
```bash
chezmoi add ~/.config/foo/bar.toml        # plain file
chezmoi add --encrypt ~/.config/secret    # encrypted file
```
This creates the source file in this repo with proper chezmoi naming.

### Adding external git repos / archives
Edit the appropriate `.chezmoiexternal.toml`:
```toml
["./tool-name"]
type = "git-repo"
url = "https://github.com/owner/repo.git"
refreshPeriod = "168h"
```

### Chezmoi scripts
Place in `.chezmoiscripts/` with naming convention:
- `run_once_*` → runs once per machine
- `run_onchange_*` → runs when script content changes (use hash in name)
- `run_once_after_*` / `run_onchange_after_*` → runs after file apply

### Testing changes
```bash
chezmoi diff        # see what would change
chezmoi apply -n    # dry run
chezmoi apply       # apply changes
```

## Ignored in .chezmoiignore
- `/README.md`, `CLAUDE.md` — repo-only files, not applied to home
- `/Devs/Tools/setup/chezmoi_files` — old reference files
- `/.vscode/`, `mise.toml` — editor/local config
