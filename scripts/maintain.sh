#!/bin/bash
# 实现原稿 Step 3 的压缩逻辑
FILE=$1
# 保留 Header (Overview, Components, Dependencies)
# 保留最近 5 条变更记录
# 之前的 5 条缩减为单行总结
# 更早的条目合并为关键词列表
# 重新写回文件并通知用户压缩完成
