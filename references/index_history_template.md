# Change History Index (External File)

Location: `.claude/process-summary/index.md`

This file stores per-module change history, keeping CLAUDE.md lean.

## Format

```markdown
# Process Summary — Change History

## ${module_name}
- [${DATE}] ${change_title}
- [${DATE}] ${change_title}

## ${module_name2}
- [${DATE}] ${change_title}
```

## Rules

- Append new change entries under the corresponding module section
- Create a new `## ${module_name}` section when a module appears for the first time
- Changes are listed newest-first within each module section
- When this file exceeds 200 lines, run `scripts/maintain.sh .claude/process-summary/index.md` to compress
