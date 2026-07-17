#!/bin/bash
# capture.sh — Print changed repository-relative paths for topic routing.

set -euo pipefail

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    changed_files=$(git diff --name-only HEAD 2>/dev/null || true)
    if [ -z "$changed_files" ]; then
        changed_files=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || true)
    fi
    if [ -n "$changed_files" ]; then
        printf '%s\n' "$changed_files"
        exit 0
    fi
fi

find . -type f \
    \( -name '*.java' -o -name '*.xml' -o -name '*.yml' -o -name '*.yaml' \
       -o -name '*.sql' -o -name '*.ts' -o -name '*.tsx' \) \
    -mtime -1 ! -path './.git/*' ! -path './node_modules/*' \
    | sed 's#^./##' | head -20
