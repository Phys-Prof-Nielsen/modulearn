#!/usr/bin/env bash
set -e

# Stage everything
git add .

# If nothing changed, exit cleanly
if git diff --cached --quiet; then
  echo "No changes to push."
  exit 0
fi

# Commit with a generic message
git commit -m "Update site files"

# Push to GitHub
git push

echo "✅ All changes pushed."



