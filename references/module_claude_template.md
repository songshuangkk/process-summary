# Module-Level CLAUDE.md Process Summary

Module-level `CLAUDE.md` stores the topic index for that root module.

## Format

```markdown
### Process Summary

- **quality-task**: 检验任务状态机、Facade、执行链路 → [details](../.claude/process-summary/quality/summary.md)
- **inspection-template**: 检验模板类型、明细快照 → [details](../.claude/process-summary/inspection-template-type/summary.md)
```

## Rules

- Keep one line per topic.
- Replace existing topic entries in place.
- Put detailed facts in `.claude/process-summary/{topic}/summary.md`.
- Keep module entries concise; do not paste history or long Watch Out text here.
- Use a relative link that works from the module directory, usually `../.claude/process-summary/{topic}/summary.md`.
