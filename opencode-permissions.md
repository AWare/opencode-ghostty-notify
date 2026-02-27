# opencode Permission Modes

Configure opencode to auto-approve, selectively approve, or prompt for permission on tool use. This is the opencode equivalent of the Claude Code `yolo` plugin.

## How It Works

opencode's `permission` field in `opencode.json` controls whether tools run automatically, require approval, or are blocked. Rules are evaluated by pattern match, with the last matching rule winning.

Three outcomes per rule:
- `"allow"` — executes without approval
- `"ask"` — prompts you for approval
- `"deny"` — blocks the action

## Modes

### approve-all

Auto-approve everything. opencode runs all tools without asking.

```json
{
  "permission": "allow"
}
```

This is also the opencode default — if you have no `permission` key, all tools are allowed.

### approve-websearch

Auto-approve web fetches and searches; ask for everything else (writes, bash, etc.).

```json
{
  "permission": {
    "*": "ask",
    "webfetch": "allow",
    "websearch": "allow"
  }
}
```

### review (safe default)

Prompt for every tool use. You review and approve each action manually.

```json
{
  "permission": "ask"
}
```

### off (default behavior)

Remove the `permission` key entirely (or don't add one). opencode defaults to allowing all tools.

### Granular bash control

For fine-grained control over shell commands:

```json
{
  "permission": {
    "*": "ask",
    "bash": {
      "*": "ask",
      "git *": "allow",
      "npm run *": "allow",
      "rm *": "deny"
    },
    "read": "allow",
    "grep": "allow",
    "glob": "allow",
    "list": "allow"
  }
}
```

## Configuration File

Settings live in `opencode.json` at the project root, or `~/.config/opencode/opencode.json` globally.

Project-level config overrides global config.

## Built-in Tool Names

Use these names in `permission` rules:

| Tool | What it does |
|------|--------------|
| `bash` | Execute shell commands |
| `edit` | Modify existing files |
| `write` | Create or overwrite files |
| `read` | Read file contents |
| `grep` | Search with regex |
| `glob` | Find files by pattern |
| `list` | List directory contents |
| `webfetch` | Fetch web content |
| `websearch` | Search the web |
| `patch` | Apply patch files |
| `question` | Ask user questions |

MCP server tools use the pattern `servername_toolname` and can be matched with wildcards like `myserver_*`.

## Notes

- Changes to `opencode.json` take effect immediately — no session restart needed
- In non-interactive mode (`opencode run`), all permissions are auto-approved
- Combine project-level and global config: project settings override global ones
- See [opencode permissions docs](https://opencode.ai/docs/permissions/) for full details
