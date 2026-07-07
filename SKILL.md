---
name: process-summary
description: |
  Manages Claude Code project memory with hierarchical CLAUDE.md files and cold process summaries.
  ALWAYS use this skill when the user says "done", "save context", "capture progress", "update summaries",
  or "capture" after completing a coding task or refactor. Also use when the user says "retrieve",
  "load module", "加载模块", "开始新任务", or asks about a specific module's implementation details.
allowed-tools: ["Bash"]
---

# Process Summary

Keep always-loaded context tiny. Store memory in a hierarchy:

```text
CLAUDE.md                         # top-level root module map only
<root-module>/CLAUDE.md            # module-level topic index
.claude/process-summary/<topic>/   # cold detailed summaries
```

## Setup

If missing, create the cold store:

```bash
mkdir -p .claude/process-summary
```

## Capture Mode

Trigger: user says "done", "更新项目记忆", "save context", "capture", or similar after a coding task.

1. Run `scripts/capture.sh` to identify changed files.
2. Run `bash scripts/route.sh <changed-files...>` or pipe changed paths into it to identify:
   - root module directory, for example `src`, `packages/api`, or `shengchuang-module-quality`
   - module index file, for example `src/CLAUDE.md` or `shengchuang-module-quality/CLAUDE.md`
   - default topic, derived from the root module name
3. Determine the logical topic.
   - Default to the owning root module name.
   - Use a narrower topic only when changed files clearly map to an existing summary.
   - If multiple plausible topics exist, stop and ask the user.
4. Write or update `.claude/process-summary/{topic}/summary.md` using `references/module_template.md`.
   - Keep summary files under 150 lines.
   - Run `scripts/maintain.sh {file_path}` immediately when exceeded.
5. Update the owning module-level `CLAUDE.md` using `references/module_claude_template.md`.
   - Add or replace one topic entry under `### Process Summary`.
   - Link to `.claude/process-summary/{topic}/summary.md`.
   - Never duplicate the same topic.
6. Update top-level `CLAUDE.md` using `references/root_claude_template.md`.
   - Keep only one short entry per root module directory.
   - Link to `{root_module}/CLAUDE.md`.
   - Do not put topic summaries, long decisions, history, dates, or Watch Out text in top-level `CLAUDE.md`.
7. Append change history to `.claude/process-summary/index.md` using `references/index_history_template.md`.
   - Add a `- [DATE] change_title` line under the corresponding `## {topic}` section, newest first.
   - Create the section if this is the first change for this topic.
   - If the file exceeds 200 lines, run `scripts/maintain.sh .claude/process-summary/index.md`.

## Retrieve Mode

Trigger: user says "开始新任务", "加载模块", "retrieve", or asks about a module.

1. Run `scripts/retrieve.sh {keyword}`.
2. Read only the matched module-level `CLAUDE.md` and matched summary file(s).
3. Present:
   - Overview
   - Dependencies
   - all Watch Out entries
4. Suggest loading related modules only when the Dependencies section names them.

## Rules

- Top-level `CLAUDE.md` is a navigation file, not a knowledge store.
- Module-level `CLAUDE.md` is an index for topics inside that module, not a history file.
- Detailed facts live in `.claude/process-summary/{topic}/summary.md`.
- `.claude/process-summary/index.md` is a cold full-history index; do not load it unless needed.
- Use imperative, factual wording. Avoid narrative filler.
- Preserve Watch Out information during compression.

## Error Handling

| Situation | Action |
|-----------|--------|
| No git repo | Fall back to `find -mtime -1` via `scripts/capture.sh` |
| No obvious topic | Ask the user before writing |
| Missing module directory | Use top-level `CLAUDE.md` plus cold summary only |
| Script failure | Manually analyze changes and complete the record; report the error |
