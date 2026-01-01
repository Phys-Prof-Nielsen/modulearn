#!/usr/bin/env bash
set -e

# -----------------------------
# Configuration
# -----------------------------
BOOK_DIR="books/university-physics-I-D"
PUBLIC_DIR="books/university-physics-I-D/site"
COMMIT_MSG="Publish University Physics I-D book"

# -----------------------------
# Build the Jupyter Book
# -----------------------------
echo "Building Jupyter Book..."
jupyter-book build --all "$BOOK_DIR"

# -----------------------------
# Publish to public site folder
# -----------------------------
echo "Syncing built HTML to public site folder..."
rm -rf "$PUBLIC_DIR"
mkdir -p "$PUBLIC_DIR"
rsync -av --delete "$BOOK_DIR/_build/html/" "$PUBLIC_DIR/"

# -----------------------------
# Disable Jekyll (important)
# -----------------------------
touch .nojekyll
touch "$PUBLIC_DIR/.nojekyll"

# -----------------------------
# Commit and push
# -----------------------------
echo "Committing and pushing changes..."
git add .
git commit -m "$COMMIT_MSG" || echo "Nothing to commit."
git push

echo "Done. Site updated."

