# Process Summary

**Project memory management for Claude Code — because your CLAUDE.md deserves to stay readable.**

If you've used Claude Code on a real project for more than a few weeks, you know what happens. Your CLAUDE.md starts clean — a few lines of instructions, maybe some coding conventions. Then it grows. And grows. Three months in, you're staring at 300+ lines of accumulated context that's eating tokens, confusing the model, and slowing down every session.

Process Summary fixes this. It turns your CLAUDE.md into a lightweight **index** — one line per module — and stores the real knowledge in structured, modular files that Claude can load on demand.

## What it looks like

**Before** — everything crammed into one file:

```
CLAUDE.md  (347 lines, half of it stale)
```

**After** — lean index + modular detail files:

```
CLAUDE.md                              (12 lines, one per module)
.claude/process-summary/
├── index.md                           # full change history
├── auth/
│   └── summary.md                     # architecture, logic, gotchas
├── payment/
│   └── summary.md
└── user/
    └── summary.md
```

Your CLAUDE.md stays small. The details are always there when you need them.

## How it works

Two workflows, two commands.

### Capture — after finishing work

Say `done`, `save context`, or `capture` in Claude Code:

1. Scans `git diff` to find what changed
2. Extracts core logic, API chains, and risks
3. Writes a structured summary to `.claude/process-summary/{module}/summary.md`
4. Updates CLAUDE.md with **one line** for that module (replaced, never duplicated)
5. Appends to the external change history

### Retrieve — before starting new work

Say `retrieve {keyword}` or `加载模块 {keyword}`:

1. Searches module summaries for a match
2. Loads the overview and all historical risk warnings
3. Suggests loading related modules so you don't step on landmines

## Key ideas

- **CLAUDE.md is an index, not a journal.** Each module gets one line. Updates replace the old line — they don't pile up.
- **Knowledge lives close to the code.** Summaries are stored under `.claude/process-summary/`, organized by module.
- **Risk warnings are sacred.** When summaries get compressed, the "Watch Out" section is the last thing to go.
- **Progressive compression.** Recent changes stay detailed. Older entries get trimmed. The index file auto-compresses past 200 lines, summaries past 150.

## Quick start

### Install

Clone this repo into your Claude Code skills directory:

```bash
# If you use the default skills path
git clone https://github.com/songshuangkk/process-summary.git ~/.claude/skills/process-summary
```

Or add it as a subdirectory in your project and reference SKILL.md directly.

That's it. No config, no build step.

### Use it

**After completing a feature or refactor:**

```
You: done
Claude: *runs capture workflow, updates summaries and CLAUDE.md*
```

**Before starting a new task:**

```
You: retrieve auth
Claude: *loads auth module context, surfaces risks, suggests related modules*
```

## Real example

Say you just finished implementing JWT authentication. You say `done` in Claude Code.

A summary gets written to `.claude/process-summary/auth/summary.md`:

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

And your CLAUDE.md gets a single line:

```markdown
### Process Summary

- **auth**: JWT auth with refresh token rotation → [details](.claude/process-summary/auth/summary.md)
```

Next time you touch the auth module, that old entry gets **replaced** — not appended. Your CLAUDE.md stays at one line per module. Forever.

## Project structure

```
process-summary/
├── SKILL.md                            # Skill definition — this is what Claude reads
├── scripts/
│   ├── capture.sh                      # Finds changed files via git diff or mtime
│   ├── retrieve.sh                     # Searches module summaries by keyword
│   └── maintain.sh                     # Compresses files that exceed line limits
└── references/
    ├── module_template.md              # Template for summary files
    ├── index_entry_template.md         # Template for CLAUDE.md entries
    └── index_history_template.md       # Template for change history
```

## Compression strategy

Left unchecked, even modular summaries will bloat over time. Process Summary handles this automatically:

| Age | What happens |
|-----|-------------|
| Latest 3 entries | Kept in full — all details preserved |
| Entries 4–8 | Compressed to key points + risk warnings |
| Beyond entry 8 | Minimal index — just the date and title |
| Watch Out warnings | **Never dropped** — highest retention priority |

The `maintain.sh` script runs automatically when a summary exceeds 150 lines or the index exceeds 200.

## Principles

- **Facts only.** No narrative filler, no "we decided to..." — just what's true about the code.
- **Imperative tone.** "Use X to validate tokens" instead of "X is used for token validation."
- **Token budget.** One line per module in CLAUDE.md. Summaries capped at 150 lines. Index at 200.
- **Risk first.** Watch Out has the highest retention priority — never drop during compression.

## License

MIT
