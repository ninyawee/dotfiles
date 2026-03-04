#!/usr/bin/env bun

/**
 * PreToolUse Hook: Block dev servers outside zellij
 *
 * Ensures dev servers (npm/pnpm/yarn/bun run dev) are started inside
 * zellij so logs remain accessible after the Claude session ends.
 * Exits with code 2 to block the command.
 */

let data = '';
process.stdin.on('data', chunk => (data += chunk));
process.stdin.on('end', () => {
  try {
    const input = JSON.parse(data);
    const cmd = input.tool_input?.command || '';

    if (
      process.platform !== 'win32' &&
      /(npm run dev\b|pnpm( run)? dev\b|yarn dev\b|bun run dev\b)/.test(cmd)
    ) {
      console.error('[Hook] BLOCKED: Dev server must run in zellij for log access');
      console.error('[Hook] Use: zellij run -- npm run dev');
      console.error('[Hook] Or start a named session: zellij -s dev');
      process.exit(2);
    }
  } catch {}

  process.stdout.write(data);
});
