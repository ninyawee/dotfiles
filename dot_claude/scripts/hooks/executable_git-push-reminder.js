#!/usr/bin/env bun

/**
 * PreToolUse Hook: Reminder before git push
 *
 * Logs a reminder to review changes before pushing.
 */

let data = '';
process.stdin.on('data', chunk => (data += chunk));
process.stdin.on('end', () => {
  try {
    const input = JSON.parse(data);
    const cmd = input.tool_input?.command || '';

    if (/git push/.test(cmd)) {
      console.error('[Hook] Review changes before push...');
      console.error('[Hook] Continuing with push (remove this hook to add interactive review)');
    }
  } catch {}

  process.stdout.write(data);
});
