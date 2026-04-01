#!/bin/bash
# 根据关键字在 .claude/process-summary/ 中定位模块文件
KEYWORD=$(echo "$1" | tr '[:upper:]' '[:lower:]')
ls .claude/process-summary/ | grep -i "$KEYWORD"
