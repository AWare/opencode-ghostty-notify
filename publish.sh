#!/bin/bash
# Publish agent-workflow files to gist.
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
GIST_ID="68eae4ca5254f3e37d942dccdf6ee045"

# --- Gist ---
echo "Publishing to gist ($GIST_ID)..."
gh api --method PATCH "/gists/$GIST_ID" \
  -f "files[README.md][content]=$(cat "$DIR/README.md")" \
  -f "files[ghostty-tab-notifications.md][content]=$(cat "$DIR/ghostty-tab-notifications.md")" \
  -f "files[opencode-permissions.md][content]=$(cat "$DIR/opencode-permissions.md")" \
  > /dev/null
echo "  Done: https://gist.github.com/xyc/$GIST_ID"
