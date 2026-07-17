#!/bin/bash
# maintain.sh — Compact only the v3 change-history tail of one summary.

set -euo pipefail

FILE=${1:?"Usage: $0 <summary.md>"}
MAX_HISTORY=3

[ -f "$FILE" ] || { echo "Error: File not found: $FILE" >&2; exit 1; }
rg -q '^## 变更历史$' "$FILE" || { echo "Error: v3 marker not found: $FILE" >&2; exit 1; }

tmp_file="${FILE}.tmp"
awk -v keep="$MAX_HISTORY" '
    /^## 变更历史$/ { history=1; print; next }
    !history { print; next }
    /^### \[/ { entries++; if (entries <= keep) print; next }
    entries <= keep { print }
    END { if (entries > keep) print "\n- 已压缩 " (entries - keep) " 条较早变更；详情见月度归档。" }
' "$FILE" > "$tmp_file"
mv "$tmp_file" "$FILE"

lines=$(wc -l < "$FILE" | tr -d ' ')
echo "Maintained v3 history: $FILE ($lines lines)"
[ "$lines" -le 200 ] || echo "Warning: split oversized current-state content manually." >&2
