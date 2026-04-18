#!/usr/bin/env bash
# Rebuild sudo-confirm as a standalone bun binary with bytecode.
# Run after editing sudo-confirm.js.
set -euo pipefail
cd "$(dirname "$0")"
bun build --compile --minify --bytecode --target=bun-linux-x64 \
  ./sudo-confirm.js --outfile ./sudo-confirm
echo "Built $(du -h sudo-confirm | cut -f1)"
