#!/bin/bash
# retrieve.sh — Resolve a v3 summary through the explicit topic topology.

set -euo pipefail

SUMMARY_DIR=".claude/process-summary"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TOPOLOGY_SCRIPT="$SCRIPT_DIR/topology.sh"
MAX_RESULTS=3

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
    echo "Usage: $0 <topic | API | table | event | owner token>" >&2
    exit 2
fi

matches=""
add_topic() {
    local topic="$1"
    [ -f "$SUMMARY_DIR/$topic/summary.md" ] || return
    if ! printf '%s\n' "$matches" | grep -Fxq "$topic"; then
        matches="${matches}${matches:+
}$topic"
    fi
}

primary=""
route=""
if [ -f "$TOPOLOGY_SCRIPT" ]; then
    resolved=$(bash "$TOPOLOGY_SCRIPT" resolve "$1")
    if [ -n "$resolved" ]; then
        primary=$(printf '%s\n' "$resolved" | sed -n '1s/^[^[:space:]]*[[:space:]]*\([^[:space:]]*\).*/\1/p')
        route=$(printf '%s\n' "$resolved" | sed -n '1s/^[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*//p')
        add_topic "$primary"
        while IFS=$'\t' read -r neighbor relation; do
            add_topic "$neighbor"
            [ "$(printf '%s\n' "$matches" | wc -l | tr -d ' ')" -ge "$MAX_RESULTS" ] && break
        done < <(bash "$TOPOLOGY_SCRIPT" neighbors "$primary")
    fi
fi

if [ -z "$matches" ] && [ -f "$SUMMARY_DIR/$1/summary.md" ]; then
    add_topic "$1"
    route="direct-topic"
fi

if [ -z "$matches" ]; then
    while IFS= read -r file; do
        add_topic "${file#"$SUMMARY_DIR"/}"
        [ "$(printf '%s\n' "$matches" | wc -l | tr -d ' ')" -ge "$MAX_RESULTS" ] && break
    done < <(rg -il --fixed-strings --glob 'summary.md' "$1" "$SUMMARY_DIR" | sed "s#^$SUMMARY_DIR/##; s#/summary.md\$##" | sort)
    route="summary-text-fallback"
fi

if [ -z "$matches" ]; then
    echo "No topic matched: $1"
    exit 0
fi

print_section() {
    local file="$1" heading="$2"
    awk -v heading="$heading" '$0 == "## " heading { found=1; next } found && /^## / { exit } found { print }' "$file"
}

echo "Topology route: ${primary:-unknown} (${route:-fallback})"
while IFS= read -r topic; do
    [ -z "$topic" ] && continue
    file="$SUMMARY_DIR/$topic/summary.md"
    echo "=============================="
    echo "Topic: $topic"
    echo "=============================="
    for heading in '现状' '技术决策' '注意事项' '相关模块'; do
        echo ""
        echo "--- $heading ---"
        print_section "$file" "$heading"
    done
    echo ""
done <<EOF
$matches
EOF
