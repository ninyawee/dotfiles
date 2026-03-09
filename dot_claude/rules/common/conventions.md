# Personal Workflow Conventions

## User Typing Notation

`[what:example,example2,...]` indicates the type of thing to fill in. May have multiple types. Sometimes `[]` means "fill in what is appropriate".

Example: "create `notes/research/[].md` for what we have done so far" means create a research note with an appropriate title like `notes/research/2024-06-01-the-best-model-for-geodecode.md`.

## Note-Taking

- Format: markdown `.md` or mermaid `.mmd`
- Location: `notes/[group]/[date]-[title][ext]` at project root
- Groups: `research`, `workaround`, `why`, or other appropriate categories

## Screenshots

- User screenshots are in `~/Pictures/Screenshots/`
- Filename pattern: `Screenshot from YYYY-MM-DD HH-MM-SS.png`
- Sort by time: `ls -1 --sort=time` (oldest first, most recent at bottom via `tail`)

## GitHub Issues with Screenshots

`gh` CLI does not support direct image upload to issues. Workaround:

1. Copy screenshots to `docs/screenshots/` with descriptive names (e.g. `issue-2-description.png`)
2. `git add docs/screenshots/ && git commit && git push`
3. Reference in issue body: `![alt](https://raw.githubusercontent.com/[owner]/[repo]/main/docs/screenshots/[filename].png)`
4. `gh issue edit [number] --repo [owner]/[repo] --body "$(cat <<'EOF' ... EOF)"`
