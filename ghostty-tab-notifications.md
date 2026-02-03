# Ghostty Tab Notifications for Claude Code Hooks

## Goal

Get Ghostty to visually notify (bell emoji in tab, dock bounce, desktop notification banner) when Claude Code needs attention -- permission prompts, idle input, auth, or elicitation dialogs.

## Ghostty's notification mechanisms

Ghostty supports several programmatic notification methods via escape sequences:

| Mechanism | Escape sequence | Effect |
|:----------|:----------------|:-------|
| Bell (BEL) | `\a` or `\007` | Dock bounce + bell emoji in tab title (macOS) |
| OSC 777 | `\033]777;notify;TITLE;BODY\007` | Desktop notification banner |
| OSC 9 | `\033]9;BODY\007` | Desktop notification (body only) |
| OSC 9;4 | `\033]9;4;1;PERCENT\007` | Progress bar at top of terminal |
| OSC 0/2 | `\033]0;TITLE\007` | Change tab/window title |

Ghostty config options: `bell-features` controls bell behavior (`title`, `attention`, `audio`, `system`, `border`). `desktop-notifications = true` enables OSC 9/777.

## Claude Code hooks

Claude Code has a `Notification` hook event that fires when it sends notifications. Matchers:

- `permission_prompt` -- Claude needs permission approval
- `idle_prompt` -- Claude is idle, waiting for input
- `auth_success` -- authentication completed
- `elicitation_dialog` -- Claude is asking a question

There's also a `Stop` hook (fires when Claude finishes responding) which is useful for "task complete" notifications.

Hooks are configured in `.claude/settings.local.json` (project-local, gitignored) or `~/.claude/settings.json` (global).

## What didn't work

### Attempt 1: printf to stdout

```json
{
  "type": "command",
  "command": "printf '\\033]777;notify;Claude Code;Needs permission\\007' && printf '\\a'"
}
```

**Result:** No notification. Hook stdout is captured by Claude Code for JSON parsing -- the escape sequences never reach the terminal.

### Attempt 2: printf to /dev/tty

```json
{
  "type": "command",
  "command": "printf '\\033]777;notify;Claude Code;Needs permission\\007' > /dev/tty && printf '\\a' > /dev/tty"
}
```

**Result:** Error: `device not configured: /dev/tty`. Hook commands run as detached subprocesses with no controlling terminal, so `/dev/tty` doesn't exist.

### Attempt 3: osascript (macOS native notifications)

```json
{
  "type": "command",
  "command": "osascript -e 'display notification \"Needs permission\" with title \"Claude Code\" sound name \"Funk\"'"
}
```

**Result:** This produces a macOS notification, but it's attributed to "Script Editor" (or whichever app runs osascript), not Ghostty. It won't trigger any Ghostty tab indicators (bell emoji, dock badge) because Ghostty doesn't know about it.

## What works: walk the process tree to find the TTY

Hook subprocesses don't have a TTY, but their ancestor (the shell running inside Ghostty) does. Walk up the process tree via `ps -o ppid=` until you find a process with a real TTY device, then write escape sequences directly to that `/dev/ttysXXX`.

### The script: `~/.claude/hooks/ghostty-notify.sh`

```bash
#!/bin/bash
# Sends a bell + OSC 777 notification to the parent Ghostty terminal.
# Walks up the process tree to find the TTY since hooks have no controlling terminal.

MSG="${1:-Notification}"

# Walk up process tree to find an ancestor with a real TTY
PID=$$
TTY=""
while [ "$PID" != "1" ] && [ -n "$PID" ]; do
  T=$(ps -o tty= -p "$PID" 2>/dev/null | tr -d ' ')
  if [ -n "$T" ] && [ "$T" != "??" ] && [ -e "/dev/$T" ]; then
    TTY="/dev/$T"
    break
  fi
  PID=$(ps -o ppid= -p "$PID" 2>/dev/null | tr -d ' ')
done

if [ -z "$TTY" ]; then
  exit 0
fi

# Send OSC 777 desktop notification + bell to the Ghostty terminal
printf '\033]777;notify;Claude Code;%s\007' "$MSG" > "$TTY"
printf '\a' > "$TTY"

exit 0
```

### Global hook configuration: `~/.claude/settings.json`

Install globally so notifications work in every project:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/ghostty-notify.sh 'Needs permission'"
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/ghostty-notify.sh 'Waiting for input'"
          }
        ]
      },
      {
        "matcher": "auth_success",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/ghostty-notify.sh 'Auth successful'"
          }
        ]
      },
      {
        "matcher": "elicitation_dialog",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/ghostty-notify.sh 'Asking a question'"
          }
        ]
      }
    ]
  }
}
```

### Alternative: per-project configuration

If you only want notifications in a specific project, use `.claude/settings.local.json` (gitignored) or `.claude/settings.json` (committable) and reference the script via `$CLAUDE_PROJECT_DIR`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/ghostty-notify.sh 'Needs permission'"
          }
        ]
      }
    ]
  }
}
```

## Notes

- Hooks are snapshotted at session startup. After editing settings, restart the Claude Code session.
- The process tree walk is: hook subprocess -> Claude Code -> node -> shell (in Ghostty, has TTY).
- Ghostty must have `desktop-notifications = true` (the default) for OSC 777 to work.
- Bell behavior is controlled by `bell-features` in Ghostty config. macOS defaults: dock bounce + bell emoji in tab title.
- You could extend this with a `Stop` hook for "task complete" notifications, or `SessionStart` to set an indeterminate progress bar (`OSC 9;4;3;0`).
- Global hooks (`~/.claude/settings.json`) apply to all projects. Project hooks (`.claude/settings.local.json`) are scoped to one repo.
- `$CLAUDE_PROJECT_DIR` is only available in project-scoped hooks; for global hooks use `~/.claude/hooks/` directly.

## References

- [Ghostty bell docs](https://ghostty.org/docs/vt/control/bel)
- [Ghostty config reference (bell-features, desktop-notifications)](https://ghostty.org/docs/config/reference)
- [Ghostty 1.2.0 release notes](https://ghostty.org/docs/install/release-notes/1-2-0)
- [OSC 9;4 progress bars](https://rockorager.dev/misc/osc-9-4-progress-bars/)
- [Claude Code hooks reference](https://code.claude.com/docs/en/hooks)
- [Claude Code hooks guide](https://code.claude.com/docs/en/hooks-guide)
