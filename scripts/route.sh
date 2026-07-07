#!/bin/bash
# route.sh — Map changed files to module-level CLAUDE.md targets.

set -euo pipefail

collect_input() {
    if [ "$#" -gt 0 ]; then
        printf '%s\n' "$@"
    else
        cat
    fi
}

topic_from_root() {
    local root="$1"
    case "$root" in
        shengchuang-module-*) echo "${root#shengchuang-module-}" ;;
        packages/*) echo "$(printf '%s' "$root" | tr '/' '-')" ;;
        apps/*) echo "$(printf '%s' "$root" | tr '/' '-')" ;;
        *) echo "$root" ;;
    esac
}

root_from_file() {
    local file="$1"
    local first second
    first=$(printf '%s\n' "$file" | cut -d/ -f1)
    second=$(printf '%s\n' "$file" | cut -d/ -f2)

    case "$first" in
        ""|"." ) echo "." ;;
        shengchuang-module-*) echo "$first" ;;
        packages|apps)
            if [ -n "$second" ] && [ "$second" != "$file" ]; then
                echo "$first/$second"
            else
                echo "$first"
            fi
            ;;
        src|lib|server|client|backend|frontend)
            echo "$first"
            ;;
        *)
            echo "$first"
            ;;
    esac
}

collect_input "$@" \
    | sed 's#^\./##' \
    | grep -v '^$' \
    | while IFS= read -r file; do
        root=$(root_from_file "$file")
        topic=$(topic_from_root "$root")
        if [ "$root" = "." ]; then
            module_claude="CLAUDE.md"
        else
            module_claude="$root/CLAUDE.md"
        fi
        summary=".claude/process-summary/$topic/summary.md"
        printf '%s\t%s\t%s\t%s\n' "$file" "$root" "$module_claude" "$summary"
    done
