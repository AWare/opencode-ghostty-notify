#!/bin/bash
# Publish agent-workflow files to skill and gist.
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$HOME/.claude/skills/yolo"
GIST_ID="68eae4ca5254f3e37d942dccdf6ee045"

# --- Skill (standalone, non-plugin install) ---
echo "Publishing to skill ($SKILL_DIR)..."
mkdir -p "$SKILL_DIR"
cp "$DIR/plugins/yolo/skills/yolo/SKILL.md" "$SKILL_DIR/SKILL.md"
cp "$DIR/plugins/yolo/scripts/permission-review.sh" "$SKILL_DIR/permission-review.sh"
cp "$DIR/plugins/yolo/scripts/ghostty-notify.sh" "$SKILL_DIR/ghostty-notify.sh"
chmod +x "$SKILL_DIR/permission-review.sh" "$SKILL_DIR/ghostty-notify.sh"
echo "  Done."

# --- Gist ---
echo "Publishing to gist ($GIST_ID)..."
gh api --method PATCH "/gists/$GIST_ID" \
  -f "files[README.md][content]=$(cat "$DIR/README.md")" \
  -f "files[permission-review.sh][content]=$(cat "$DIR/plugins/yolo/scripts/permission-review.sh")" \
  -f "files[ghostty-tab-notifications.md][content]=$(cat "$DIR/ghostty-tab-notifications.md")" \
  > /dev/null
echo "  Done: https://gist.github.com/xyc/$GIST_ID"
