#!/usr/bin/env bun

/**
 * PreToolUse Hook: Intercept sudo commands with GNOME confirmation dialog
 *
 * Flow:
 * 1. Detect sudo in command
 * 2. Show zenity confirmation popup
 * 3. If approved, execute the command with zenity-based askpass for password
 * 4. Capture output and return it to Claude (block original to avoid double-run)
 * 5. If denied, block with reason
 */

import { execSync, execFileSync } from 'child_process';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const ASKPASS = join(dirname(fileURLToPath(import.meta.url)), 'sudo-askpass.sh');
const ENV = { ...process.env, DISPLAY: process.env.DISPLAY || ':1' };

let data = '';
process.stdin.on('data', chunk => (data += chunk));
process.stdin.on('end', () => {
  try {
    const input = JSON.parse(data);
    const cmd = input.tool_input?.command || '';

    // Match sudo only as a command (start of line/after && || ; | or $(...))
    // Not inside file paths, variable names, etc.
    const sudoCmdPattern = /(^|&&|\|\||;|\||\$\()\s*sudo\b/;
    if (!sudoCmdPattern.test(cmd) || /^\s*sudo\s+-(k|K|v)\s*$/.test(cmd)) {
      process.stdout.write(data);
      return;
    }

    const displayCmd = cmd.length > 300 ? cmd.slice(0, 300) + '...' : cmd;
    const safeDisplay = displayCmd
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');

    // Step 1: Ask user for confirmation
    try {
      execFileSync('zenity', [
        '--question',
        '--title=Claude Code: sudo confirmation',
        `--text=Claude wants to run a privileged command:\n\n<tt>${safeDisplay}</tt>\n\nYou will be prompted for your password if you allow.`,
        '--ok-label=Allow',
        '--cancel-label=Block',
        '--width=520',
        '--icon-name=dialog-warning',
        '--timeout=60',
      ], { stdio: 'pipe', timeout: 65000, env: ENV });
    } catch {
      // User clicked Block or timeout
      console.error('[Hook] BLOCKED: sudo command rejected by user');
      process.exit(2);
    }

    // Step 2: Execute with zenity askpass for password entry
    // Uses SUDO_ASKPASS with zenity only when sudo needs a password
    // Only replace sudo when used as a command, preserving any prefix (&&, ;, etc.)
    const escalatedCmd = cmd.replace(/(^|(?<=&&\s*)|(?<=\|\|\s*)|(?<=;\s*)|(?<=\|\s*)|(?<=\$\(\s*))sudo\b/, 'sudo -A');

    let stdout = '';
    let stderr = '';
    let exitCode = 0;

    try {
      stdout = execSync(escalatedCmd, {
        encoding: 'utf-8',
        timeout: 120000,
        env: { ...ENV, SUDO_ASKPASS: ASKPASS },
        shell: '/bin/bash',
        maxBuffer: 10 * 1024 * 1024,
      });
    } catch (err) {
      exitCode = err.status ?? 1;
      stdout = err.stdout ?? '';
      stderr = err.stderr ?? '';
    }

    // Step 3: Return output to Claude by blocking the original command
    // and putting the result in stderr (which Claude sees as hook feedback)
    const output = [stdout, stderr].filter(Boolean).join('\n').trim();
    const status = exitCode === 0 ? 'completed successfully' : `failed (exit ${exitCode})`;

    console.error(`[sudo-confirm] Command ${status}`);
    if (output) {
      console.error(`[sudo-confirm] Output:\n${output}`);
    }

    // Block the original command since we already executed it
    process.exit(2);
  } catch (err) {
    // Parse error or unexpected failure - pass through
    console.error(`[sudo-confirm] Hook error: ${err.message}`);
    process.stdout.write(data);
  }
});
