#!/bin/bash

# Convert JSON language files to PHP (Laravel) array files
# Usage: ./scripts/convert-lang-json-to-php.sh [locale]
# Example: ./scripts/convert-lang-json-to-php.sh en-GB
# If no locale is provided, all locales will be converted

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LANG_JSON_DIR="$PROJECT_ROOT/resources/lang-json"
LANG_DIR="$PROJECT_ROOT/resources/lang"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Install it with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

# Function to convert {placeholder} to :placeholder in a string
convert_placeholders() {
    local str="$1"
    # Convert {var} to :var
    echo "$str" | sed -E 's/\{([a-zA-Z_][a-zA-Z0-9_]*)\}/:\1/g'
}

# Function to escape single quotes for PHP
escape_php_string() {
    local str="$1"
    echo "$str" | sed "s/'/\\\\'/g"
}

# Function to convert JSON value to PHP array syntax
json_to_php_array() {
    local json="$1"
    local indent="$2"
    local output=""
    local type

    type=$(echo "$json" | jq -r 'type')

    if [[ "$type" == "object" ]]; then
        output="[\n"
        local keys
        keys=$(echo "$json" | jq -r 'keys[]')
        local first=true

        while IFS= read -r key; do
            [[ -z "$key" ]] && continue

            if [[ "$first" == "true" ]]; then
                first=false
            else
                output+=",\n"
            fi

            local value
            value=$(echo "$json" | jq -c --arg k "$key" '.[$k]')
            local value_type
            value_type=$(echo "$value" | jq -r 'type')

            local escaped_key
            escaped_key=$(escape_php_string "$key")

            if [[ "$value_type" == "object" ]]; then
                local nested
                nested=$(json_to_php_array "$value" "$indent    ")
                output+="$indent    '$escaped_key' => $nested"
            elif [[ "$value_type" == "array" ]]; then
                local nested
                nested=$(json_to_php_array "$value" "$indent    ")
                output+="$indent    '$escaped_key' => $nested"
            else
                local str_value
                str_value=$(echo "$value" | jq -r '.')
                str_value=$(convert_placeholders "$str_value")
                str_value=$(escape_php_string "$str_value")
                output+="$indent    '$escaped_key' => '$str_value'"
            fi
        done <<< "$keys"

        output+=",\n$indent]"
    elif [[ "$type" == "array" ]]; then
        output="[\n"
        local length
        length=$(echo "$json" | jq 'length')

        for ((i=0; i<length; i++)); do
            if [[ $i -gt 0 ]]; then
                output+=",\n"
            fi

            local value
            value=$(echo "$json" | jq -c ".[$i]")
            local value_type
            value_type=$(echo "$value" | jq -r 'type')

            if [[ "$value_type" == "object" ]] || [[ "$value_type" == "array" ]]; then
                local nested
                nested=$(json_to_php_array "$value" "$indent    ")
                output+="$indent    $nested"
            else
                local str_value
                str_value=$(echo "$value" | jq -r '.')
                str_value=$(convert_placeholders "$str_value")
                str_value=$(escape_php_string "$str_value")
                output+="$indent    '$str_value'"
            fi
        done

        output+=",\n$indent]"
    else
        local str_value
        str_value=$(echo "$json" | jq -r '.')
        str_value=$(convert_placeholders "$str_value")
        str_value=$(escape_php_string "$str_value")
        output="'$str_value'"
    fi

    echo -e "$output"
}

# Function to process a single locale
process_locale() {
    local locale="$1"
    local json_file="$LANG_JSON_DIR/$locale.json"
    local lang_locale_dir="$LANG_DIR/$locale"

    if [[ ! -f "$json_file" ]]; then
        echo "Error: JSON file not found: $json_file"
        return 1
    fi

    echo "Processing locale: $locale"

    # Create locale directory if it doesn't exist
    mkdir -p "$lang_locale_dir"

    # Get all top-level keys (groups)
    local groups
    groups=$(jq -r 'keys[]' "$json_file")

    while IFS= read -r group; do
        [[ -z "$group" ]] && continue

        local php_file="$lang_locale_dir/$group.php"
        local group_json
        group_json=$(jq -c --arg g "$group" '.[$g]' "$json_file")

        echo "  Creating: $group.php"

        # Generate PHP file content
        {
            echo "<?php"
            echo ""
            echo "return $(json_to_php_array "$group_json" "");"
            echo ""
        } > "$php_file"

    done <<< "$groups"

    echo "Done processing: $locale"
}

# Main logic
main() {
    local locale="$1"

    if [[ -n "$locale" ]]; then
        # Process single locale
        process_locale "$locale"
    else
        # Process all locales
        echo "Processing all locales..."
        for json_file in "$LANG_JSON_DIR"/*.json; do
            [[ ! -f "$json_file" ]] && continue
            local locale_name
            locale_name=$(basename "$json_file" .json)
            process_locale "$locale_name"
            echo ""
        done
        echo "All locales processed!"
    fi
}

main "$@"
