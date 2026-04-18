#!/usr/bin/env bash
# Prune ~/.claude caches: old transcripts, orphaned todos, stale image-cache.
# Dry-run by default; pass --apply to actually delete.

set -euo pipefail

DAYS="${DAYS:-30}"
APPLY=false
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=true ;;
    --days=*) DAYS="${arg#--days=}" ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--apply] [--days=N]

  --apply    Actually delete files (default: dry-run)
  --days=N   Retention threshold in days (default: 30)

Targets:
  ~/.claude/projects/**/*.jsonl  (session transcripts older than N days)
  ~/.claude/todos/*              (todo files older than N days)
  ~/.claude/image-cache/*        (image cache dirs older than N days)
  ~/.claude/shell-snapshots/*    (shell snapshots older than N days)
EOF
      exit 0
      ;;
  esac
done

ROOT="$HOME/.claude"

report_and_delete() {
  local label="$1"; shift
  local files
  files=$(find "$@" -mtime +"$DAYS" 2>/dev/null || true)
  if [[ -z "$files" ]]; then
    printf "  %-20s 0 files\n" "$label:"
    return
  fi
  local n bytes human
  n=$(printf '%s\n' "$files" | wc -l)
  bytes=$(printf '%s\n' "$files" | xargs -d '\n' du -cb 2>/dev/null | tail -1 | awk '{print $1}')
  human=$(numfmt --to=iec --suffix=B "${bytes:-0}" 2>/dev/null || echo "${bytes:-0}B")
  printf "  %-20s %d files, %s\n" "$label:" "$n" "$human"
  if $APPLY; then
    printf '%s\n' "$files" | xargs -d '\n' rm -rf
  fi
}

echo "Retention: ${DAYS} days"
echo "Mode: $($APPLY && echo APPLY || echo DRY-RUN)"
echo
echo "Eligible for cleanup:"

report_and_delete "transcripts"     "$ROOT/projects"        -type f -name '*.jsonl'
report_and_delete "todos"           "$ROOT/todos"           -type f
report_and_delete "image-cache"     "$ROOT/image-cache"     -mindepth 1 -maxdepth 1
report_and_delete "shell-snapshots" "$ROOT/shell-snapshots" -type f

echo
if ! $APPLY; then
  echo "Dry-run only. Re-run with --apply to delete."
fi
