# agent-workflow

Claude Code plugins for agent workflows.

## Plugins

### ghostty-notifications

Ghostty terminal notifications for Claude Code events. Sends a bell (dock bounce, tab indicator) and OSC 777 desktop notification when Claude needs attention.

Fires on: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`.

See [ghostty-tab-notifications.md](ghostty-tab-notifications.md) for the full writeup on how this works and what was tried.

### yolo

Auto-handle Claude Code permission requests. Two modes:

- **review** (default) — route each request to Claude Opus 4.5 for security evaluation. Safe operations get auto-approved, dangerous ones fall through to the permission dialog.
- **approve-all** — auto-approve everything with zero latency.

Includes a `/yolo` skill for toggling modes.

## Install as plugins

Add the marketplace and install:

```
/plugin marketplace add recursechat/agent-workflow
/plugin install ghostty-notifications@recursechat-agent-workflow
/plugin install yolo@recursechat-agent-workflow
```

## Install manually (without marketplace)

### Ghostty notifications

Add to `~/.claude/settings.json`:

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

Copy `plugins/ghostty-notifications/scripts/ghostty-notify.sh` to `~/.claude/hooks/` and make it executable.

### Permission review

Copy `plugins/yolo/scripts/permission-review.sh` and `ghostty-notify.sh` to `.claude/hooks/` in your project (or `~/.claude/hooks/` for global). Make executable.

Add to `.claude/settings.local.json` (or `~/.claude/settings.json` for global):

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/permission-review.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## Notes

- Restart your session after installing/editing hooks -- they're snapshotted at startup
- `PermissionRequest` hooks don't fire in non-interactive mode (`-p`)
- Use `claude --debug` and `Ctrl+O` (verbose mode) to see hook execution
- Check `/hooks` in Claude Code to verify hooks are loaded
- Only `type: "command"` hooks work with `PermissionRequest` (prompt hooks don't fire for this event)
