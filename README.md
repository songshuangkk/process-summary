# Process Summary

**Keep Claude Code memory layered instead of loading everything at once.**

Large projects make top-level `CLAUDE.md` expensive when every module summary is indexed there. Process Summary turns project memory into a layered tree:

```text
CLAUDE.md                         # root module map only
<root-module>/CLAUDE.md            # module-level topic index
.claude/process-summary/<topic>/   # detailed cold memory
```

Claude reads the top-level map first, then loads the nearby module index only when work touches that module, then loads detailed summaries only when needed.

---

## Workflows

**After finishing work** — say `done` in Claude Code:

```text
You: done
Claude: analyzes changed files, writes cold summary, updates module CLAUDE.md, keeps root CLAUDE.md short
```

**Before starting work** — say `retrieve quality`:

```text
You: retrieve quality
Claude: finds matching module CLAUDE.md and summaries, loads overview + risks only
```

---

## What It Looks Like

**Top-level `CLAUDE.md`:**

```markdown
### Process Summary

- `shengchuang-module-quality/CLAUDE.md`: 质检、来料检、自检、检验任务
- `shengchuang-module-biz/CLAUDE.md`: PDA 接口、业务编排、跨模块 AppService
```

**Module-level `shengchuang-module-quality/CLAUDE.md`:**

```markdown
### Process Summary

- **quality-task**: 检验任务状态机、Facade、执行链路 → [details](../.claude/process-summary/quality/summary.md)
- **inspection-template**: 检验模板类型、明细快照 → [details](../.claude/process-summary/inspection-template-type/summary.md)
```

**Cold summary `.claude/process-summary/quality/summary.md`:**

```markdown
# Quality Context

## Overview
质检模块核心：状态机、Facade 层、错误码、来料检验执行链路

## Core Components
- `QualityTaskFacade`: 跨模块质检任务入口
- `QualityTaskService`: 质检任务状态流转

## Dependencies
- biz

## Recent Changes

### [2026-07-07] 修复来料检任务详情
**Modified**: ...
**Why**: ...
**Key Logic**: ...
**Watch Out**: ...
```

---

## Why This Works

- Top-level context stays small and stable.
- Module-level indexes are loaded only when work enters that module.
- Detailed summaries remain available without becoming default context.
- Watch Out entries survive compression.

---

## Install

```bash
git clone https://github.com/songshuangkk/process-summary.git \
  ~/.claude/skills/process-summary
```

No build step is required.

---

## Project Structure

```text
process-summary/
├── SKILL.md
├── scripts/
│   ├── capture.sh
│   ├── retrieve.sh
│   ├── route.sh
│   └── maintain.sh
└── references/
    ├── module_template.md
    ├── root_claude_template.md
    ├── module_claude_template.md
    └── index_history_template.md
```

---

## License

MIT
