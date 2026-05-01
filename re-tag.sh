#!/bin/bash

set -e

TAG=$1

if [ -z "$TAG" ]; then
  echo "Usage: $0 <tag-name>"
  exit 1
fi

echo "Re-tagging current commit as '$TAG'..."

# Delete local and remote tags if they exist
git tag -d "$TAG" 2>/dev/null || true
git push origin -d "$TAG" 2>/dev/null || true

# Tag the current commit and push
git tag "$TAG"
git push origin "$TAG"

echo "Done. '$TAG' now points to $(git rev-parse --short HEAD)."