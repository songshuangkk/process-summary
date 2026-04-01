#!/bin/bash
# retrieve.sh — Search module summaries by keyword (directory name + content)

set -euo pipefail

KEYWORD=$(echo "$1" | tr '[:upper:]' '[:lower:]')
SUMMARY_DIR=".claude/process-summary"

if [ ! -d "$SUMMARY_DIR" ]; then
    echo "Error: No summaries found at $SUMMARY_DIR"
    exit 1
fi

echo "=== Directory matches ==="
DIR_MATCHES=$(ls "$SUMMARY_DIR" 2>/dev/null | grep -i "$KEYWORD" || true)
if [ -n "$DIR_MATCHES" ]; then
    echo "$DIR_MATCHES"
else
    echo "(none)"
fi

echo ""
echo "=== Content matches ==="
CONTENT_MATCHES=$(grep -ril "$KEYWORD" "$SUMMARY_DIR" 2>/dev/null || true)
if [ -n "$CONTENT_MATCHES" ]; then
    echo "$CONTENT_MATCHES"
else
    echo "(none)"
fi
