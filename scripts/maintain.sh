#!/bin/bash
# ----------------------------------------------------------------
# Name: maintain.sh
# Description: 自动压缩超长文件，保留关键架构决策。
#              支持两类文件：
#              1. 模块 summary.md — 分级压缩变更记录
#              2. index.md — 压缩过老的变更历史条目
# ----------------------------------------------------------------

FILE=$1
if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE not found."
    exit 1
fi

BASENAME=$(basename "$FILE")

# --- 模式判断 ---
if [ "$BASENAME" = "index.md" ]; then
    # ===== index.md 压缩逻辑 =====
    # 策略：每个模块 section 只保留最近 10 条变更，更早的删除
    TEMP_FILE="${FILE}.tmp"
    IN_SECTION=false
    LINE_COUNT=0
    SECTION_LINES=()

    while IFS= read -r line; do
        if [[ "$line" =~ ^##\  ]]; then
            # 新 section 开始 — 先 flush 上一个 section
            if [ "$IN_SECTION" = true ]; then
                # 只保留最近 10 条
                TOTAL=${#SECTION_LINES[@]}
                if [ "$TOTAL" -gt 10 ]; then
                    KEEP=$((TOTAL - 10))
                    for (( j=0; j<KEEP; j++ )); do
                        echo "${SECTION_LINES[$j]}" >> "$TEMP_FILE"
                    done
                    echo "... (compressed ${KEEP} older entries)" >> "$TEMP_FILE"
                    for (( j=KEEP; j<TOTAL; j++ )); do
                        echo "${SECTION_LINES[$j]}" >> "$TEMP_FILE"
                    done
                else
                    for entry in "${SECTION_LINES[@]}"; do
                        echo "$entry" >> "$TEMP_FILE"
                    done
                fi
                echo "" >> "$TEMP_FILE"
            fi
            # 写 section header
            echo "$line" >> "$TEMP_FILE"
            IN_SECTION=true
            SECTION_LINES=()
        elif [ "$IN_SECTION" = true ]; then
            # 跳过空行，收集条目
            if [ -n "$line" ]; then
                SECTION_LINES+=("$line")
            fi
        else
            # header 部分（文件头等）
            echo "$line" >> "$TEMP_FILE"
        fi
    done < "$FILE"

    # flush 最后一个 section
    if [ "$IN_SECTION" = true ]; then
        TOTAL=${#SECTION_LINES[@]}
        if [ "$TOTAL" -gt 10 ]; then
            KEEP=$((TOTAL - 10))
            for (( j=0; j<KEEP; j++ )); do
                echo "${SECTION_LINES[$j]}" >> "$TEMP_FILE"
            done
            echo "... (compressed ${KEEP} older entries)" >> "$TEMP_FILE"
            for (( j=KEEP; j<TOTAL; j++ )); do
                echo "${SECTION_LINES[$j]}" >> "$TEMP_FILE"
            done
        else
            for entry in "${SECTION_LINES[@]}"; do
                echo "$entry" >> "$TEMP_FILE"
            done
        fi
    fi

    mv "$TEMP_FILE" "$FILE"
    echo "Index maintenance done. Current line count: $(wc -l < "$FILE")"

else
    # ===== summary.md 压缩逻辑（原有逻辑） =====
    TEMP_FILE="${FILE}.tmp"
    MARKER="## Recent Changes"

    # 1. 定位变更区域起始行
    MARKER_LINE=$(grep -n "$MARKER" "$FILE" | cut -d: -f1)
    if [ -z "$MARKER_LINE" ]; then
        echo "Error: Marker '$MARKER' not found in $FILE."
        exit 1
    fi

    # 2. 提取并保留 Header (Overview, Components, Dependencies)
    head -n "$MARKER_LINE" "$FILE" > "$TEMP_FILE"

    # 3. 识别所有变更条目的起始行 (格式为 ### [YYYY-MM-DD])
    RECORD_LINES=$(grep -n "^### \[" "$FILE" | cut -d: -f1)
    TOTAL_RECORDS=$(echo "$RECORD_LINES" | wc -l)

    # 如果记录数较少，不执行复杂压缩，直接追加后续内容
    if [ "$TOTAL_RECORDS" -le 5 ]; then
        sed -n "$((MARKER_LINE + 1)),\$p" "$FILE" >> "$TEMP_FILE"
    else
        echo "Compressing $TOTAL_RECORDS historical records in $FILE..."

        COUNTER=1
        # 将行号转为数组处理
        LINES_ARRAY=($RECORD_LINES)

        for (( i=0; i<${#LINES_ARRAY[@]}; i++ )); do
            CURRENT_LINE=${LINES_ARRAY[$i]}
            # 获取下一条记录的开始行，如果是最后一条则取文件末尾
            if [ $i -lt $(( ${#LINES_ARRAY[@]} - 1 )) ); then
                NEXT_START=${LINES_ARRAY[$((i+1))]}
                END_LINE=$((NEXT_START - 1))
            else
                END_LINE=$(wc -l < "$FILE")
            fi

            # --- 分级处理逻辑 ---
            if [ "$COUNTER" -le 3 ]; then
                # Level 1: 最近 3 条记录 - 100% 完整保留
                sed -n "${CURRENT_LINE},${END_LINE}p" "$FILE" >> "$TEMP_FILE"

            elif [ "$COUNTER" -le 8 ]; then
                # Level 2: 第 4-8 条记录 - 压缩为单行摘要 + Watch Out 风险点
                TITLE=$(sed -n "${CURRENT_LINE}p" "$FILE")
                # 提取 Watch Out 后的内容（如果有）
                WATCHOUT=$(sed -n "${CURRENT_LINE},${END_LINE}p" "$FILE" | grep "**Watch Out**:" | sed 's/**Watch Out**://' | xargs)

                if [ -n "$WATCHOUT" ]; then
                    echo "$TITLE (⚠️ $WATCHOUT)" >> "$TEMP_FILE"
                else
                    echo "$TITLE" >> "$TEMP_FILE"
                fi

            else
                # Level 3: 8 条以后的记录 - 仅保留日期和标题作为索引
                sed -n "${CURRENT_LINE}p" "$FILE" | sed 's/### /- /' >> "$TEMP_FILE"
            fi

            ((COUNTER++))
        done
    fi

    # 4. 替换原文件
    mv "$TEMP_FILE" "$FILE"
    echo "Maintenance done. Current line count: $(wc -l < "$FILE")"
fi
