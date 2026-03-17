# PaperClaw Skills 润色计划

> 目标：让 PaperClaw 的 skills 体系完整覆盖科研工作流 7 个阶段，并提升现有 skill 的质量。
> 创建日期：2026-03-17

---

## 现状分析

| 项目 | 状态 |
|------|------|
| 已实现 Skills | 1 个 (`paperclaw-AI-ideation`) |
| 主文件行数 | 382 行 SKILL.md + 6 个参考文档 (967 行) |
| 覆盖阶段 | 仅 Stage 1 (Research Ideation) |
| 缺失阶段 | Stage 2-7 全部缺失 |

### 现有 Skill 问题清单

| 编号 | 问题 | 严重程度 |
|------|------|----------|
| E1 | ~~参考文档语言不统一 (4 篇中文 / 2 篇英文)~~ ✅ 已修复 | 中 |
| E2 | ~~缺少工具集成说明 (WebSearch 使用方式不明确)~~ ✅ 已修复 | 高 |
| E3 | ~~边界情况未处理 (冷门领域 / 并发工作 / 过时文献)~~ ✅ 已修复 | 中 |
| E4 | ~~Phase 0 过于抽象 (缺少示例问题和搜索模板)~~ ✅ 已修复 | 中 |
| E5 | ~~会议覆盖面窄 (仅 ML 会议，缺少 Nature/Science/PNAS 等期刊标准)~~ ✅ 已修复 | 中 |
| E6 | ~~各阶段缺少输出质量标准~~ ✅ 已修复 | 低 |

---

## 执行计划

### Phase A：润色现有 `paperclaw-AI-ideation`

> 预计工作量：中等 | 优先级：P0

#### A1. 参考文档语言统一 `[x]` ✅ 2026-03-17

已将 4 篇中文参考文档翻译为英文，同时移除了 `literature-search-strategies.md` 中的 Zotero MCP 相关内容。

#### A2. 补充工具集成说明 `[x]` ✅ 2026-03-17

在 SKILL.md 中新增 "Tool Usage by Phase" section，明确各阶段工具：

| 阶段 | 工具 | 用途 |
|------|------|------|
| Phase 0 | WebSearch | Quick field survey |
| Phase 1 | WebSearch | 搜索 10-15 篇论文 |
| Phase 2 | AskUserQuestion | 方向选择 |
| Phase 3 | WebSearch | 深度搜索 20-30 篇论文 |
| Phase 4 | AskUserQuestion | 确认研究问题 |
| Gate | AskUserQuestion | 展示评分卡 |
| 全程 | TodoWrite | 跟踪当前阶段进度 |

#### A3. 补充边界情况处理 `[x]` ✅ 2026-03-17

在 `references/iteration-loop.md` 新增 "Edge Case Protocols" section，覆盖三种场景：
- **Niche Topic** (<10 papers): 扩大搜索范围，降低论文数量要求至 5-8 篇
- **Concurrent Work Discovery**: 差异化分析 + Novelty 重新评分协议
- **Stale Literature** (>2 年无新进展): 成熟领域 vs. 被放弃领域判断标准

#### A4. Phase 0 具象化 `[x]` ✅ 2026-03-17

在 SKILL.md Phase 0 中：
- 5W1H checklist 改为表格，每个维度附带 2 个示例提问
- Quick Field Survey 添加搜索查询模板 (以 EEG emotion recognition 为例)
- 明确停止条件：能写出包含 What/Why/Who/How 的连贯段落即可

#### A5. 扩展会议/期刊覆盖 `[x]` ✅ 2026-03-17

在 `references/conference-readiness.md` 新增：
- Nature/Science/Cell 评审标准 + Significance 阈值调整 (≥4)
- PNAS 三审稿通道说明
- CVPR/ECCV/ICCV 视觉会议特点
- 期刊 vs. 会议选择决策树

#### A6. 各阶段输出质量标准 `[x]` ✅ 2026-03-17

在 SKILL.md 每个 Phase 末尾添加 "Output quality checklist"：
- Phase 0: 5W1H 覆盖度 + summary 具体程度
- Phase 1: 论文数量 + 时间跨度 + 方法多样性
- Phase 2: Direction 数量 + trade-off 分析 + 推荐理由
- Phase 3: 论文数量 + 比较矩阵 + Gap card 可操作性
- Phase 4: SMART 全覆盖 + 方法具体性 + 可证伪性

---

### Phase B：新建 `paperclaw-paper-writing`

> 预计工作量：大 | 优先级：P0 | 覆盖 Stage 4

#### 核心设计思路

从 ideation 输出的 `proposal.md` 无缝衔接，提供逐节写作指导。

#### 计划内容

- **B1. 主文件 SKILL.md** `[ ]`
  - Section-by-section 写作流程 (Title → Abstract → Intro → Method → Experiments → Conclusion)
  - 每节的写作 checklist 和常见陷阱
  - 逐节审查 + 整体一致性检查

- **B2. 参考文档** `[ ]`
  - `references/section-templates.md` — 各 section 的结构模板和示例
  - `references/writing-patterns.md` — 学术写作常用句式和过渡词
  - `references/figure-table-guide.md` — 图表规范 (caption 写法 / 排版标准)
  - `references/venue-style-guide.md` — 各会议 format 要求 (页数 / 引用格式 / 附录)

- **B3. 持久化状态** `[ ]`
  - `./writing/state.md` — 当前写作进度 (哪个 section, 第几轮修改)
  - `./writing/outline.md` — 论文大纲
  - `./writing/draft/` — 各 section 草稿

- **B4. 与 ideation 的衔接** `[ ]`
  - 自动读取 `./ideation/proposal.md` 作为写作输入
  - 将 proposal 的 Related Work 转化为 paper 的 Related Work section 骨架
  - 将 Experimental Plan 转化为 Experiments section 骨架

---

### Phase C：新建 `paperclaw-experiment-analysis`

> 预计工作量：大 | 优先级：P0 | 覆盖 Stage 3

#### 计划内容

- **C1. 主文件 SKILL.md** `[ ]`
  - 实验结果分析流程 (数据加载 → 统计检验 → 可视化 → 消融实验 → 结果表格生成)
  - 支持常见 ML 指标 (Accuracy, F1, AUC, BLEU, FID 等)
  - 统计显著性检验指导 (paired t-test, bootstrap, confidence intervals)

- **C2. 参考文档** `[ ]`
  - `references/statistical-tests.md` — 常用统计方法选择指南
  - `references/visualization-guide.md` — 学术图表最佳实践
  - `references/ablation-design.md` — 消融实验设计原则

- **C3. 与 paper-writing 的衔接** `[ ]`
  - 输出格式化的 results table (LaTeX ready)
  - 自动生成 figure caption 草稿
  - 生成 "Key findings" 摘要供 writing skill 引用

---

### Phase D：新建 `paperclaw-self-review` + `paperclaw-rebuttal`

> 预计工作量：中 | 优先级：P1 | 覆盖 Stage 5 + 6

#### D1. `paperclaw-self-review` `[ ]`

- 投稿前质量门控 (6 项检查)：
  1. Novelty claim 是否清晰且有支撑？
  2. 实验是否充分支持 claims？
  3. Writing 是否清晰无歧义？
  4. 引用是否完整且准确？
  5. 可复现性信息是否齐全？
  6. 格式是否符合目标会议要求？
- 模拟审稿人视角找弱点
- 输出 review report + 建议修改清单

#### D2. `paperclaw-rebuttal` `[ ]`

- 审稿意见解析 (逐条分类: factual error / misunderstanding / valid concern / suggestion)
- Point-by-point 回复模板
- 语气校准 (专业 / 感谢 / 坚定但不对抗)
- 修改追踪 (哪些意见导致了哪些修改)

---

### Phase E：新建 `paperclaw-post-acceptance` + 跨 Skill 集成

> 预计工作量：中 | 优先级：P2 | 覆盖 Stage 7 + 整体集成

#### E1. `paperclaw-post-acceptance` `[ ]`

- 会议 presentation 大纲生成 (15 min / 20 min / poster 三种模式)
- Poster 设计指导 (布局 / 字号 / 色彩方案)
- Social media 推广文案 (Twitter thread / LinkedIn post / 博客摘要)

#### E2. 跨 Skill 集成 `[ ]`

- **数据流串联**：定义各 skill 的输入输出接口
  ```
  ideation/proposal.md → paper-writing 输入
  experiment-analysis/results/ → paper-writing/experiments 输入
  paper-writing/draft/ → self-review 输入
  self-review/report.md → 修改指导
  reviewer-comments → rebuttal 输入
  ```
- **共享资源**：会议标准 references 跨 skill 复用
- **生命周期追踪**：在项目根目录维护 `./research-stage.md` 记录当前所处阶段

---

## 执行节奏

```
Phase A (润色 ideation)     ██████████  ✅ 完成
Phase B (paper-writing)     ░░░░░░░░░░
Phase C (experiment-analysis) ░░░░░░░░░░
Phase D (self-review + rebuttal) ░░░░░░░░░░
Phase E (post-acceptance + 集成) ░░░░░░░░░░
```

---

## 架构原则

每个新 skill 遵循统一架构：

```
.claude/skills/paperclaw-{name}/
├── SKILL.md              # 主文件 (200-400 行)
├── references/           # 参考文档 (按需加载)
│   ├── xxx.md
│   └── yyy.md
└── (无代码，纯 prompt 工程)
```

- SKILL.md 结构：Frontmatter → Overview → Workflow → 各 Phase 详细说明 → 状态管理 → 交互原则 → 参考文件列表
- 参考文档统一用英文
- 所有 skill 支持语言自适应输出 (language matching)
- 持久化目录命名：`./ideation/`, `./writing/`, `./analysis/`, `./review/`, `./rebuttal/`
