#!/bin/bash
# Restore CLAUDE.md to chezmoi source directory if missing
# (CLAUDE.md is in .chezmoiignore so it won't be applied to ~/)
CHEZMOI_DIR="$HOME/.local/share/chezmoi"
if [ ! -f "$CHEZMOI_DIR/CLAUDE.md" ]; then
  git -C "$CHEZMOI_DIR" checkout HEAD -- CLAUDE.md 2>/dev/null || true
fi
