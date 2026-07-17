# Process Summary v2.1 — Knowledge-Focused Memory

**Turn change history into evolving knowledge base.**

Process Summary v2.1 transforms project memory from a **change log** into a **knowledge base** that evolves with your project:

```text
.claude/process-summary/{topic}/summary.md

## 现状（What it does NOW）
核心职责 + 关键设计 + 数据流

## 技术决策（WHY decisions were made）
| 决策 | 时间 | 理由 | 状态 |

## 变更历史（WHEN changes happened）
简短记录，详情已上移到上述部分
```

## What's New in v2.1

| Feature | v2.0 | v2.1 |
|---------|------|------|
| **Main focus** | Change timeline | Current state + design rationale |
| **New changes** | Append to history | **Update existing knowledge** |
| **Design decisions** | Buried in history | **Explicit decision table** |
| **Deprecated features** | Hard to find | **Clearly marked as ❌ 已废弃** |
| **Knowledge growth** | Keeps expanding | **Converges to stable state** |
| **Onboarding** | Read all history | **Read current state first** |

---

## Core Philosophy

### Knowledge Over History

**v2.0 Question**: "What changed when?"
```markdown
## Recent Changes
### [2026-07-17] 某某功能修改
**Modified**: ...
**Why**: ...
**Key Logic**: ...
```

**v2.1 Question**: "How does it work NOW and WHY?"
```markdown
## 现状
### 核心职责
{一句话概括现在是做什么的}

### 关键设计
{当前的核心架构、模式、决策}

## 技术决策
| 决策 | 时间 | 理由 | 状态 |
| 某某架构 | 2026-07-17 | 为什么 | ✅ 有效 |
```

---

## How It Works

### Capture: Update Knowledge, Don't Just Append

When you say `done` after coding:

1. **Analyze the change**: Does this update existing knowledge or add new topic?
2. **Update "现状" section**: Modify current state description
3. **Update decision table**: Add/update design rationale
4. **Mark deprecated**: If replacing old design, mark as ❌ 已废弃
5. **Append brief history**: Single line at bottom referencing what was updated

### Retrieve: Current State First

When you say `retrieve quality`:

1. **Present current state**: 核心职责 → 关键设计 → 技术决策
2. **Show rationale**: Design decision table with WHY
3. **Cross-reference**: Related modules with dependency flows
4. **History on demand**: Brief timeline only if asked

---

## Example: Knowledge Evolution

### Initial State (First Implementation)

```markdown
## 现状
### 核心设计
- 简单的质检流程：创建任务 → 分配检验员 → 提交结果

## 技术决策
| 决策 | 时间 | 理由 | 状态 |
| 基础质检流程 | 2026-05-01 | MVP 版本 | ✅ 有效 |
```

### After First Enhancement

```markdown
## 现状
### 核心设计
- 质检流程：创建任务 → 分配检验员 → 提交结果
- **新增**：支持返工流程（CONCESSION_ACCEPT 可返工）

## 技术决策
| 决策 | 时间 | 理由 | 状态 |
| 基础质检流程 | 2026-05-01 | MVP 版本 | ✅ 有效 |
| 支持返工 | 2026-06-10 | 处理不合格品 | ✅ 有效 |
```

### After Major Refactor

```markdown
## 现状
### 核心设计
- **状态机三维度分离**：任务状态、检验结果、处理方式
- **返工流程简化**：跳过 WAIT_REWORK 状态，直接完成任务
- **ERP 流程拆分**：assign ①②③ + submit ④⑤

## 技术决策
| 决策 | 时间 | 理由 | 状态 |
| 状态机三维度分离 | 2026-07-15 | 删除WAIT_REWORK，简化流程 | ✅ 有效 |
| ~~支持返工~~ | ~~2026-06-10~~ | ~~旧返工流程~~ | ❌ 已废弃 |
| ~~基础质检流程~~ | ~~2026-05-01~~ | ~~被新架构取代~~ | ❌ 已废弃 |
```

**Result**: Knowledge converges to current understanding, not an ever-growing list of changes.

---

## Migration from v2.0

See `references/migration_guide.md` for detailed examples:

1. **Extract design decisions** from change history into decision table
2. **Synthesize current state** by merging all changes into "现状" section
3. **Mark deprecated** features clearly in decision table
4. **Simplify change history** to brief references

**Quick checklist**:
- [ ] Added "相关模块" section
- [ ] Changed "Overview" to "现状"
- [ ] Merged changes into "关键设计"
- [ ] Extracted decisions to table
- [ ] Marked deprecated decisions
- [ ] Moved history to bottom

---

## Benefits

| For... | v2.0 | v2.1 |
|--------|------|------|
| **New developers** | Read 50 change entries | Read 1 "现状" section |
| **Design rationale** | Scattered across dates | Explicit decision table |
| **Impact analysis** | Guess which changes matter | Check decision table |
| **Deprecated features** | Still in history | Clearly marked ❌ |
| **Knowledge maintenance** | Append forever | Update existing sections |
| **Token efficiency** | Load all history | Load only current state |

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
├── SKILL.md                        # v2.1 knowledge-focused logic
├── README.md                       # This file
├── references/
│   ├── module_template.md          # Updated: knowledge-first structure
│   ├── migration_guide.md          # NEW: v2.0 → v2.1 migration
│   ├── monthly_entry_template.md   # Monthly archive entries
│   ├── root_claude_template.md
│   └── module_claude_template.md
└── scripts/
    ├── capture.sh
    ├── retrieve.sh
    ├── route.sh
    └── maintain.sh
```

---

## License

MIT
