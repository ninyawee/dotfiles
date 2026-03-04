#!/usr/bin/env bun

/**
 * PostToolUse Hook (async): Build completion notification
 *
 * Logs a message when a build command completes.
 * Runs asynchronously without blocking the main session.
 */

let data = '';
process.stdin.on('data', chunk => (data += chunk));
process.stdin.on('end', () => {
  try {
    const input = JSON.parse(data);
    const cmd = input.tool_input?.command || '';

    if (/(npm run build|pnpm build|yarn build|bun run build)/.test(cmd)) {
      console.error('[Hook] Build completed - async analysis running in background');
    }
  } catch {}

  process.stdout.write(data);
});
