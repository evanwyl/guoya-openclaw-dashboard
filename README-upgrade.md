# OpenClaw Dashboard 升级开发 README

## 1. 项目定位

本次任务不是从 0 重写 dashboard，  
而是 **基于现有 `openclaw-dashboard` 仓库做增量升级**。

目标是：

- 保留现有已可用能力
- 重构 UI 和信息架构
- 新增多 agent 可视化能力
- 新增 Feishu routing / 绑定关系可视化
- 新增 plugin 状态页
- 新增 Connection Mode / Data Sources 展示
- 强化 model usage / token / cost 能力
- 增加新群排障卡片
- 视觉风格融合两个 dashboard，优先参考第二个 dashboard 的配色与卡片体系

---

## 2. 仓库信息

### 仓库实际路径
`<project-root>`

### 当前项目结构
```text
<project-root>
├── .git/
├── .gitignore
├── README.md
├── README-upgrade.md
├── RELEASE_NOTES.md
├── index.html
├── server.js
├── install.sh
├── disk-history.json
├── data/
│   └── health-history.json
├── docs/
│   ├── costs.png
│   ├── feed.png
│   ├── limits.png
│   ├── logs.png
│   ├── overview.png
│   ├── screenshot.png
│   └── sessions.png
└── scripts/
    ├── parse-claude-usage.py
    └── scrape-claude-usage.sh
```

### 关键判断
当前项目不是典型前后端分离结构，核心代码主要集中在：

- `index.html`：前端主页面 / UI / 交互入口
- `server.js`：后端服务 / 数据聚合 / API / 系统能力入口
- `scripts/`：usage 抓取相关脚本
- `data/`：部分历史数据缓存
- `docs/`：文档截图，不是业务代码

**明确要求：**
- 所有改造基于以上现有项目结构进行
- **禁止新建一个平行 dashboard 项目重做**
- 如果需要拆分前端模块，也必须在现有仓库内演进完成

---

## 3. 本次升级总原则

### 3.1 必须坚持
- 不从 0 重写
- 先盘点再改造
- 先信息架构再补页面
- 优先复用现有 API / 数据逻辑 / 展示逻辑
- 尽量不在第一阶段做大规模底层重构

### 3.2 禁止事项
- 禁止新起一个同类项目并迁移
- 禁止在没搞清现有能力前直接重写 UI
- 禁止为了页面美观牺牲现有可用功能
- 禁止先做零散页面、后补数据模型
- 禁止把两个 dashboard 的视觉元素生硬拼接成两套风格

---

## 4. 现有能力：必须保留

以下能力属于现有资产，升级过程中必须保留：

- Session 查看能力
- Logs 查看 / 解析能力
- Cron 查看能力
- Per-model token / usage / cost 能力
- Auth 相关能力
- Restart / service control 相关能力
- Live feed / health / system 状态等已有监控能力
- 现有 Claude / Gemini usage 统计能力

---

## 5. 本次必须新增的能力

### 5.1 多 Agent 总览
至少包含：

- agent 列表
- 在线 / 离线 / 异常状态
- 最近活跃时间
- 关联 session / thread 概览
- 所属 channel / provider
- 消耗摘要（如可获取）

目标：
让用户一眼看清系统里有哪些 agent、哪些在跑、哪些异常。

---

### 5.2 Feishu Routing / 绑定关系页
至少包含：

- chat / group / thread 与 agent 的绑定关系
- routing 规则展示
- 当前消息流向说明
- provider / surface / account 信息
- 群聊 / 私聊 / thread 区分
- 常见路由异常排查入口

目标：
让用户看懂“为什么这条消息会由这个 agent 接住”。

---

### 5.3 Plugin 状态页
至少包含：

- 已安装 plugin 列表
- plugin 状态（启用 / 禁用 / 异常）
- 作用范围
- 最近错误 / 健康状态
- plugin 与 agent / channel 的关联（如有）

目标：
避免 plugin 成为黑盒。

---

### 5.4 Connection Mode / Data Sources 说明
至少包含：

- 当前 dashboard 连接的 OpenClaw 实例
- 数据来源说明
- 当前连接模式
- 依赖项健康状态
- 数据缺失原因提示

目标：
减少“有数据不知道哪来的、没数据不知道为什么”。

---

### 5.5 Model Usage / Token / Cost 强化
至少包含：

- 按模型维度统计
- 按 agent 维度统计
- 按时间维度趋势
- 高消耗 session / agent 识别
- 总览页 cost 摘要卡片
- 异常消耗提示

目标：
把 cost 页从“查看页”升级成“分析页”。

---

### 5.6 新群排障卡片
至少包含：

- 新群是否被识别
- 是否已绑定 agent
- 是否命中 routing
- 是否有 auth / permission 问题
- 是否有 plugin / provider 异常
- 是否有消息进入但未响应
- 快速跳转相关日志

目标：
快速定位“新群为什么没反应”。

---

## 6. 页面结构重构目标

建议重构为“系统控制台 / 运营控制台”风格，而不是调试页面拼装。

## 6.1 视觉风格要求

界面风格采用 **两个 dashboard 融合** 的方式：

- 功能结构沿用现有 `openclaw-dashboard`
- 视觉风格优先参考第二个 dashboard
- 重点吸收第二个 dashboard 的：
  - 配色体系
  - 卡片样式
  - 页面留白
  - 字体层级
  - 图表视觉语言
  - 状态标签样式
  - 导航栏质感

明确要求：
- 保留第一个 dashboard 的功能骨架
- 吸收第二个 dashboard 的视觉风格
- 最终统一成一套设计语言
- 不要做成两个风格硬拼接

### 建议一级导航
- Overview
- Agents
- Sessions / Logs
- Feishu Routing
- Plugins
- Models / Cost
- Cron / Jobs
- Troubleshooting
- Settings / Connection

---

## 7. 页面职责说明

### 7.1 Overview
展示全局摘要：

- agent 数量与状态
- 活跃 session 数
- 最近异常
- 模型消耗摘要
- Feishu routing 摘要
- cron / service 健康状态

### 7.2 Agents
展示：

- agent 列表
- agent 状态
- agent 详情
- agent 与 session / channel / provider 的关系
- 最近活动

### 7.3 Sessions / Logs
保留现有核心能力并统一入口：

- session 列表
- session 详情
- logs 查询
- agent / channel / 时间维度筛选

### 7.4 Feishu Routing
展示：

- 群 / 会话 / thread 绑定
- routing 规则
- 路由命中结果
- 相关异常与日志跳转

### 7.5 Plugins
展示：

- plugin 列表
- plugin 状态
- 健康状态
- 错误摘要
- 作用对象

### 7.6 Models / Cost
展示：

- model usage
- token 统计
- cost 统计
- agent / 时间筛选
- 消耗异常识别

### 7.7 Troubleshooting
展示：

- 新群排障卡片
- 常见接入异常
- 常见错误快速入口
- 关键日志跳转

### 7.8 Settings / Connection
展示：

- 当前连接实例
- 连接模式
- 数据源说明
- auth / restart / service control 入口

---

## 8. 代码与文件改造要求

### 8.1 当前核心文件
本次优先关注这些文件：

#### 前端主入口
- `<project-root>/index.html`

#### 后端主入口
- `<project-root>/server.js`

#### usage 抓取脚本
- `<project-root>/scripts/scrape-claude-usage.sh`
- `<project-root>/scripts/parse-claude-usage.py`

#### 历史数据
- `<project-root>/data/health-history.json`
- `<project-root>/disk-history.json`

### 8.2 改造原则
- 优先在 `index.html` 中重构页面结构和导航
- 优先在 `server.js` 中扩展/复用数据接口
- 如果前端逻辑过于集中，可在仓库内新增 `assets/`、`js/`、`css/` 或 `src/` 目录做整理
- 但必须是**在当前仓库内渐进演进**
- 不得以“重构方便”为由另开平行项目

### 8.3 Phase 1 必须输出的文件定位结果
在正式开发前，必须先明确：

- `index.html` 中：
  - Overview 相关区域
  - Sessions / Logs 相关区域
  - Cost / Usage 相关区域
  - Navigation 相关结构
- `server.js` 中：
  - sessions 数据来源
  - logs 数据来源
  - cron 数据来源
  - model usage / cost 数据来源
  - auth / restart / service control 相关接口
- 哪些内容可以直接复用
- 哪些内容需要新增接口或整理数据结构

---

## 9. 数据设计原则

所有新增视图尽量围绕以下核心对象展开：

- agent
- session
- chat / thread
- plugin
- model usage
- cron / job
- connection / data source

### 要尽量打通的关系
- `agent -> session`
- `agent -> chat/channel`
- `chat -> routing -> agent`
- `plugin -> status/error`
- `agent -> usage/cost`
- `chat/group -> troubleshooting`

目标：
用户可以从“异常现象”一路点到“具体原因”。

---

## 10. 推荐开发顺序

### Phase 1：现状盘点
先做，不要直接大改页面。

必须产出：

1. 当前已有页面 / 模块盘点
2. 当前已有接口 / 数据来源盘点
3. 当前已有可复用能力盘点
4. 当前目录结构与核心文件说明
5. 改造涉及文件清单

#### Phase 1 输出物
- 功能盘点表
- 页面结构草图
- 文件改造清单

---

### Phase 2：信息架构重构
先重构导航和组织方式：

- 定义一级导航
- 明确 Overview 信息结构
- 明确 Agents / Routing / Plugins / Cost 页面归属
- 统一筛选和跳转逻辑

#### Phase 2 输出物
- 新导航结构
- 页面路由/切换关系
- 页面间跳转图

---

### Phase 3：核心页面改造
优先完成：

- Overview
- Agents
- Sessions / Logs
- Feishu Routing

这是第一优先级。

---

### Phase 4：专题页补充
继续完成：

- Plugins
- Models / Cost
- Settings / Connection

---

### Phase 5：排障和细节完善
最后完成：

- Troubleshooting
- 新群排障卡片
- 空状态 / 错误提示
- 小交互优化

---

## 11. 优先级

### P0
- Dashboard 总览重构
- 多 agent 列表 / 状态
- Sessions / Logs 统一入口
- Feishu routing 展示

### P1
- Plugin 状态页
- Connection mode / data source 页
- Agent 详情页完善

### P2
- Cost 页面强化
- 新群排障卡片
- 告警 / 提示 / 交互优化

---

## 12. 验收标准

### 12.1 现有能力不能丢
以下能力必须仍然可用：

- sessions
- logs
- cron
- cost
- auth
- restart

### 12.2 新增能力必须落地
必须能看到：

- 多 agent 总览与状态
- agent 与 session / channel 的关系
- Feishu routing / 绑定关系
- plugin 状态
- connection mode / data source
- 增强后的 model usage / token / cost 视图
- 新群排障卡片

### 12.3 UI / 体验要求
- 页面结构比当前版本更清晰
- 更像控制台，不像功能拼盘
- 空数据要有解释，不是纯空白
- 用户能从 Overview 快速进入问题排查路径

---

## 13. 本轮开发前必须先确认的内容

正式进入开发前，先提交以下内容：

1. 当前功能盘点表
2. 新版信息架构图
3. 改造涉及文件清单
4. 分阶段开发计划
5. 风险点说明

**未确认前，不要直接大规模开工。**

---

## 14. 一句话执行要求

基于 `<project-root>` 现有代码继续升级，  
以 `index.html` 和 `server.js` 为核心改造入口，  
保留现有 session / logs / cron / cost / auth / restart 等能力，  
完成多 agent、Feishu routing、plugin、connection mode、cost 强化和新群排障能力的增量升级，  
**禁止新起平行项目重做。**
