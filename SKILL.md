---
name: process-summary
description: |
  Manages Claude Code project memory with knowledge-focused summaries and monthly-archived change history.
  ALWAYS use this skill when the user says "done", "save context", "capture progress", "update summaries",
  or "capture" after completing a coding task or refactor. Also use when the user says "retrieve",
  "load module", "加载模块", "开始新任务", or asks about a specific module's implementation details.
allowed-tools: ["Bash"]
---

# Process Summary v2.1 - Knowledge-Focused Memory

Keep always-loaded context tiny. Store memory as **evolving knowledge** with change history:

```text
CLAUDE.md                                  # top-level root module map only
<root-module>/CLAUDE.md                     # module-level topic index with cross-references
.claude/process-summary/<topic>/           # knowledge-focused summaries with current state
.claude/process-summary/index.md            # yearly index (last 30 days + monthly archive links)
.claude/process-summary/2026/04.md         # monthly change archive
.claude/process-summary/2026/05.md         # monthly change archive
...
```

## Key Principles (v2.1)

- **Knowledge over history**: Prioritize "how it works now" over "what changed when"
- **Evolving documentation**: New changes UPDATE existing knowledge sections, not just append
- **Design decisions table**: Track WHY decisions were made, not just WHAT changed
- **Converging knowledge**: Multiple related changes merge into single coherent state description
- **Change history as reference**: Brief timeline at bottom, not the main content

## v2.0 → v2.1 Changes

| Aspect | v2.0 (Change-Focused) | v2.1 (Knowledge-Focused) |
|--------|------------------------|--------------------------|
| Summary structure | Recent Changes first | Current State first |
| New changes | Append to history | Update existing knowledge |
| Design decisions | Buried in history | Explicit decision table |
| Knowledge growth | Keeps expanding | Merges and converges |
| Main value | Timeline reference | Current understanding |

## Setup

If missing, create the cold store:

```bash
mkdir -p .claude/process-summary/2026
```

## Capture Mode (Knowledge-Focused)

Trigger: user says "done", "更新项目记忆", "save context", "capture", or similar after a coding task.

1. Run `scripts/capture.sh` to identify changed files.
2. Run `bash scripts/route.sh <changed-files...>` to identify module and topic.
3. **Determine knowledge update strategy**:
   - **Does this change EXISTING knowledge?** → Update "现状" / "关键设计" / "技术决策" sections
   - **Is this a NEW topic?** → Create new summary with knowledge-first structure
   - **Does this change DEPRECATED knowledge?** → Mark as废弃/removed in decision table
4. Write or update `.claude/process-summary/{topic}/summary.md`:
   - **Current State section goes FIRST** (现状优先)
   - **Design Decisions table tracks WHY** (技术决策表记录理由)
   - **Change History goes LAST** (变更历史作为参考)
5. Update cross-references in "相关模块" section if dependencies changed.
6. Update module-level `CLAUDE.md` and top-level `CLAUDE.md`.
7. **Append to monthly archive** `.claude/process-summary/2026/{MM}.md`.
8. **Update yearly index** `.claude/process-summary/index.md`.

### Knowledge Update Logic

When updating existing summary:

```markdown
## 现状

### 核心职责
{如果职责变化，更新这里}

### 关键设计
{新设计追加到这里，旧设计如果废弃就移到技术决策表}

## 技术决策

| 决策 | 时间 | 理由 | 状态 |
|------|------|------|------|
| 新决策 | 2026-07-17 | 理由 | ✅ 有效 |
| 旧决策 | 2026-06-10 | 旧理由 | ❌ 已废弃 |

## 变更历史

### [2026-07-17] 最新变更
**影响**: 更新"关键设计"部分，添加新策略
```

## Retrieve Mode

Trigger: user says "开始新任务", "加载模块", "retrieve", or asks about a module.

1. Run `scripts/retrieve.sh {keyword}`.
2. Read only the matched module-level `CLAUDE.md` and matched summary file(s).
3. **Present current state first**:
   - 现状 → 核心职责 → 关键设计 → 技术决策
   - Show cross-references to related modules
   - Show Watch Out warnings
4. **Provide change history only if asked**.

## Rules

- **Current state > History**: "现状" section always comes first
- **Update > Append**: Prefer updating existing knowledge over appending new sections
- **Converge > Expand**: Merge related changes into coherent descriptions
- **WHY > WHAT**: Design decision table captures reasoning, not just changes
- **Cross-reference everything**: Explicit module dependencies in every summary
- **Keep summaries under 200 lines**: Use `scripts/maintain.sh` when exceeded
- **Monthly archives for detail**: Full change history in monthly files, summaries show current state

## Knowledge Structure

### Recommended summary.md structure:

```markdown
# {Topic} 知识总结

> 最后更新: 2026-07-17

## 相关模块

{cross-references}

## 现状

### 核心职责
{一句话概括当前是做什么的}

### 关键设计
{当前的核心架构、模式、关键决策}

### 数据流
{主要数据流转路径}

## 技术决策

| 决策 | 时间 | 理由 | 状态 |
|------|------|------|------|
| 某某架构决策 | 2026-07-17 | 为什么这么做 | ✅ 有效 |
| 废弃的决策 | 2026-06-10 | 以前的理由 | ❌ 已废弃 |

## 注意事项

- ⚠️ {风险和坑}

## 变更历史

### [2026-07-17] 变更标题
**影响**: 更新了哪些知识部分
---
```

## Error Handling

| Situation | Action |
|-----------|--------|
| No git repo | Fall back to `find -mtime -1` via `scripts/capture.sh` |
| No obvious topic | Ask the user before writing |
| Missing module directory | Use top-level `CLAUDE.md` plus cold summary only |
| Script failure | Manually analyze changes and complete the record; report the error |
| Monthly file missing | Create it with header `# 2026年{MM}月变更历史\n\n` |
| **Knowledge conflict** | **Stop and ask user**: 新变更与现有知识冲突，如何处理？ |
| **Deprecated feature** | **Mark in decision table**: 状态改为 ❌ 已废弃，保留时间戳 |

## Migration from v2.0

To migrate existing change-focused summaries to knowledge-focused:

1. **Read existing summary**
2. **Extract design decisions** from change history into decision table
3. **Write "现状" section** by synthesizing all changes into current state description
4. **Keep change history brief** at bottom as reference
5. **Update cross-references** if missing

See `references/migration_guide.md` for detailed examples.

## Benefits

| Aspect | v2.0 (Change-Focused) | v2.1 (Knowledge-Focused) |
|--------|------------------------|--------------------------|
| **Main value** | Timeline reference | Current system understanding |
| **Knowledge growth** | Expands indefinitely | Converges to stable state |
| **Design rationale** | Buried in history | Explicit in decision table |
| **Deprecated features** | Hard to identify | Clearly marked in table |
| **New developer onboarding** | Read all history | Read current state first |
| **Change impact analysis** | Diff across dates | Check decision table |
