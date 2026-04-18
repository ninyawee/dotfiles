#!/usr/bin/env bun
/**
 * PreToolUse hook: intercept sudo commands with a GNOME confirmation dialog.
 *
 * 1. Detect sudo at command position (fast substring + regex)
 * 2. zenity --question (Allow/Block)
 * 3. Execute with SUDO_ASKPASS=zenity (password only if cache expired)
 * 4. Block original (exit 2) and surface output via stderr so Claude sees it
 */

import { spawnSync } from 'child_process';

const HOME = process.env.HOME ?? '';
const ASKPASS = `${HOME}/.claude/scripts/hooks/sudo-askpass.sh`;
const ENV = { ...process.env, DISPLAY: process.env.DISPLAY || ':0' };
const STDIN_LIMIT = 1 << 20;

const SUDO_AT_CMD = /(^|&&|\|\||;|\||\$\()(\s*)sudo\b/;
const SUDO_NOOP = /^\s*sudo\s+-[kKv]\s*$/;

const HTML_ESC = { '&': '&amp;', '<': '&lt;', '>': '&gt;' };
const escapeHtml = (s) => s.replace(/[&<>]/g, (c) => HTML_ESC[c]);

async function readStdin() {
  process.stdin.setEncoding('utf8');
  let buf = '';
  for await (const chunk of process.stdin) {
    buf += chunk;
    if (buf.length >= STDIN_LIMIT) break;
  }
  return buf.slice(0, STDIN_LIMIT);
}

function passthrough(raw) {
  process.stdout.write(raw);
  process.exit(0);
}

function zenityConfirm(displayCmd) {
  const r = spawnSync('zenity', [
    '--question',
    '--title=Claude Code: sudo confirmation',
    `--text=Claude wants to run a privileged command:\n\n<tt>${escapeHtml(displayCmd)}</tt>\n\nYou will be prompted for your password if you allow.`,
    '--ok-label=Allow',
    '--cancel-label=Block',
    '--width=520',
    '--icon-name=dialog-warning',
    '--timeout=60',
  ], { stdio: 'pipe', timeout: 65_000, env: ENV });
  return r.status === 0;
}

function runEscalated(cmd) {
  const escalated = cmd.replace(SUDO_AT_CMD, (_, p1, p2) => `${p1}${p2}sudo -A`);
  const r = spawnSync(escalated, {
    encoding: 'utf-8',
    shell: '/bin/bash',
    env: { ...ENV, SUDO_ASKPASS: ASKPASS },
    timeout: 120_000,
    maxBuffer: 10 << 20,
  });
  return {
    stdout: r.stdout ?? '',
    stderr: r.stderr ?? '',
    exitCode: r.status ?? (r.error ? 1 : 0),
  };
}

async function main() {
  const raw = await readStdin();

  let input;
  try {
    input = JSON.parse(raw);
  } catch {
    passthrough(raw);
  }

  const cmd = input?.tool_input?.command ?? '';

  if (!cmd.includes('sudo') || !SUDO_AT_CMD.test(cmd) || SUDO_NOOP.test(cmd)) {
    passthrough(raw);
  }

  const displayCmd = cmd.length > 300 ? cmd.slice(0, 300) + '...' : cmd;

  if (!zenityConfirm(displayCmd)) {
    console.error('[sudo-confirm] BLOCKED: rejected by user');
    process.exit(2);
  }

  const { stdout, stderr, exitCode } = runEscalated(cmd);
  const output = [stdout, stderr].filter(Boolean).join('\n').trim();

  console.error(`[sudo-confirm] ${exitCode === 0 ? 'completed' : `failed (exit ${exitCode})`}`);
  if (output) console.error(`[sudo-confirm] Output:\n${output}`);

  process.exit(2);
}

main().catch((err) => {
  console.error(`[sudo-confirm] Hook error: ${err.message}`);
  process.exit(0);
});
