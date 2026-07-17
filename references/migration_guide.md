# Process Summary v2.0 → v2.1 迁移指南

## 核心变化

从"**变更记录模式**"迁移到"**知识总结模式**"：

### v2.0 模式（变更记录）

```markdown
# Quality Context

## Overview
质检模块核心：状态机、Facade 层、错误码、来料检验执行链路

## Recent Changes

### [2026-07-15] 返工流程实现与状态重构
**Modified**: 12文件修改304行新增30行删除
**Why**: 删除WAIT_REWORK状态实现三维度分离
**Key Logic**: 新增ReworkInspectionTaskCreateListener监听排产返工事件
**Watch Out**: 状态机谓词需要同步更新

### [2026-07-14] 来料检 ERP 流程拆分
**Modified**: QualityIncomingErpService
**Why**: 解除 createOrder inspectionNo 冲突
**Key Logic**: assign ①②③ 检验申请保存/审核+检验单保存回写
**Watch Out**: ERP ④ 不可回滚 gap
```

### v2.1 模式（知识总结）

```markdown
# Quality 知识总结

> 最后更新: 2026-07-15

## 相关模块

**被依赖方**: biz, pad-incoming-inspection, purchase-inbound
**依赖方**: biz, scheduling
**核心链路**:
- scheduling → quality (返工检验任务创建)
- biz → quality (来料检 ERP 调用重构)

---

## 现状

### 核心职责
质检模块核心：状态机管理、Facade 层、错误码、来料检验执行链路、返工流程

### 关键设计

- **状态机三维度分离**：任务状态（WAIT_ASSIGN→WAIT_INSPECT→COMPLETED）、检验结果（overallResult）、处理方式（handleType）
- **返工流程**：监听排产返工事件 → 创建返工检验任务 → 跳过 WAIT_REWORK 状态直接完成任务
- **ERP 流程拆分**：assign ①②③（检验申请/审核+检验单保存）+ submit ④⑤（检验单审核+补填）

### 数据流

1. 排产返工事件触发 → TaskOperationReworkCreatedEvent
2. quality 监听器创建返工检任务 → 初始状态 WAIT_ASSIGN
3. 任务分配 → WAIT_INSPECT
4. 检验完成 → COMPLETED（跳过 WAIT_REWORK）

---

## 技术决策

| 决策 | 时间 | 理由 | 状态 |
|------|------|------|------|
| 三维度分离 | 2026-07-15 | 删除WAIT_REWORK状态，任务状态只管流程 | ✅ 有效 |
| 返工不等待审核 | 2026-07-15 | 简化流程，返工直接完成任务 | ✅ 有效 |
| ERP 流程拆分 | 2026-07-14 | 解除 inspectionNo 冲突，明确审计时机 | ✅ 有效 |
| ~~旧返工流程~~ | ~~2026-06-10~~ | ~~WAIT_REWORK 状态阻塞~~ | ❌ 已废弃 |

---

## 注意事项

- ⚠️ ERP ④⑤ 分支不可回滚，gap 待联调验证
- ⚠️ 状态机谓词需同步更新（canRouteToWaitReview, canRework）
- ⚠️ 来料检不能返工（CONCESSION_ACCEPT）

---

## 变更历史

### [2026-07-15] 返工流程实现与状态重构
**影响**: 新增"返工流程"设计，更新"状态机三维度分离"决策，废弃旧返工流程

### [2026-07-14] 来料检 ERP 流程拆分
**影响**: 新增"ERP 流程拆分"设计

---
```

---

## 迁移步骤

### 1. 提取技术决策

从历史变更中提取**WHY**（理由）和**WHAT**（做了什么），填入决策表：

```bash
# 原来的变更记录
### [2026-07-15] 返工流程实现与状态重构
**Why**: 删除WAIT_REWORK状态实现三维度分离

# 提取到决策表
| 删除WAIT_REWORK状态 | 2026-07-15 | 实现三维度分离 | ✅ 有效 |
```

### 2. 综合现状描述

把所有相关变更**合并**成"现在是怎么工作的"：

```bash
# 原来：分散在多个变更记录中
### [2026-07-15] 返工流程实现
### [2026-07-14] ERP 流程拆分
### [2026-07-10] resultValue 改造

# 现在：合并为一个"关键设计"部分
### 关键设计
- **状态机三维度分离**: ...
- **返工流程**: ...
- **ERP 流程拆分**: ...
- **resultValue String**: ...
```

### 3. 标记废弃决策

如果某个设计被新的替代了，**保留在决策表中**但标记为已废弃：

```markdown
| ~~旧返工流程~~ | ~~2026-06-10~~ | ~~WAIT_REWORK 状态~~ | ❌ 已废弃 |
```

好处：
- **保留历史**：知道以前是怎么做的
- **明确当前**：一眼看出哪些已经废弃
- **便于追溯**：出问题时可以对比前后设计

### 4. 简化变更历史

变更历史只保留**简短记录**，详细内容已上移到"现状"和"决策表"：

```markdown
## 变更历史

### [2026-07-15] 返工流程实现与状态重构
**影响**: 新增"返工流程"设计，更新"状态机三维度分离"决策

# 不再需要：
# **Modified**: 12文件修改304行新增30行删除
# **Key Logic**: 新增ReworkInspectionTaskCreateListener监听排产返工事件...
```

---

## 迁移检查清单

从 v2.0 迁移到 v2.1 时，逐项检查：

- [ ] 是否已添加"相关模块"部分？
- [ ] 是否已将"Overview"改为"现状"？
- [ ] 是否已将所有变更综合成"关键设计"？
- [ ] 是否已提取技术决策到决策表？
- [ ] 是否已标记废弃的决策？
- [ ] 是否已将详细变更记录简化为"影响"描述？
- [ ] 是否已将变更历史移到底部？
- [ ] 知识内容是否收敛（重复内容是否合并）？

---

## 常见问题

### Q: 我有几十条历史变更，都要手动迁移吗？

**A**: 不需要。**渐进式迁移**：

1. **只迁移最近1-2个月**的变更到"现状"部分
2. **旧变更保留在底部**的"变更历史"，作为参考
3. **下次修改时**自然就更新到新格式

### Q: 如果我不确定某个设计是否还有效怎么办？

**A**: 标记为"⚠️ 待确认"：

```markdown
| 某个设计 | 2026-05-10 | 理由 | ⚠️ 待确认 |
```

下次用到这个模块时，确认后更新状态。

### Q: 变更历史要保留多久？

**A**: 建议：
- **月度归档**：完整历史按月保存
- **summary.md**：只保留**最近3个月**的简短记录
- **超过3个月**的详细历史，只看月度归档文件

---

## 示例：完整迁移

### 迁移前（v2.0）

```markdown
# pad-incoming-inspection Context

## Overview
PAD 来料检验接口

## Recent Changes

### [2026-07-13] PAD 来料检接口对齐必检
**Modified**: PadIncomingInspectionController, QualityTaskIncomingPageQueryService
**Why**: 对标必检 /pad/quality-required
**Key Logic**: 8接口对标必检，写操作复用 QualityInspectionCommandAppService

### [2026-06-15] 来料检任务详情接口修复
**Modified**: PadIncomingInspectionAppService
**Why**: 详情接口字段不全
**Key Logic**: 补充5字段 + 2接口字段
```

### 迁移后（v2.1）

```markdown
# pad-incoming-inspection 知识总结

> 最后更新: 2026-07-13

## 相关模块

**依赖方**: biz, quality
**核心链路**:
- pad-incoming-inspection → quality (写操作复用 QualityInspectionCommandAppService)
- pad-incoming-inspection → biz (biz 独立 VO 不复用 my-tasks)

---

## 现状

### 核心职责
PAD 端来料检验接口：列表分页、详情查询、保存/提交/审核，对标必检接口 /pad/quality-required

### 关键设计

- **8接口对标必检**：GET /page, /detail, POST /save, /save-submit, /delete, /submit, /audit
- **CQRS 分离**：查询用 QualityTaskIncomingPageQueryService，写操作复用 QualityInspectionCommandAppService
- **按到货单聚合**：PadIncomingInspectionTaskDTO 补 status 字段
- **VO 独立不复用**：biz 独立 VO，不复用 my-tasks

### 数据流

1. 前端调用 GET /page → QualityTaskIncomingPageQueryService
2. 按到货单聚合 → PadIncomingInspectionTaskDTO
3. 写操作 → 复用 QualityInspectionCommandAppService

---

## 技术决策

| 决策 | 时间 | 理由 | 状态 |
|------|------|------|------|
| 对标必检接口 | 2026-07-13 | 统一来料检接口，减少维护成本 | ✅ 有效 |
| CQRS 分离 | 2026-07-13 | 查询按到货单聚合，避免 N+1 | ✅ 有效 |
| 复用写操作 | 2026-07-13 | 零新增代码，复用已有 CommandAppService | ✅ 有效 |
| ~~详情字段不全~~ | ~~2026-06-15~~ | ~~已补全5字段+2接口~~ | ✅ 已修复 |

---

## 注意事项

- ⚠️ 评审仅 CONCESSION_ACCEPT 来料检不能返工
- ⚠️ 复用 CommandAppService 需注意状态校验

---

## 变更历史

### [2026-07-13] PAD 来料检接口对齐必检
**影响**: 新增"8接口对标必检"设计，更新"CQRS分离"决策

### [2026-06-15] 来料检任务详情接口修复
**影响**: 补全详情字段，修复后标记为"✅ 已修复"

---
```

---

## 迁移收益

| 方面 | v2.0 | v2.1 |
|------|------|------|
| **理解当前状态** | 需要读所有历史变更 | 直接读"现状"部分 |
| **为什么这么做** | 散落在各条变更记录 | 集中在决策表 |
| **哪些已废弃** | 不明确 | 决策表明确标记 |
| **新人上手** | 从头读历史 | 直接看现状+决策表 |
| **知识维护** | 一直追加 | 更新现有描述 |
