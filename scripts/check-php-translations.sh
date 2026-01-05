#!/bin/bash

# Extract translation keys from PHP files and check against language files
# Usage: ./scripts/check-php-translations.sh [locale]

LOCALE=${1:-en}
LANG_DIR="resources/lang/$LOCALE"
PHP_DIR="files"

echo "Checking PHP translations for locale: $LOCALE"
echo "============================================="

# Extract all translation keys from PHP files (works on macOS and Linux)
KEYS=$(grep -rho "__('mixpost::[^']*')\|__(\"mixpost::[^\"]*\")" "$PHP_DIR" --include="*.php" 2>/dev/null | \
    sed -E "s/__\(['\"]mixpost::([^'\"]+)['\"]\)/\1/" | \
    sort -u)

if [ -z "$KEYS" ]; then
    echo "No translation keys found in PHP files."
    exit 0
fi

echo ""
echo "Found translation keys:"
echo "$KEYS"
echo ""

# Check if language directory exists
if [ ! -d "$LANG_DIR" ]; then
    echo "WARNING: Language directory '$LANG_DIR' does not exist!"
    echo ""
    echo "Missing keys (all):"
    echo "$KEYS"
    exit 1
fi

MISSING=0

echo "Missing keys:"
echo "-------------"

for KEY in $KEYS; do
    # Extract file and key parts (e.g., rules.remote_file.invalid_url -> rules file, remote_file.invalid_url key)
    FILE=$(echo "$KEY" | cut -d'.' -f1)
    LANG_FILE="$LANG_DIR/$FILE.php"

    if [ ! -f "$LANG_FILE" ]; then
        echo "  $KEY (file '$LANG_FILE' not found)"
        MISSING=1
    fi
done

if [ $MISSING -eq 0 ]; then
    echo "  None - all translation files exist!"
fi

echo ""
