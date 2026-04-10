---
name: cron-session-target
description: Standardizes OpenClaw cron job entries to always use the current user session as target. Use when creating or editing cron jobs to ensure they deliver messages to the active user session (session:agent:main:user-session) with the correct JSON schema for ~/.openclaw/cron/jobs.json.
---

# Cron Session Target Standardization

## Overview

This skill enforces a consistent cron job format that targets the current user session (`session:agent:main:user-session`) so cron-triggered messages appear in the user's active chat. Use this skill whenever adding entries to `~/.openclaw/cron/jobs.json` manually or via automation.

## Required Format

Every cron job entry in `jobs.json` must use this exact structure:

```json
{
  "id": "uuid-v4-here",
  "agentId": "main",
  "name": "descriptive name",
  "enabled": false,
  "deleteAfterRun": false,
  "createdAtMs": 1775801246492,
  "updatedAtMs": 1775802873867,
  "schedule": {
    "kind": "every",
    "everyMs": 60000,
    "anchorMs": 1775801246492
  },
  "sessionTarget": "session:agent:main:user-session",
  "wakeMode": "now",
  "payload": {
    "kind": "agentTurn",
    "message": "your message text here"
  },
  "delivery": {
    "mode": "none"
  }
}
```

### Field Reference

| Field | Required? | Notes |
|-------|-----------|-------|
| `id` | Yes | UUID v4 string. Generate with `uuidgen` or any UUID generator. |
| `agentId` | Yes | Use `"main"` for the default agent. |
| `name` | Yes | Human-readable job name (e.g., "water reminder", "daily standup"). |
| `enabled` | Yes | Set to `true` to activate, `false` to disable. |
| `deleteAfterRun` | Yes | Set to `false` (keeps job after running). |
| `createdAtMs` | Yes | Epoch milliseconds when job was created. Use current time. |
| `updatedAtMs` | Yes | Epoch milliseconds of last update. Use current time. |
| `schedule.kind` | Yes | `"every"` for recurring, `"at"` for one-shot. |
| `schedule.everyMs` | Yes (if kind=every) | Milliseconds between runs. 60000 = 1 minute. |
| `schedule.anchorMs` | Yes | Epoch ms for the initial anchor time (usually `createdAtMs`). |
| `sessionTarget` | Yes | **Must be** `"session:agent:main:user-session"` for user session delivery. |
| `wakeMode` | Yes | `"now"` (immediate) or `"next-heartbeat"` (batched). Use `"now"` for timely messages. |
| `payload.kind` | Yes | `"agentTurn"` for agent message execution. |
| `payload.message` | Yes | The message text sent to the session. |
| `delivery.mode` | Yes | `"none"` (no external delivery) or `"announce"` (broadcast to channel). |

## Creating a Cron Job (Step by Step)

### 1. Generate a UUID

```bash
# Using uuidgen (Linux/macOS)
uuidgen

# Example output: 52be6125-16cd-4aec-9508-9e8355f10f54
```

### 2. Build the Entry

Create a new object with the template above, filling in:

- `id`: your UUID
- `name`: descriptive job name
- `createdAtMs` / `updatedAtMs` / `anchorMs`: `$(date +%s%3N)` (current time in ms)
- `schedule.everyMs`: interval in milliseconds (60000 = 1 min, 3600000 = 1 hour, 86400000 = 1 day)
- `payload.message`: the reminder/notification text

### 3. Append to `~/.openclaw/cron/jobs.json`

The file contains:

```json
{
  "version": 1,
  "jobs": [
    { /* your job object here */,
    { /* existing jobs */ }
  ]
}
```

Add your entry to the `jobs` array, keeping valid JSON syntax (commas between objects).

### 4. Restart Gateway

Reload cron jobs by restarting the gateway:

```bash
openclaw gateway restart
```

Or send SIGHUP if running in foreground.

## Common Pitfalls

- **Wrong `sessionTarget`**: Using `"main"`, `"isolated"`, or omitting it causes messages to be lost or routed incorrectly. Always use `"session:agent:main:user-session"`.
- **Using `text` instead of `message`**: Payload must contain `"message"`, not `"text"`.
- **Setting `deleteAfterRun:true`**: Job disappears after first execution. Set to `false` for recurring reminders.
- **Incorrect ms intervals**: 60000 = 1 min, not 1000×60^2. Double-check math.
- **Invalid JSON**: Trailing commas or missing braces break the entire jobs file.

## Validation

After editing `jobs.json`, validate before restart:

```bash
python3 -m json.tool ~/.openclaw/cron/jobs.json > /dev/null
```

Fix any syntax errors before reloading.

## Example: Water Reminder (1 minute)

```json
{
  "id": "52be6125-16cd-4aec-9508-9e8355f10f54",
  "agentId": "main",
  "name": "water reminder",
  "enabled": true,
  "deleteAfterRun": false,
  "createdAtMs": 1775801246492,
  "updatedAtMs": 1775802873867,
  "schedule": {
    "kind": "every",
    "everyMs": 60000,
    "anchorMs": 1775801246492
  },
  "sessionTarget": "session:agent:main:user-session",
  "wakeMode": "now",
  "payload": {
    "kind": "agentTurn",
    "message": "💧 Water break! Time to drink water."
  },
  "delivery": {
    "mode": "none"
  }
}
```

## Resources

### scripts/generate_cron_entry.py

Utility script to generate a correctly formatted cron job JSON object. Run:

```bash
python3 scripts/generate_cron_entry.py --name "reminder name" --message "text" --interval-ms 60000
```

It prints a ready-to-paste JSON object.

## Quick Reference

- **Target session always**: `"session:agent:main:user-session"`
- **Payload field**: `"message"`
- **Never delete after run**: `"deleteAfterRun": false`
- **Gateway reload required**: `openclaw gateway restart`
