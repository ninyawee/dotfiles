#!/usr/bin/env bun

/**
 * PostToolUse Hook: Log PR URL after creation
 *
 * After `gh pr create` completes, extracts the PR URL from the output
 * and logs it along with a convenient review command.
 */

const PR_URL_RE = /https:\/\/github\.com\/[^/]+\/[^/]+\/pull\/\d+/;

let data = '';
process.stdin.on('data', chunk => (data += chunk));
process.stdin.on('end', () => {
  try {
    const input = JSON.parse(data);
    const cmd = input.tool_input?.command || '';

    if (/gh pr create/.test(cmd)) {
      const output = input.tool_output?.output || '';
      const match = output.match(PR_URL_RE);

      if (match) {
        const url = match[0];
        const repo = url.replace(/https:\/\/github\.com\/([^/]+\/[^/]+)\/pull\/\d+/, '$1');
        const pr = url.replace(/.+\/pull\/(\d+)/, '$1');

        console.error(`[Hook] PR created: ${url}`);
        console.error(`[Hook] To review: gh pr review ${pr} --repo ${repo}`);
      }
    }
  } catch {}

  process.stdout.write(data);
});
