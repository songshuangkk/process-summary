# v2.x → v3.3 迁移指南

## 目标

将旧的变更日志摘要收敛为“当前知识 + 冷历史”，并建立可检索的 topic 拓扑。

## 步骤

1. 运行 `bash scripts/migrate-to-v3.sh .claude/process-summary`，统一为 v3 标题。
2. 将每个 topic 的当前职责、关键设计与不变量收敛到 `## 现状`。
3. 将仍有效的设计理由写到 `## 技术决策`，将风险写到 `## 注意事项`。
4. 创建 `.claude/process-summary/topology.tsv`：

   ```bash
   cp references/topology_template.tsv .claude/process-summary/topology.tsv
   ```

5. 每个 topic 建一行；先填 `topic`、`aliases`、`owners`，再补 API、表和事件。
6. 创建 `edges.tsv`，每条关系写为 `source / relation / target / evidence / verified_at`；证据必须是代码路径加精确锚点。
7. 运行 `bash scripts/topology.sh check`；所有摘要必须恰有一个节点，所有边与证据必须可解析。

## 迁移原则

- 不从旧历史中臆测关系；不确定的边先留空，待代码验证后补充。
- 不从摘要或 import 列表臆测关系；只有验证过代码锚点的关系才进入 `edges.tsv`。
- 后续任务中持续修正图谱，优先提升锚点和边的准确性，而不是增加无用节点。
