#!/usr/bin/env bun

/**
 * PreToolUse Hook: Remind to use zellij for long-running commands
 *
 * Suggests running npm/pnpm/yarn/bun install/test, cargo build, make,
 * docker, pytest, vitest, and playwright inside a zellij session for
 * persistence. Only warns when not already inside zellij.
 */

const LONG_RUNNING_RE =
  /(npm (install|test)|pnpm (install|test)|yarn (install|test)?|bun (install|test)|cargo build|make\b|docker\b|pytest|vitest|playwright)/;

let data = '';
process.stdin.on('data', chunk => (data += chunk));
process.stdin.on('end', () => {
  try {
    const input = JSON.parse(data);
    const cmd = input.tool_input?.command || '';

    if (process.platform !== 'win32' && !process.env.ZELLIJ && LONG_RUNNING_RE.test(cmd)) {
      console.error('[Hook] Consider running in zellij for session persistence');
      console.error('[Hook] zellij -s dev  |  zellij attach dev');
    }
  } catch {}

  process.stdout.write(data);
});
