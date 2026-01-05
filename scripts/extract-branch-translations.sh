#!/bin/bash

# Extract translation keys from files changed in the current branch
# Usage: ./scripts/extract-branch-translations.sh [base-branch]

BASE_BRANCH=${1:-main}
BRANCH_NAME=$(node -p "require('./branch.json').branchName" 2>/dev/null || git branch --show-current)
OUTPUT_FILE="resources/lang-json/draft-${BRANCH_NAME}.json"

echo "Extracting translations from branch: $BRANCH_NAME"
echo "Comparing against: $BASE_BRANCH"
echo "Output file: $OUTPUT_FILE"
echo "============================================="

# Get changed files (Vue, JS, PHP) - exclude node_modules and vendor
CHANGED_FILES=$(git diff --name-only "$BASE_BRANCH"...HEAD 2>/dev/null || git diff --name-only "$BASE_BRANCH" HEAD)
CHANGED_FILES=$(echo "$CHANGED_FILES" | grep -v '^node_modules/' | grep -v '^vendor/' || true)
VUE_JS_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(vue|js)$' || true)
PHP_FILES=$(echo "$CHANGED_FILES" | grep -E '\.php$' || true)

echo ""
echo "Changed files:"
echo "$CHANGED_FILES"
echo ""

# Extract Vue/JS keys: $t('key'), $tc('key'), t('key')
VUE_KEYS=""
if [ -n "$VUE_JS_FILES" ]; then
    for file in $VUE_JS_FILES; do
        if [ -f "$file" ]; then
            KEYS=$(grep -oE "\\\$t[c]?\(['\"][^'\"]+['\"]\)|[^a-zA-Z]t\(['\"][^'\"]+['\"]\)" "$file" 2>/dev/null | \
                sed -E "s/.*\(['\"]([^'\"]+)['\"]\)/\1/" | sort -u)
            VUE_KEYS="$VUE_KEYS $KEYS"
        fi
    done
fi

# Extract PHP keys: __('mixpost::key')
PHP_KEYS=""
if [ -n "$PHP_FILES" ]; then
    for file in $PHP_FILES; do
        if [ -f "$file" ]; then
            KEYS=$(grep -oE "__\(['\"]mixpost::[^'\"]+['\"]\)" "$file" 2>/dev/null | \
                sed -E "s/__\(['\"]mixpost::([^'\"]+)['\"]\)/\1/" | sort -u)
            PHP_KEYS="$PHP_KEYS $KEYS"
        fi
    done
fi

# Combine and deduplicate keys
ALL_KEYS=$(echo "$VUE_KEYS $PHP_KEYS" | tr ' ' '\n' | grep -v '^$' | sort -u)

if [ -z "$ALL_KEYS" ]; then
    echo "No translation keys found in changed files."
    exit 0
fi

echo "Found translation keys:"
echo "$ALL_KEYS"
echo ""

# Generate JSON file
echo "{" > "$OUTPUT_FILE"
echo "  \"_meta\": {" >> "$OUTPUT_FILE"
echo "    \"branch\": \"$BRANCH_NAME\"," >> "$OUTPUT_FILE"
echo "    \"extracted_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"
echo "  \"keys\": [" >> "$OUTPUT_FILE"

FIRST=true
for KEY in $ALL_KEYS; do
    if [ "$FIRST" = true ]; then
        echo "    \"$KEY\"" >> "$OUTPUT_FILE"
        FIRST=false
    else
        echo "    ,\"$KEY\"" >> "$OUTPUT_FILE"
    fi
done

echo "  ]" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

echo "Keys saved to: $OUTPUT_FILE"
echo ""
echo "To tag these keys in Tolgee, run:"
echo "  npm run tolgee:tag-draft"
