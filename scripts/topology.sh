#!/bin/bash
# topology.sh — Resolve and validate the local Process Summary topic graph.

set -euo pipefail

TOPOLOGY_FILE=".claude/process-summary/topology.tsv"
SUMMARY_DIR=".claude/process-summary"

usage() { echo "Usage: $0 <resolve|neighbors|check> [query]" >&2; exit 2; }
[ -f "$TOPOLOGY_FILE" ] || { echo "Error: Missing $TOPOLOGY_FILE" >&2; exit 1; }

resolve() {
    [ "$#" -eq 1 ] || usage
    query=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
    leaf=$(basename "$query" | sed 's/\.[^.]*$//')
    capability=$(printf '%s' "$leaf" | sed -E 's/(controller|appservice|service|facade|mapper|impl|listener|do|vo|dto)$//')
    awk -F '\t' -v query="$query" -v capability="$capability" '
        NR == 1 { next }
        {
            id=tolower($1); aliases=tolower($2); owners=tolower($3); endpoints=tolower($4)
            data=tolower($5); events=tolower($6); tags=tolower($8)
            haystack=id "\t" aliases "\t" owners "\t" endpoints "\t" data "\t" events "\t" tags
            score=0; reason=""
            if (id == query) { score=100; reason="exact-topic" }
            else if (index(aliases, query) > 0 || index(endpoints, query) > 0 || index(data, query) > 0) { score=80; reason="explicit-alias" }
            else if (length(capability) >= 3 && (index(owners, capability) > 0 || index(aliases, capability) > 0)) { score=70; reason="path-owner" }
            else if (index(owners, query) > 0) { score=65; reason="owner" }
            else if (index(haystack, query) > 0) { score=40; reason="tag" }
            if (score > 0) print score "\t" $1 "\t" reason
        }
    ' "$TOPOLOGY_FILE" | sort -t $'\t' -k1,1nr -k2,2 | head -3
}

neighbors() {
    [ "$#" -eq 1 ] || usage
    awk -F '\t' -v topic="$1" '
        NR == 1 { next }
        $1 == topic { count=split($7, deps, ";"); for (i = 1; i <= count; i++) if (deps[i] != "") print deps[i] "\tdepends-on" }
        index(";" $7 ";", ";" topic ";") > 0 { print $1 "\timpacts" }
    ' "$TOPOLOGY_FILE" | sort -u
}

check() {
    status=0
    duplicates=$(tail -n +2 "$TOPOLOGY_FILE" | cut -f1 | sort | uniq -d)
    if [ -n "$duplicates" ]; then printf '%s\n' "$duplicates" | sed 's/^/Duplicate topology node: /' >&2; status=1; fi
    while IFS= read -r topic; do
        [ -f "$SUMMARY_DIR/$topic/summary.md" ] || { echo "Missing summary: $topic" >&2; status=1; }
    done < <(tail -n +2 "$TOPOLOGY_FILE" | cut -f1)
    while IFS= read -r summary; do
        topic=${summary#"$SUMMARY_DIR"/}; topic=${topic%/summary.md}
        awk -F '\t' -v id="$topic" 'NR > 1 && $1 == id { found=1 } END { exit !found }' "$TOPOLOGY_FILE" || { echo "Missing topology node: $topic" >&2; status=1; }
    done < <(find "$SUMMARY_DIR" -name summary.md -type f | sort)
    dangling=$(awk -F '\t' 'NR == 1 { next } { ids[$1]=1; sources[++count]=$1; dependencies[count]=$7 } END { for (i=1; i<=count; i++) { split(dependencies[i], deps, ";"); for (j in deps) if (deps[j] != "" && !ids[deps[j]]) print sources[i] " -> " deps[j] } }' "$TOPOLOGY_FILE")
    if [ -n "$dangling" ]; then printf '%s\n' "$dangling" | sed 's/^/Dangling dependency: /' >&2; status=1; fi
    exit "$status"
}

case "${1:-}" in
    resolve) shift; resolve "$@" ;;
    neighbors) shift; neighbors "$@" ;;
    check) shift; check "$@" ;;
    *) usage ;;
esac
