#!/bin/bash

# Tag production translation keys and mark deprecated ones
# Run this on every commit to main branch in GitHub Actions
# Usage: ./scripts/tag-production-translations.sh
#
# Environment variables (optional, falls back to .tolgeerc.json):
#   TOLGEE_API_KEY - Tolgee API key
#   TOLGEE_API_URL - Tolgee API URL
#   TOLGEE_PROJECT_ID - Tolgee project ID

TOLGEE_ARGS=""

if [ -n "$TOLGEE_API_KEY" ]; then
    TOLGEE_ARGS="$TOLGEE_ARGS --api-key $TOLGEE_API_KEY"
fi

if [ -n "$TOLGEE_API_URL" ]; then
    TOLGEE_ARGS="$TOLGEE_ARGS --api-url $TOLGEE_API_URL"
fi

if [ -n "$TOLGEE_PROJECT_ID" ]; then
    TOLGEE_ARGS="$TOLGEE_ARGS --project-id $TOLGEE_PROJECT_ID"
fi

echo "Tagging production translations..."
echo "============================================="

# Tag all extracted keys as production, remove draft tags
echo ""
echo "Step 1: Tag extracted keys as production, remove draft tags"
tolgee tag $TOLGEE_ARGS --filter-extracted --tag production --untag 'draft:*'

# Mark keys no longer in code as deprecated
echo ""
echo "Step 2: Mark removed keys as deprecated"
tolgee tag $TOLGEE_ARGS \
    --filter-not-extracted --filter-tag production \
    --tag deprecated --untag production

echo ""
echo "✅ Done!"
