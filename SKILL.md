---
name: process-summary
description: Maintain a local, topology-assisted Claude Code knowledge base. Use when the user explicitly asks to save context, capture progress, retrieve a module, or load a topic.
allowed-tools: ["Bash"]
---

# Process Summary v3.2 — Local Knowledge Topology

This skill maintains a personal project knowledge base for fast, accurate task context.

- **Topology** routes a task to the smallest relevant topic set.
- **Topic summaries** explain current behavior, decisions, and risks.
- **Code** remains the source of truth before changing contracts, persistence, state machines, or permissions.

```text
CLAUDE.md                                              # root route only
<root-module>/CLAUDE.md                                # static boundary + topic index
.claude/process-summary/topology.tsv                   # machine-readable topic graph
.claude/process-summary/<module>/<topic>/summary.md    # current knowledge
.claude/process-summary/index.md + <year>/<month>.md   # cold change history
```

## Setup

```bash
mkdir -p .claude/process-summary
cp references/topology_template.tsv .claude/process-summary/topology.tsv
```

## Topology

`topology.tsv` has one row per topic:

```text
topic  aliases  owners  entrypoints  data_nodes  events  depends_on  tags
```

- `aliases`: business terms and common names.
- `owners`: stable class/package capability tokens, not every implementation file.
- `entrypoints`, `data_nodes`, `events`: exact anchors when relevant.
- `depends_on`: semicolon-separated direct topic IDs only.

Record only high-value API, data, event, state, or Facade boundaries. Never generate a full import graph.

## Retrieve

```bash
bash scripts/retrieve.sh module/topic
bash scripts/retrieve.sh /api/path
bash scripts/retrieve.sh table_name
bash scripts/retrieve.sh path/to/CapabilityService.java
```

The command resolves a primary topic, then adds direct upstream/downstream neighbors, capped at three summaries. Read monthly history only for rationale or regression investigation.

## Capture

Capture only when the user explicitly asks and the change affects a contract, state/data semantic, cross-module flow, recurring root cause, or lasting design decision.

1. Run `scripts/capture.sh` and route the changed paths.
2. Update the primary topic summary.
3. Update `topology.tsv` whenever anchors or direct dependencies changed.
4. For a new topic, add both its summary and exactly one topology row.
5. Run `bash scripts/topology.sh check`.

Do not capture routine CRUD, formatting, renames, or transient debugging notes.

## Summary Rules

Every `summary.md` uses only these top-level sections:

```markdown
## 现状
## 相关模块
## 技术决策
## 注意事项
## 变更历史
```

- Keep a summary under 200 lines. `scripts/maintain.sh` compacts history only; split an oversized topic instead of deleting facts.
- Put human explanation of relationships in `相关模块`; put machine-readable edges in `topology.tsv`.
- Never use legacy headings such as `Overview`, `Dependencies`, `Recent Changes`, or `Watch Out`.

## Validation

```bash
bash scripts/topology.sh resolve <query>
bash scripts/topology.sh neighbors <topic>
bash scripts/topology.sh check
```

`check` verifies that every summary has one topology node and every edge targets an existing topic.
