#!/bin/bash

# Tag translation keys from the branch localization keys file
# Usage: ./scripts/tag-branch-translations.sh

BRANCH_NAME=$(git branch --show-current)
TAG="draft:${BRANCH_NAME}"
KEYS_FILE="branch-localization-keys.json"

echo "Tagging translations for branch: $BRANCH_NAME"
echo "Tag: $TAG"
echo "Keys file: $KEYS_FILE"
echo "============================================="

if [ ! -f "$KEYS_FILE" ]; then
    echo "Keys file not found: $KEYS_FILE"
    exit 1
fi

# Show keys to be tagged
echo ""
echo "Keys to tag:"
cat "$KEYS_FILE"
echo ""

# Tag keys in Tolgee using custom extractor
tolgee tag --filter-extracted --tag "$TAG" \
    --patterns "$KEYS_FILE" \
    --extractor ./tolgee-extractors/branch-tolgee-keys-extractor.cjs
