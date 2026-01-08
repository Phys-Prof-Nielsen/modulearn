#!/usr/bin/env bash
set -e

# Usage:
#   ./publish-book.sh BOOKNAME "Commit message"
#
# Example:
#   ./publish-book.sh university-physics-II-D "Publish Phase D updates"

BOOKNAME="${1:-}"
COMMIT_MSG="${2:-}"

if [[ -z "$BOOKNAME" ]]; then
  echo 'Usage: ./publish-book.sh BOOKNAME "Commit message"'
  echo 'Example: ./publish-book.sh university-physics-II-D "Publish updates"'
  exit 1
fi

# Default commit message if not provided
if [[ -z "$COMMIT_MSG" ]]; then
  COMMIT_MSG="Publish ${BOOKNAME}"
fi

BOOK_DIR="books/${BOOKNAME}"
PUBLIC_DIR="${BOOK_DIR}/site"

# Sanity checks
if [[ ! -d "$BOOK_DIR" ]]; then
  echo "❌ Book directory not found: $BOOK_DIR"
  exit 1
fi

if [[ ! -f "$BOOK_DIR/_config.yml" ]]; then
  echo "❌ Not a Jupyter Book folder (missing _config.yml): $BOOK_DIR"
  exit 1
fi

# -----------------------------
# Build the Jupyter Book (abort if fails)
# -----------------------------
echo "Building Jupyter Book in: $BOOK_DIR"
if ! jupyter-book build "$BOOK_DIR"; then
#if ! jupyter-book build --all "$BOOK_DIR"; then
  echo "❌ Build failed. Not publishing."
  exit 1
fi

# -----------------------------
# Publish to public site folder
# -----------------------------
echo "Syncing built HTML to: $PUBLIC_DIR"
rm -rf "$PUBLIC_DIR"
mkdir -p "$PUBLIC_DIR"
rsync -av --delete "$BOOK_DIR/_build/html/" "$PUBLIC_DIR/"

# Disable Jekyll so _static etc. are served (repo root + book site)
touch .nojekyll
touch "$PUBLIC_DIR/.nojekyll"

# -----------------------------
# Commit ONLY the published book output (+ .nojekyll)
# -----------------------------
#echo "Staging only published output..."
#git add -A "$PUBLIC_DIR" .nojekyll
echo "Staging entire book folder..."
git add -A "$BOOK_DIR" .nojekyll

# If nothing changed, don't create an empty commit
if git diff --cached --quiet; then
  echo "No published changes to commit."
  exit 0
fi

echo "Committing and pushing..."
git commit -m "$COMMIT_MSG"
git push

echo "✅ Done. Published output updated for: $BOOKNAME"