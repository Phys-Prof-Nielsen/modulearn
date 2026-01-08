#!/usr/bin/env bash
set -e

# Usage:
#   ./push_one.sh path/to/file "Commit message"
#
# Examples:
#   ./push_one.sh index.html "Update homepage links"
#   ./push_one.sh books/university-physics-I-D/intro.md "Fix typo in intro"

FILE_PATH="${1:-}"
COMMIT_MSG="${2:-}"

if [[ -z "$FILE_PATH" ]]; then
  echo "Usage: ./push_one.sh path/to/file \"Commit message\""
  exit 1
fi

if [[ ! -e "$FILE_PATH" ]]; then
  echo "❌ File not found: $FILE_PATH"
  exit 1
fi

# Default commit message if none provided
if [[ -z "$COMMIT_MSG" ]]; then
  COMMIT_MSG="Update $(basename "$FILE_PATH")"
fi

# Make sure we're inside a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "❌ Not inside a git repository."
  exit 1
}

# Stage ONLY that file (not everything)
git add -A -- "$FILE_PATH"

# If the file has no staged changes, exit cleanly
if git diff --cached --quiet; then
  echo "No changes staged for: $FILE_PATH"
  exit 0
fi

git commit -m "$COMMIT_MSG"
git push

echo "✅ Pushed: $FILE_PATH"

