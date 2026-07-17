# 变更历史索引

位置：`.claude/process-summary/index.md`

索引只保留最近 30 天的简短入口；完整历史写入 `.claude/process-summary/{year}/{month}.md`。

```markdown
## 最近30天变更 (YYYY-MM-DD ~ YYYY-MM-DD)

### YYYY-MM-DD
- **module/topic**: 一句说明（详见 [MM月详情](YYYY/MM.md)）
```

- 新日期置顶；同一天按 topic 列出。
- 不在 index 或模块 `CLAUDE.md` 重复 topic 的现状、决策与风险。
- 超出 30 天的条目从 index 移除，月度文件保留。
