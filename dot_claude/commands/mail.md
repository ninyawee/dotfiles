# Email Triage

Email-only triage using the chief-of-staff agent. Spawns the `@agents/chief-of-staff` agent scoped to Gmail only.

## Instructions

Use the Agent tool to spawn the `chief-of-staff` agent with the following prompt:

> Run **email-only triage**. Do NOT fetch Slack, LINE, or Messenger — only Gmail and Calendar.
>
> 1. Fetch unread email: `gog gmail search "is:unread -category:promotions -category:social" --max 20 --json`
> 2. Fetch today's calendar: `gog calendar events --today --all --max 30`
> 3. Classify every email using the 4-tier system (skip → info_only → meeting_info → action_required)
> 4. Output the briefing in the standard format, with only Email sections (omit Slack/LINE headers)
> 5. For action_required emails, generate draft replies
> 6. After any send, complete the full post-send follow-through checklist
