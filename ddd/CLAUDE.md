# Gereral Guide

## env vars
- `fnox` cli is preferred to store and retrive secrets and variables(public-able, app-parameters/feature-flags).
    - `fnox exec -- [command]` to run commands with secrets loaded from fnox.
    - `fnox list` to list available secrets.
    - set
        - variables `fnox set --default [key] [value]`
        - secrets `echo [] | fnox set [key]`
    - AVOID `fnox get [key]` as it may expose secrets in shell history. use `fnox ls | grep [key]` to check existence instead.
    - `fnox` supports hierarchical config files that expose to only the dir below it. there MUST NOT have global config file at `~/.fnox.toml`, only project local(git root) `./.fnox.toml` is allowed.
    - we use `fnox` age backend for secret encryption.
    - `fnox` could also have profiles(e.g. [dev-name], [env:prod,staging]) to separate secrets for different environments.

```toml our fnox starter, at project root, MUST contain providers.
[providers.age]
type = "age"
recipients = ["age1jqy4r7lltng327m9wzwtrwcd9pkjpveafmv8cjhv2tymdmcg93vqrc3y4j"]

[secrets]
```

### document
maintain docs all env vars `.env.example`


## makefile
- `mise` cli is preferred to store common tasks as scripts , wide variety tools use, as well as environement variable(prefer `fnox` but old project) hierachically. [`mise.toml` share among dev, `mise.local.toml` (personally, exclude from git)] at project root.
    - for simple direct use, `package.json` scripts (or `pyproject.toml`, etc.) is fine. for more complex multi-stage, long scripts, or tasks beyond runtime/framework scope, use local `mise.toml` with directives like `depends`, `sources`, `outputs`, `redactions`, `dir`, `confirm` — these are important and encouraged.
    - tasks
        - a few line should be in `mise.toml`
        - else, in `mise-tasks/` dir. ensure executable permission, it will auto pickup. can be any language as long as executable. #uvShebangHeader is common cool pattern. `.sh` is also common.
    - pipelining: mix sequential and parallel steps in a single task
        ```toml
        [tasks.grouped]
        run = [
          { task = "t1" },          # run t1 (with its dependencies)
          { tasks = ["t2", "t3"] }, # run t2 and t3 in parallel (with their dependencies)
          "echo end",               # then run a script
        ]
        ```

- prefer `bun` cli over `npm` or `node`
- prefer `uv` cli over `python` (via `uv run python`) or `pip`
    - as package manager, `uv add [package]` is used to add dependencies to `pyproject.toml`.
    - as script executor, `uv run --with httpx script.py` is commonly used. #uvShebangHeader deps combo is much prefer.

```python
#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["httpx"]
# ///
import httpx

print(httpx.get("https://example.com"))
```

- `just` justfile is not used anymore, prefer `mise` instead.

## user typing notion
`[what:example,example2,...]` is used to indicate the type of the thing. could be multiple types. sometimes `[]` means `[fill in what is appropriate]`. e.g. create `notes/research/[].md` what we have done so far. means create a research note, fill in appropriate title such as `notes/research/2024-06-01-the-best-model-for-geodecode.md`.

## git worktrees
- we use `git worktree` to work on multiple branches simultaneously.
- worktree path convention: `<repo>.wt.<name>` (e.g. `pakjai.wt.main`, `pakjai.wt.admin-panel`) as siblings of the main repo directory.
- the main repo directory itself is always a worktree (typically on `develop` or a feature branch).
- to clean up: `git worktree remove <path>`, then `git worktree prune` if needed.

## note taking
- in markdown files `.md` or mermaid `.mmd`
- in `notes/[note group:research,workaround,why]/[date]-[title][ext]` dir of the project root

## screenshots
- when user provides images in chat, the actual files are likely in `~/Pictures/Screenshots/`
- ubuntu screenshots location: `~/Pictures/Screenshots/`
- filenames: `Screenshot from YYYY-MM-DD HH-MM-SS.png`
- sorted by `ls -1 --sort=time` (oldest first, most recent at bottom via `tail`)

## github issues with screenshots
- `gh` cli does not support direct image upload to issues.
- workaround: commit images to the repo, then reference via raw URL.
    1. copy screenshots to `docs/screenshots/` with descriptive names (e.g. `issue-2-description.png`)
    2. `git add docs/screenshots/ && git commit && git push`
    3. reference in issue body: `![alt](https://raw.githubusercontent.com/[owner]/[repo]/main/docs/screenshots/[filename].png)`
    4. `gh issue edit [number] --repo [owner]/[repo] --body "$(cat <<'EOF' ... EOF)"`

