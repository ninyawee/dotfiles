---
name: gh-issue
description: "Manage GitHub Issues with Projects v2: create issues and sub-issues, apply labels, update project metadata (status, priority, size, estimate, dates), manage relationships (parent, blocked-by, blocking), and upload images. Use this skill whenever the user wants to create, update, or organize GitHub issues -- especially when they mention sub-issues, project boards, issue priorities, estimates, blocking relationships, or any project field updates. Also trigger when the user mentions Pakjai project, issue hierarchies, or wants to batch-update issues."
---

# GitHub Issue Management

The `gh-issue` CLI tool at `~/.local/bin/gh-issue` wraps `gh` and the GitHub GraphQL/REST APIs for full issue lifecycle management with Projects v2 support.

## Quick Reference

```bash
# Always specify repo with -R if not in a git repo
gh-issue -R OWNER/REPO <command> [options]
```

| Command | What it does |
|---------|-------------|
| `create` | Create issue, optionally as sub-issue of a parent |
| `sub add/remove/list` | Manage sub-issue hierarchy |
| `label add/remove` | Add or remove labels |
| `image` | Upload image (commits to repo, appends to issue body) |
| `meta` | Update project v2 fields (status, priority, size, estimate, dates) |
| `relate` | Manage relationships: parent, blocked-by, blocking |
| `fields` | List project fields and their allowed values |

## Creating Issues

```bash
# Simple issue
gh-issue -R ninyawee/pakjai create -t "Fix login bug" -b "Users can't log in on mobile"

# With labels and assignee
gh-issue -R ninyawee/pakjai create -t "Add dark mode" -l "enhancement" -l "frontend" -a "@me"

# Create as sub-issue of parent #100
gh-issue -R ninyawee/pakjai create -t "Implement color tokens" -p 100
```

## Sub-Issues

Sub-issues create parent-child hierarchies (not old task-list checkboxes).

```bash
# Add existing issue #42 as sub-issue of #10
gh-issue -R ninyawee/pakjai sub add 10 42

# Remove sub-issue
gh-issue -R ninyawee/pakjai sub remove 10 42

# List all sub-issues of #10
gh-issue -R ninyawee/pakjai sub list 10
```

The REST API uses the issue's numeric `id` (not `number`, not `node_id`). The tool handles this conversion automatically.

## Labels

```bash
gh-issue -R ninyawee/pakjai label add 42 bug P1
gh-issue -R ninyawee/pakjai label remove 42 wontfix
```

## Project Metadata

Update any combination of project v2 fields in a single call. The tool auto-detects which project the issue belongs to.

```bash
gh-issue -R ninyawee/pakjai meta 42 \
  --status "In progress" \
  --priority P1 \
  --size XL \
  --estimate 124 \
  --start-date 2026-03-03 \
  --target-date 2026-04-15
```

If the issue is in multiple projects, specify which one:

```bash
gh-issue -R ninyawee/pakjai meta 42 --project 6 --owner ninyawee --priority P0
```

### Pakjai Project (#6) Field Values

| Field | Options |
|-------|---------|
| Status | Backlog, Ready, In progress, In review, Follow up, Done |
| Priority | P0, P1, P2 |
| Size | XS, S, M, L, XL |
| Estimate | any number |
| Start date | YYYY-MM-DD |
| Target date | YYYY-MM-DD |

Run `gh-issue fields 6 ninyawee` to see the latest field definitions.

## Relationships

```bash
# Issue #42 is blocked by issue #10
gh-issue -R ninyawee/pakjai relate blocked-by 42 10

# Issue #10 is blocking issue #42 (same relationship, other direction)
gh-issue -R ninyawee/pakjai relate blocking 10 42

# Remove a blocking relationship
gh-issue -R ninyawee/pakjai relate unblocked-by 42 10

# Set parent (alias for sub add, from child's perspective)
gh-issue -R ninyawee/pakjai relate parent 42 10
```

These use GraphQL mutations (`addBlockedBy`, `removeBlockedBy`). There is no REST API for relationships.

## Images

GitHub has no public image upload API. The workaround is to commit the image to the repo and reference it via raw URL.

```bash
# Must be run from inside the git repo
gh-issue -R ninyawee/pakjai image 42 ~/Pictures/Screenshots/screenshot.png "Login bug"
```

This will: copy to `docs/screenshots/`, commit, push, and append a markdown image reference to the issue body.

## Batch Operations

For creating a parent issue with multiple sub-issues and full metadata, chain commands:

```bash
REPO="ninyawee/pakjai"

# Create parent
PARENT_URL=$(gh-issue -R $REPO create -t "Epic: Redesign dashboard" -l "epic")
PARENT=$(basename "$PARENT_URL")

# Create sub-issues
for title in "Design mockups" "Implement layout" "Add charts" "Write tests"; do
  gh-issue -R $REPO create -t "$title" -p "$PARENT"
done

# Set metadata on parent
gh-issue -R $REPO meta "$PARENT" \
  --status "In progress" --priority P1 --size XL \
  --estimate 40 --start-date 2026-03-09
```

## Direct API Fallbacks

For operations the tool doesn't cover, use `gh api` directly:

```bash
# Get issue details
gh api repos/ninyawee/pakjai/issues/42

# List project items
gh project item-list 6 --owner ninyawee --format json

# Add issue to project
gh project item-add 6 --owner ninyawee --url "https://github.com/ninyawee/pakjai/issues/42"

# GraphQL for anything else
gh api graphql -f query='
  query($nodeId: ID!) {
    node(id: $nodeId) {
      ... on Issue { title state }
    }
  }
' -f nodeId="$(gh-issue -R ninyawee/pakjai node-id 42)"
```
