# Process-Summary

A project memory management skill for Claude Code. Uses a "module-level index + external change history + modular detail files" architecture to keep CLAUDE.md lean regardless of project size.

## Core Value

As `CLAUDE.md` grows bloated over time, token waste and AI confusion increase. Process Summary solves this with:

- **Module-level indexing**: One line per module in CLAUDE.md — updated in place, never duplicated
- **External change history**: Detailed change logs live in `.claude/process-summary/index.md`, not in CLAUDE.md
- **Incremental capture**: Only record architectural decisions and core logic from the current change
- **Layered storage**: Detailed docs live in `.claude/process-summary/`, keeping the main file lightweight
- **Tiered compression**: Recent changes fully preserved, older entries progressively compressed by `maintain.sh`

## Project Structure

After installation, your project will have:

```
your-project/
├── CLAUDE.md                            # Module-level index (one line per module)
└── .claude/
    ├── process-summary/
    │   ├── index.md                     # Change history across all modules
    │   └── <module-name>/
    │       └── summary.md               # Architecture and logic details
```

## Usage

After completing a feature or refactoring, say in Claude Code:

```
done
更新项目记忆
save context
```

To load module context when starting a new task:

```
加载模块 auth
retrieve auth
```

### What the skill does

1. Scans `git diff` to identify code changes
2. Extracts core logic, API call chains, and risks (Watch Out)
3. Creates or updates module summaries under `.claude/process-summary/`
4. Updates the module's one-line entry in `CLAUDE.md` (replaces, never appends)
5. Appends change history to `.claude/process-summary/index.md`

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition and instructions |
| `scripts/capture.sh` | Identify changed files from git or filesystem |
| `scripts/retrieve.sh` | Search module summaries by keyword |
| `scripts/maintain.sh` | Compress summary files exceeding 150 lines, or index.md exceeding 200 lines |
| `references/module_template.md` | Template for summary file structure |
| `references/index_entry_template.md` | Template for CLAUDE.md module-level index |
| `references/index_history_template.md` | Template for external change history file |
