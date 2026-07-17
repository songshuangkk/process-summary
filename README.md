# Process Summary v3.2

个人本地 Claude Code 知识库：通过显式 topic 拓扑，以最小上下文定位业务事实、关键决策和已知风险。

## 设计

- `topology.tsv` 是机器路由层：输入 topic、代码路径、接口、表或事件，得到主 topic 和一跳关联节点。
- `summary.md` 是人类可读的当前知识层：现状、决策、风险与直接关系。
- 源码是最终事实源；高风险修改必须回读实现验证。

不要构建全量 import 图。只维护会影响任务判断的 API、数据、事件、状态机和模块边界。

## 安装与初始化

```bash
git clone https://github.com/songshuangkk/process-summary.git \
  ~/.claude/skills/process-summary

mkdir -p .claude/process-summary
cp ~/.claude/skills/process-summary/references/topology_template.tsv \
  .claude/process-summary/topology.tsv
```

## 常用命令

```bash
# 输出真实变更路径
bash scripts/capture.sh

# 拓扑解析与一跳关联检索
bash scripts/retrieve.sh module/topic
bash scripts/retrieve.sh /api/path
bash scripts/retrieve.sh table_name

# 拓扑完整性校验
bash scripts/topology.sh check

# 仅压缩一个摘要的变更历史
bash scripts/maintain.sh .claude/process-summary/module/topic/summary.md

# 单向迁移旧标题到 v3
bash scripts/migrate-to-v3.sh .claude/process-summary
```

## 项目结构

```text
process-summary/
├── SKILL.md
├── README.md
├── references/
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
