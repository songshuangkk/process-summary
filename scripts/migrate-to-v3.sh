#!/bin/bash
# migrate-to-v3.sh — One-way schema migration for Process Summary files.

set -euo pipefail

ROOT="${1:-.claude/process-summary}"
DATE="${2:-$(date +%F)}"
[ -d "$ROOT" ] || { echo "Error: Summary directory not found: $ROOT" >&2; exit 1; }

migrate_file() {
    local file="$1" tmp title
    if rg -q '^> 最后整理:' "$file" && rg -q '^## 现状$' "$file" && rg -q '^## 技术决策$' "$file" && rg -q '^## 注意事项$' "$file" && rg -q '^## 变更历史$' "$file"; then return; fi
    tmp="${file}.tmp"
    title=$(sed -n 's/^# //p' "$file" | head -1)
    [ -n "$title" ] || title=$(basename "$(dirname "$file")")
    awk -v title="$title" -v date="$DATE" '
        function section(name) { if (!seen[name]++) { print ""; print "## " name; print "" } }
        BEGIN { print "# " title; print ""; print "> 最后整理: " date }
        /^# / || /^> 最后(更新|整理):/ { next }
        /^## (Overview|概述)$/ { section("现状"); print "### 核心职责"; next }
        /^## (Dependencies|依赖模块|依赖关系)$/ { section("相关模块"); next }
        /^## (Recent Changes|Change History|变更历史)$/ { section("变更历史"); next }
        /^## (Watch Out|注意事项|技术债务|待改进项|上线检查)$/ { section("注意事项"); next }
        /^## (关键决策|关键决策（Think 阶段）|Deprecated)$/ { section("技术决策"); next }
        /^## / { section("现状"); sub(/^## /, "### "); print; next }
        { print }
        END {
            if (!seen["相关模块"]) { section("相关模块"); print "- 待按实际调用关系补充。" }
            if (!seen["技术决策"]) { section("技术决策"); print "- 暂无独立决策；后续变更时补充决策原因。" }
            if (!seen["注意事项"]) { section("注意事项"); print "- 暂无已确认的专项风险。" }
            if (!seen["变更历史"]) { section("变更历史"); print "- 历史详情见月度归档。" }
        }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
}

while IFS= read -r -d '' file; do migrate_file "$file"; done < <(find "$ROOT" -name summary.md -type f -print0)
echo "Migrated summaries under $ROOT to v3 schema."
