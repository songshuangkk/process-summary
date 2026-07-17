---
name: process-summary
description: Maintain this developer's local, topology-assisted Claude Code knowledge base. Use when the user explicitly asks to save context, capture progress, retrieve a module, or load a topic.
allowed-tools: ["Bash"]
---

# Process Summary v3.3 — Evidence-Backed Knowledge Topology

This is a local personal knowledge base for fast, accurate task context. It has three complementary roles:

- **Topology** routes a task to the smallest relevant topic set.
- **Topic summaries** explain current behavior, decisions, and risks.
- **Code** remains the source of truth before changing contracts, persistence, state machines, or permissions.

```text
CLAUDE.md                                              # root route only
<root-module>/CLAUDE.md                                # static module boundary + topic index
.claude/process-summary/topology.tsv                   # machine-readable topic nodes
.claude/process-summary/edges.tsv                      # evidence-backed topic relations
.claude/process-summary/<module>/<topic>/summary.md    # human-readable current knowledge
.claude/process-summary/index.md + <year>/<month>.md   # cold change history
```

## Topology Schema

`topology.tsv` has one row per topic:

```text
topic  aliases  owners  entrypoints  data_nodes  events  tags
```

- `aliases`: business terms and common names.
- `owners`: stable class/package capability tokens, not every implementation file.
- `entrypoints`, `data_nodes`, `events`: exact API paths, tables, or event names when relevant.
- Topic rows never contain dependencies. Relations belong exclusively in `edges.tsv`.

`edges.tsv` has one row per directed relation:

```text
source  relation  target  evidence  verified_at
```

- `relation` is one of `calls`, `reads`, `writes`, `publishes`, `consumes`, or `state-transition`.
- `evidence` is `repository-relative-file#exact-anchor`; the anchor must occur in that file.
- `verified_at` is an ISO date set after reading the evidence.

Never generate a full import graph or create a relationship from summary prose alone.

## Retrieve

Use topology before reading summaries:

```bash
bash scripts/retrieve.sh quality/pad-incoming-inspection
bash scripts/retrieve.sh /pad/quality-incoming
bash scripts/retrieve.sh mes_quality_task
```

The command resolves a primary topic, then adds direct upstream/downstream neighbors, capped at three summaries. Load monthly history only for design rationale or regression investigation.

## Capture

Capture only on explicit user request and only for high-value changes: API contracts, state/data semantics, cross-module flow, recurring root causes, or lasting design decisions.

1. Run `scripts/capture.sh` and route the changed paths.
2. Update the primary topic summary: `现状`, `技术决策`, `注意事项`, then concise history.
3. Update `topology.tsv` whenever aliases, owner tokens, API/table/event anchors changed.
4. Add or refresh an `edges.tsv` row only after verifying a code anchor; update `verified_at` at the same time.
5. For a new topic, add both its summary and exactly one topology row.
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

- Keep a summary under 200 lines. `scripts/maintain.sh` compacts history only; split an oversized current-state topic instead of deleting facts.
- Current behavior and invariants come before history.
- Put human explanation of a relationship in `相关模块`; put the machine-readable edge in `topology.tsv`.
- Never use legacy headings such as `Overview`, `Dependencies`, `Recent Changes`, or `Watch Out`.

## Validation

```bash
bash scripts/topology.sh resolve <query>
bash scripts/topology.sh neighbors <topic>
bash scripts/topology.sh check
bash scripts/topology.sh audit 2026-04-18
```

`check` verifies nodes, relation type, edge endpoints, evidence files, evidence anchors, and date format. `audit <cutoff>` lists relations whose verification date is older than the cutoff.
