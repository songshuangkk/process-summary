#!/bin/bash
# Priority 1: Check for recent commits
git log -1 --stat 2>/dev/null || \
# Priority 2: Check staged + unstaged changes
git diff HEAD 2>/dev/null || \
# Priority 3: Fallback to recent modifications (last 24 hours)
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.java" -o -name "*.go" \) -mtime -1 2>/dev/null | grep -v node_modules | head -20
