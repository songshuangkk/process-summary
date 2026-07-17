#!/bin/bash
# topology.sh — Resolve and audit the local Process Summary knowledge graph.

set -euo pipefail

TOPOLOGY_FILE=".claude/process-summary/topology.tsv"
EDGES_FILE=".claude/process-summary/edges.tsv"
SUMMARY_DIR=".claude/process-summary"

usage() { echo "Usage: $0 <resolve|neighbors|check|audit> [query|YYYY-MM-DD]" >&2; exit 2; }
[ -f "$TOPOLOGY_FILE" ] || { echo "Error: Missing $TOPOLOGY_FILE" >&2; exit 1; }
[ -f "$EDGES_FILE" ] || { echo "Error: Missing $EDGES_FILE" >&2; exit 1; }

resolve() {
    [ "$#" -eq 1 ] || usage
    query=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
    leaf=$(basename "$query" | sed 's/\.[^.]*$//')
    capability=$(printf '%s' "$leaf" | sed -E 's/(controller|appservice|service|facade|mapper|impl|listener|do|vo|dto)$//')
    awk -F '\t' -v query="$query" -v capability="$capability" '
        NR == 1 { next }
        { id=tolower($1); aliases=tolower($2); owners=tolower($3); endpoints=tolower($4); data=tolower($5); events=tolower($6); tags=tolower($7)
          haystack=id "\t" aliases "\t" owners "\t" endpoints "\t" data "\t" events "\t" tags
          score=0; reason=""
          if (id == query) { score=100; reason="exact-topic" }
          else if (index(aliases, query) || index(endpoints, query) || index(data, query)) { score=80; reason="explicit-anchor" }
          else if (length(capability) >= 3 && (index(owners, capability) || index(aliases, capability))) { score=70; reason="path-owner" }
          else if (index(owners, query)) { score=65; reason="owner" }
          else if (index(haystack, query)) { score=40; reason="tag" }
          if (score) print score "\t" $1 "\t" reason
        }
    ' "$TOPOLOGY_FILE" | sort -t $'\t' -k1,1nr -k2,2 | head -3
}

neighbors() {
    [ "$#" -eq 1 ] || usage
    awk -F '\t' -v topic="$1" 'NR > 1 { if ($1 == topic) print $3 "\t" $2 "\t" $4 "\t" $5; if ($3 == topic) print $1 "\timpacts:" $2 "\t" $4 "\t" $5 }' "$EDGES_FILE" | sort -u
}

check() {
    status=0
    duplicates=$(tail -n +2 "$TOPOLOGY_FILE" | cut -f1 | sort | uniq -d)
    [ -z "$duplicates" ] || { printf '%s\n' "$duplicates" | sed 's/^/Duplicate topology node: /' >&2; status=1; }
    while IFS= read -r topic; do
        [ -f "$SUMMARY_DIR/$topic/summary.md" ] || { echo "Missing summary: $topic" >&2; status=1; }
    done < <(tail -n +2 "$TOPOLOGY_FILE" | cut -f1)
    while IFS= read -r summary; do
        topic=${summary#"$SUMMARY_DIR"/}; topic=${topic%/summary.md}
        awk -F '\t' -v id="$topic" 'NR > 1 && $1 == id { found=1 } END { exit !found }' "$TOPOLOGY_FILE" || { echo "Missing topology node: $topic" >&2; status=1; }
    done < <(find "$SUMMARY_DIR" -name summary.md -type f | sort)
    while IFS=$'\t' read -r source relation target evidence verified_at; do
        [ "$source" = "source" ] && continue
        validate_node "$source" "edge source" || status=1
        validate_node "$target" "edge target" || status=1
        case "$relation" in calls|reads|writes|publishes|consumes|state-transition) ;; *) echo "Invalid relation: $source -> $relation -> $target" >&2; status=1 ;; esac
        validate_evidence "$source" "$target" "$evidence" "$verified_at" || status=1
    done < "$EDGES_FILE"
    exit "$status"
}

validate_node() { awk -F '\t' -v id="$1" 'NR > 1 && $1 == id { found=1 } END { exit !found }' "$TOPOLOGY_FILE" || { echo "Missing $2: $1" >&2; return 1; }; }

validate_evidence() {
    local source="$1" target="$2" evidence="$3" verified_at="$4" path anchor
    path=${evidence%%#*}; anchor=${evidence#*#}
    [ "$path" != "$evidence" ] && [ -f "$path" ] && [ -n "$anchor" ] && rg -Fq "$anchor" "$path" \
        || { echo "Invalid evidence: $source -> $target ($evidence)" >&2; return 1; }
    [[ "$verified_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "Invalid verified_at: $source -> $target ($verified_at)" >&2; return 1; }
}

audit() {
    [ "$#" -eq 1 ] || usage
    [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "Use an ISO cutoff date: YYYY-MM-DD" >&2; exit 2; }
    awk -F '\t' -v cutoff="$1" 'NR > 1 && $5 < cutoff { print $1 "\t" $2 "\t" $3 "\t" $5 }' "$EDGES_FILE"
}

case "${1:-}" in
    resolve) shift; resolve "$@" ;;
    neighbors) shift; neighbors "$@" ;;
    check) shift; check "$@" ;;
    audit) shift; audit "$@" ;;
    *) usage ;;
esac
