#!/bin/bash

# Create branch.json with current git branch name
# Output is written to the project root directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "{\"branchName\": \"$(git rev-parse --abbrev-ref HEAD)\"}" > "$PROJECT_ROOT/branch.json"
