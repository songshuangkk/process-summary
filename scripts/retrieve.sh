#!/bin/bash
# retrieve.sh — Search hierarchical Claude Code memory by keyword.

set -euo pipefail

KEYWORD=$(echo "${1:-}" | tr '[:upper:]' '[:lower:]')
SUMMARY_DIR=".claude/process-summary"

if [ -z "$KEYWORD" ]; then
    echo "Usage: scripts/retrieve.sh <keyword>" >&2
    exit 1
fi

if [ ! -d "$SUMMARY_DIR" ]; then
    echo "Error: No summaries found at $SUMMARY_DIR"
    exit 1
fi

# --- Find matching module CLAUDE indexes ---
MODULE_INDEXES=$(find . -path "./*/CLAUDE.md" -type f 2>/dev/null \
    ! -path "./.git/*" \
    ! -path "./.claude/*" \
    | while IFS= read -r f; do
        if printf '%s\n' "$f" | tr '[:upper:]' '[:lower:]' | grep -q "$KEYWORD" \
            || grep -qi "$KEYWORD" "$f"; then
            printf '%s\n' "$f"
        fi
    done || true)

if [ -n "$MODULE_INDEXES" ]; then
    echo "Matched module CLAUDE.md indexes:"
    echo "$MODULE_INDEXES" | sed 's/^/  - /'
    echo ""
fi

# --- Find matching cold summaries ---
DIR_MATCHES=$(ls "$SUMMARY_DIR" 2>/dev/null | grep -i "$KEYWORD" || true)
CONTENT_MATCHES=$(grep -ril "$KEYWORD" "$SUMMARY_DIR" 2>/dev/null | grep "summary.md" || true)

ALL_FILES=""
for dir in $DIR_MATCHES; do
    f="$SUMMARY_DIR/$dir/summary.md"
    [ -f "$f" ] && ALL_FILES="$ALL_FILES $f"
done
for f in $CONTENT_MATCHES; do
    ALL_FILES="$ALL_FILES $f"
done
ALL_FILES=$(echo "$ALL_FILES" | tr ' ' '\n' | sort -u | grep -v '^$' || true)

if [ -z "$ALL_FILES" ]; then
    echo "No summaries found matching: $KEYWORD"
    exit 0
fi

for FILE in $ALL_FILES; do
    MODULE=$(basename "$(dirname "$FILE")")
    echo "=============================="
    echo "Summary: $MODULE"
    echo "File: $FILE"
    echo "=============================="

    echo ""
    echo "--- Overview ---"
    awk '/^## Overview/{found=1; next} found && /^##/{exit} found{print}' "$FILE"

    echo ""
    echo "--- Dependencies ---"
    awk '/^## Dependencies/{found=1; next} found && /^##/{exit} found{print}' "$FILE"

    echo ""
    echo "--- Watch Out (all historical) ---"
    grep "^\*\*Watch Out\*\*:" "$FILE" | sed 's/\*\*Watch Out\*\*:/⚠️ /' || echo "(none)"

    echo ""
done
