#!/bin/bash
# Publish to gist.
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
GIST_ID="68eae4ca5254f3e37d942dccdf6ee045"

echo "Publishing to gist ($GIST_ID)..."
gh api --method PATCH "/gists/$GIST_ID" \
  -f "files[README.md][content]=$(cat "$DIR/README.md")" \
  -f "files[ghostty-tab-notifications.md][content]=$(cat "$DIR/ghostty-tab-notifications.md")" \
  -f "files[ghostty-notify.sh][content]=$(cat "$DIR/plugins/ghostty-notifications/ghostty-notify.sh")" \
  -f "files[ghostty-notify.ts][content]=$(cat "$DIR/plugins/ghostty-notifications/ghostty-notify.ts")" \
  > /dev/null
echo "  Done: https://gist.github.com/xyc/$GIST_ID"
