# CLAUDE.md Index Entry (Module-Level)

Each module gets exactly ONE line in CLAUDE.md. When updating, replace the existing line — never append a second entry for the same module.

## Format

```markdown
### Process Summary

- **${module_name}**: ${one_line_overview} → [details](.claude/process-summary/${module_name}/summary.md)
- **${module_name2}**: ${one_line_overview2} → [details](.claude/process-summary/${module_name2}/summary.md)
```

## Rules

- One line per module — update in place, do not append duplicates
- `${one_line_overview}`: concise description of what this module does (not what changed)
- Remove the section header `### Process Summary` if no modules exist yet; add it when creating the first entry
- Keep all entries under the same `### Process Summary` heading
