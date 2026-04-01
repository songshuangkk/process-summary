#!/bin/bash
# capture.sh — Identify changed files for context capture

set -euo pipefail

# Priority 1: Latest commit stats
CHANGES=$(git log -1 --stat 2>/dev/null)

# Priority 2: Uncommitted changes
if [ -z "$CHANGES" ]; then
    CHANGES=$(git diff HEAD --stat 2>/dev/null)
fi

# Priority 3: Fall back to recently modified files
if [ -z "$CHANGES" ]; then
    CHANGES=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rs" -o -name "*.tsx" -o -name "*.jsx" \) -mtime -1 | grep -v node_modules | grep -v '.git' | head -20)
fi

echo "$CHANGES"
