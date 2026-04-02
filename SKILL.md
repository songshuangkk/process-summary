---
name: process-summary
description: |
  Manages project memory and keeps CLAUDE.md lean by modularizing context.
  Use when the user says "done", "task finished", "save context", "capture progress", or "update summaries".
  This skill triggers after completing a feature or refactor to analyze git changes and update module-specific summaries in .claude/process-summary/.
allowed-tools: ["Bash"]
---

# Process Summary

## Instructions

### Capture Mode

Trigger: user says "done", "更新项目记忆", "save context", "capture", or after a git commit.

1. Run `scripts/capture.sh` to identify changed files
2. For each logical module affected, extract knowledge using the template at [references/module_template.md](references/module_template.md):
   - **Why**: What problem does this change solve?
   - **Key Logic**: Core algorithm or interface changes
   - **Watch Out**: Breaking changes, concurrency risks, or gotchas
3. Write summary to `.claude/process-summary/{module_name}/summary.md`
4. If the summary file exceeds 150 lines, run `scripts/maintain.sh {file_path}`
5. Update **CLAUDE.md** using [references/index_entry_template.md](references/index_entry_template.md):
   - Search for an existing entry with `**{module_name}**:`
   - If found: replace that line with the updated overview
   - If not found: add a new line under the `### Process Summary` section
   - **Never append a duplicate entry for the same module**
6. Update **change history** in `.claude/process-summary/index.md` using [references/index_history_template.md](references/index_history_template.md):
   - Append a `- [DATE] change_title` line under the corresponding `## {module_name}` section
   - Create the section if this is the first change for this module
   - If the file exceeds 200 lines, run `scripts/maintain.sh .claude/process-summary/index.md`

### Retrieve Mode

Trigger: user says "开始新任务", "加载模块", "retrieve", or asks about a specific module's implementation.

1. Run `scripts/retrieve.sh {keyword}` to locate relevant module files
2. Load and present the Overview section and all historical Watch Out warnings
3. Check the Dependencies field and suggest loading related modules to prevent side effects

## Principles

- **Factuality**: Record only objective facts, no narrative filler
- **Imperative tone**: Use imperative sentences ("Use X to Y")
- **Token budget**: CLAUDE.md index = one line per module (no growth per change); each summary file under 150 lines
- **Risk first**: Watch Out has the highest retention priority — never drop during compression

## Error Handling

- **No git**: Fall back to `find -mtime -1` for files modified in the last 24 hours
- **Naming conflict**: If similar module names exist (e.g., `auth` vs `auth-api`), stop and ask the user
- **Script failure**: Manually analyze file changes and complete the record, then report the error

## Examples

**Example 1 — Capture after implementing JWT auth**

User says "done" after implementing JWT authentication.

Summary written to `.claude/process-summary/auth/summary.md`:

```markdown
# Auth Context

## Overview
JWT-based authentication with refresh token rotation

## Core Components
- `src/middleware/auth.ts`: Token validation middleware
- `src/routes/login.ts`: Login endpoint with credential verification

## Dependencies
- redis (token blacklist)

---

## Recent Changes

### [2026-04-01] Implement JWT authentication
**Modified**: src/middleware/auth.ts, src/routes/login.ts
**Why**: Replace session-based auth for stateless horizontal scaling
**Key Logic**: RS256 signed tokens, 15min access + 7day refresh, Redis blacklist on logout
**Watch Out**: Token rotation race condition — concurrent refresh requests may generate orphaned tokens
```

CLAUDE.md index updated (one line per module, replaced on update):

```markdown
### Process Summary

- **auth**: JWT auth with refresh token rotation → [details](.claude/process-summary/auth/summary.md)
```

Change history appended to `.claude/process-summary/index.md`:

```markdown
## auth
- [2026-04-01] Implement JWT authentication
```

**Example 2 — Second update to the same module**

User says "done" after adding refresh token rotation.

CLAUDE.md entry updated in-place (not appended):

```markdown
### Process Summary

- **auth**: JWT auth with refresh token rotation and concurrent-request protection → [details](.claude/process-summary/auth/summary.md)
```

Change history appended:

```markdown
## auth
- [2026-04-01] Add refresh token rotation with race condition handling
- [2026-04-01] Implement JWT authentication
```

**Example 3 — Retrieve module context**

User says "加载 auth 模块的上下文".

1. Run `scripts/retrieve.sh auth`
2. Present Overview and all Watch Out entries from `.claude/process-summary/auth/summary.md`
3. Suggest: "This module depends on redis. Load that module too?"
