# opencode-ghostty-notify

Ghostty terminal notifications for opencode. Sends a bell (dock bounce, tab indicator) and OSC 777 desktop notification when the opencode session goes idle.

See [ghostty-tab-notifications.md](ghostty-tab-notifications.md) for the full writeup on how this works and what was tried.

## Install

Copy both files to `.opencode/plugins/` in your project, or `~/.config/opencode/plugins/` for global use:

```bash
cp plugins/ghostty-notifications/ghostty-notify.ts .opencode/plugins/
cp plugins/ghostty-notifications/ghostty-notify.sh .opencode/plugins/
chmod +x .opencode/plugins/ghostty-notify.sh
```

opencode automatically loads all `.ts` and `.js` files in the plugins directory.

## How it works

The plugin hooks into the `session.idle` event, which fires when the agent finishes responding. It calls `ghostty-notify.sh`, which walks up the process tree to find the ancestor TTY (since plugins run without a controlling terminal) and writes the OSC 777 escape sequence and bell directly to that TTY device.

## Notes

- Restart opencode after adding plugins
- Only fires on `session.idle` (agent done) — no permission prompts or other events in opencode's plugin API
- Requires Ghostty with `desktop-notifications = true` in your Ghostty config for banner notifications; bell alone works without it
