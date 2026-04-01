---
name: process-summary
description: 动态管理 Claude Code 开发中的项目上下文。通过维护轻量级索引，将详细架构知识持久化至模块化文件中。
metadata:
  version: 1.1.0
  author: bryan.song
---
## Principles & Constraints
- **Strict Factuality**: 仅记录客观事实（算法、接口、配置），禁止叙述性废话（如 "In this section...", "We decided to..."）。
- **Imperative Tone**: 必须使用祈使句（如 "Use X to Y", "Require Redis 6+"）。
- **Lean Index**: 强制 `CLAUDE.md` 保持在 120 行以内。
- **Atomic Operations**: 复杂逻辑通过调用 `scripts/` 中的脚本执行，确保执行的确定性。

## Workflows

### 1. Capture Mode (增量更新)
**Trigger**: 用户说 "done"、"更新项目记忆" 或检测到 Git 提交。
1. **分析**: 运行 `scripts/capture.sh`。若无返回，则询问用户修改了哪些文件。
2. **知识提取**:
   - 识别模块名：依据路径（如 `src/features/payment/`）或文件名。
   - 捕获 WHY、KEY LOGIC 和 WATCH OUT (风险/破坏性改动)。
   - 扫描 `import` 语句识别跨模块依赖。
3. **持久化**:
   - 检查目标模块文件行数，若 > 150 行，调用 `scripts/maintain.sh` 执行压缩算法。
   - 使用 `references/module_template.md` 结构写入新内容。
4. **索引**: 使用 `references/index_entry_template.md` 更新 `CLAUDE.md` 的 `Active Modules`。

### 2. Retrieve Mode (上下文加载)
**Trigger**: 用户开始新任务或询问特定模块。
1. **匹配**: 运行 `scripts/retrieve.sh <keyword>`。
2. **呈现**: 加载该模块的 Overview、最近 3 条变更以及所有历史记录中的 "Watch Out" 警示。
3. **递归加载**: 若存在跨模块依赖，建议用户同时加载相关上下文。

## Error Handling
- **No Git**: 回退至 `find -mtime -1` 扫描最近 24 小时修改的文件。
- **Name Collision**: 发现相似模块名（如 "user" 与 "user-profile"）时必须提示用户确认。
