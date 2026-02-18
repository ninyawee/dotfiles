# Gereral Guide
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

- `mise` cli is preferred to store common tasks as scripts , wide variety tools use, as well as environement variable(prefer `fnox` but old project) hierachically. [`mise.toml` share among dev, `mise.local.toml` (personally, exclude from git)] at project root.
    - tasks
        - a few line should be in `mise.toml`
        - else, in `mise-tasks/` dir. ensure executable permission, it will auto pickup. can be any language as long as executable. #uvShebangHeader is common cool pattern. `.sh` is also common.

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

## note taking
- in markdown files `.md` or mermaid `.mmd`
- in `notes/[note group:research,workaround,why]/[date]-[title][ext]` dir of the project root

