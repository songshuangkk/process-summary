# Process Summary

Process Summary is a local knowledge-management skill for Claude Code. It helps an agent load the smallest reliable amount of project context before making a change.

Rather than treating project memory as an ever-growing changelog, Process Summary separates:

- **topic summaries** — current behavior, decisions, invariants, and risks;
- **topology nodes** — stable entry points such as topics, APIs, tables, events, and capability tokens;
- **evidence-backed edges** — verified relationships between topics; and
- **monthly history** — cold context used only for rationale and regression investigation.

The result is a compact, auditable context graph: route first, read only the relevant summaries, and verify high-risk assumptions in source code.

## Why Process Summary

Large repositories typically accumulate documentation that is difficult for both humans and agents to search accurately. Keyword search alone often loads irrelevant context; hand-written dependency lists drift as the code changes.

Process Summary addresses both problems:

1. Resolve an input such as a code path, API route, table name, event, or topic.
2. Select the primary topic and a bounded set of direct neighbors.
3. Read current topic summaries instead of a full history.
4. Require code evidence and a verification date for every relationship in the graph.

It is intentionally not a full import graph. Only relationships that materially affect implementation decisions belong in the topology.

## Architecture

```text
Task input: code path / API / table / event / topic
                         │
                         ▼
                 topology.tsv (nodes)
                         │
                         ▼
                  edges.tsv (verified edges)
                         │
                         ▼
       primary topic + direct neighbors (maximum three)
                         │
                         ▼
              current topic summaries and source code
```

The local project layout is:

```text
.claude/process-summary/
├── topology.tsv                    # topic nodes and lookup anchors
├── edges.tsv                       # verified directed relationships
├── <module>/<topic>/summary.md     # current, human-readable knowledge
└── <year>/<month>.md               # cold change history
```

## Installation

Clone the skill into your Claude Code skills directory:

```bash
git clone https://github.com/songshuangkk/process-summary.git \
  ~/.claude/skills/process-summary
```

From the root of the project you want to document, initialize the local store:

```bash
mkdir -p .claude/process-summary
cp ~/.claude/skills/process-summary/references/topology_template.tsv \
  .claude/process-summary/topology.tsv
cp ~/.claude/skills/process-summary/references/edges_template.tsv \
  .claude/process-summary/edges.tsv
```

The project knowledge store is local by design. Keep it out of version control when it contains personal working context or environment-specific details.

## Data Model

### Topic nodes

`topology.tsv` has one row per topic:

```text
topic  aliases  owners  entrypoints  data_nodes  events  tags
```

Use this file to expose stable lookup anchors. For example, an API path belongs in `entrypoints`, a database table in `data_nodes`, and a core service or package capability in `owners`.

### Evidence-backed edges

`edges.tsv` has one row per directed relationship:

```text
source  relation  target  evidence  verified_at
```

Supported relationship types are:

- `calls`
- `reads`
- `writes`
- `publishes`
- `consumes`
- `state-transition`

`evidence` must use the form `repository-relative-file#ExactAnchor`. The anchor must exist in that file. `verified_at` is an ISO-8601 date set after reviewing the evidence.

Do not add an edge based only on a summary, an import statement, or an assumption.

## Daily Workflow

Run commands from the target project root. Replace the path below if you installed the skill elsewhere.

```bash
SKILL_DIR="$HOME/.claude/skills/process-summary"
```

### Retrieve focused context

```bash
bash "$SKILL_DIR/scripts/retrieve.sh" quality/pad-incoming-inspection
bash "$SKILL_DIR/scripts/retrieve.sh" /api/quality/incoming
bash "$SKILL_DIR/scripts/retrieve.sh" mes_quality_task
bash "$SKILL_DIR/scripts/retrieve.sh" path/to/CapabilityService.java
```

The retrieval command resolves a primary topic and loads direct upstream or downstream neighbors, capped at three summaries.

### Capture high-value knowledge

Capture only changes that affect contracts, state or data semantics, cross-module flows, recurring root causes, or durable design decisions.

```bash
bash "$SKILL_DIR/scripts/capture.sh"
bash "$SKILL_DIR/scripts/route.sh" <changed-paths...>
```

When a relevant change is complete:

1. Update the primary topic summary.
2. Update node anchors in `topology.tsv` if required.
3. Add or refresh edges only after verifying a code anchor.
4. Update `verified_at` for every reviewed edge.
5. Run the integrity checks.

## Validation and Auditing

```bash
# Verify nodes, summaries, edge endpoints, relation types, evidence anchors, and dates.
bash "$SKILL_DIR/scripts/topology.sh" check

# List edges that have not been verified since the specified date.
bash "$SKILL_DIR/scripts/topology.sh" audit 2026-04-18
```

Use `audit` as part of periodic maintenance or before working in an area with an old topology.

## Migrating Existing Summaries

To normalize legacy summary headings into the v3 structure:

```bash
bash "$SKILL_DIR/scripts/migrate-to-v3.sh" .claude/process-summary
```

The migration preserves existing factual text. Review and refine each topic over time; do not invent topology edges during migration.

## Summary Contract

Every `summary.md` uses these top-level sections only:

```markdown
## 现状
## 相关模块
## 技术决策
## 注意事项
## 变更历史
```

Keep summaries under 200 lines. The maintenance script compacts historical entries only; split an oversized topic instead of removing current facts.

## Repository Structure

```text
process-summary/
├── SKILL.md
├── README.md
├── references/
│   ├── edges_template.tsv
│   ├── topology_template.tsv
│   └── module_template.md
└── scripts/
    ├── capture.sh
    ├── maintain.sh
    ├── migrate-to-v3.sh
    ├── retrieve.sh
    ├── route.sh
    └── topology.sh
```

## License

MIT
