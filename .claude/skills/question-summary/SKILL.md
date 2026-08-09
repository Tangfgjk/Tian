# 技术问答助手 + 项目问题知识库维护器

## ⚠️ 强制触发规则

**每次回答完用户的技术问题后，必须自动执行本 Skill 的"第二阶段 → 第六阶段"**，完成问题归档。

以下情况**必须触发**：

- 用户贴了报错日志并得到分析解决
- 用户问了"为什么XXX连不上/启动失败/报错"并得到根因分析
- 用户问了"XXX是什么意思/为什么这样设计"并涉及项目具体机制
- 用户修改了配置文件/代码后问题得到解决
- 任何涉及排查、定位、修复的技术对话

以下情况**不需要触发**：

- 纯闲聊、纯确认状态（如"这是成功了吗"只需回答是/否）
- 用户明确说不需要记录

## 核心原则

1. **先回答问题，再整理文档** — 不能让文档生成先于问题解决
2. **模型负责理解，工具负责修改** — 用 Grep/Read/Edit 精确操作，不手写正则解析
3. **不保存推测为结论** — 未验证的根因标记为"待验证"
4. **不重复、不覆盖、不丢数据** — 四个更新策略
5. **每次回答完问题必须归档** — 不可遗漏，形成肌肉记忆

## 工作流程

### 第一阶段：问题分析

收到用户问题后，按以下步骤分析：

1. **确认上下文** — 读取用户提供的日志、代码、配置
2. **定位第一个有效错误** — 搜索 `ERROR`，找到时间最早的那条
3. **追踪异常链** — 逐层向下找 `Caused by`，直到最底层根因
4. **提取关键信息** — 目标地址/端口、配置文件、模块名、异常类型
5. **给出解决方案** — 具体的、可操作的步骤
6. **提供验证方法** — 如何确认问题已解决

回答格式：

```
## 🔍 错误定位
[关键日志片段]

## 🎯 根本原因
[一句话说明]

## ✅ 解决方法
[步骤 1]
[步骤 2]
...

## 🔄 验证方法
[如何确认已解决]
```

### 第二阶段：问题结构化

解决问题后，生成以下结构化对象：

```json
{
  "issue_id": "<MODULE>-<COMPONENT>-<NNN>",
  "title": "<简短描述>",
  "category": "<01-environment|02-configuration|03-middleware|04-business|05-methodology>",
  "category_file": "<对应的 Markdown 文件名>",
  "module": "<所属模块>",
  "status": "<已解决|待验证|初步定位>",
  "symptom": "<一条问题现象>",
  "exception_type": "<异常大类：connection-failure|config-error|bean-error|port-conflict|...>",
  "root_cause": "<一句根因>",
  "solution_steps": ["步骤1", "步骤2"],
  "verification": ["验证方法"],
  "tags": ["标签1", "标签2"],
  "fingerprint": "<module>|<component>|<error-category>|<root-cause-category>",
  "related_issues": ["GW-NACOS-001"]
}
```

**ID 命名规则**：
- 模块缩写-组件缩写-序号
- 模块缩写：`GW`(gateway), `ENV`(环境), `MW`(中间件), `BIZ`(业务), `METHOD`(方法论)
- 序号从 001 开始递增

**异常大类映射**（fingerprint 使用，不用具体异常类名）：
- 连接失败 → `connection-failure`
- 配置错误 → `config-error`
- Bean 创建失败 → `bean-error`
- 端口冲突 → `port-conflict`
- 权限拒绝 → `access-denied`
- 超时 → `timeout`
- SQL 错误 → `sql-error`

**分类文件映射**：

| category | 文件 |
|----------|------|
| 01-environment | `docs/knowledge-base/01-environment.md` |
| 02-configuration | `docs/knowledge-base/02-configuration.md` |
| 03-middleware | `docs/knowledge-base/03-middleware.md` |
| 04-business | `docs/knowledge-base/04-business.md` |
| 05-methodology | `docs/knowledge-base/05-methodology.md` |

### 第三阶段：知识库检索

在写入之前，用 **Grep** 搜索知识库：

```bash
# 搜索相同 issue-id
grep -r "issue-id: <issue_id>" docs/knowledge-base/

# 搜索相同 fingerprint
grep -r "fingerprint: <fingerprint>" docs/knowledge-base/

# 搜索类似标题或关键词
grep -rn "<关键词>" docs/knowledge-base/ --include="*.md"
```

### 第四阶段：决定更新策略

根据检索结果，选择以下四种策略之一：

| 策略 | 条件 | 操作 |
|------|------|------|
| **新建** | 无相同 ID、无相同指纹 | 在对应分类文件末尾追加新条目 |
| **合并** | 相同指纹或相同根因 | 用 Edit 更新已有条目的现象/方案/验证方法 |
| **新增子案例** | 相同异常大类但根因不同 | 在新条目中用"相关问题"链接到旧条目 |
| **建立关联** | 不同问题但有因果关系 | 在两个条目中互相添加"相关问题"链接 |

**合并时只更新这些字段**：
- 补充新的"问题现象"
- 补充"解决方案"中的新步骤
- 更新"最后更新"日期
- 如果之前是"待验证"现在已确认，更新状态为"已解决"

### 第五阶段：写入知识库

用 **Read** + **Edit** 工具操作文件。

**新建条目**：用 Read 读取分类文件末尾，确认插入位置，然后用 Edit 在最后一个 `---` 分隔线之后追加新条目。

**合并条目**：用 Grep 定位 `<!-- issue-id: xxx -->`，用 Read 读取该条目完整内容，然后用 Edit 精确替换需要更新的字段。

**更新 README.md**：如果新增了问题，检查 README.md 的"快速排错索引"是否需要补充新的关键词映射。

### 第六阶段：向用户汇报（必须执行，不可省略）

每次完成问题归档后，**必须**以以下格式输出：

```markdown
📝 **问题已归档**

| 项目 | 内容 |
|------|------|
| 操作 | 新建 / 合并 / 关联 |
| 文档 | `docs/knowledge-base/0X-xxx.md` |
| 条目 | **[ID]** 标题 |
| 指纹 | `module\|component\|error-category\|root-cause-category` |

📊 知识库当前：`01-environment(3) 02-configuration(3) 03-middleware(1) 04-business(0) 05-methodology(1) = 共 N 条`
```

**如果没有新增条目**（例如纯闲聊、状态确认），也要输出一行：

```markdown
📝 本次无需归档（[原因]）
```

**这一阶段是强制性的，不可因为"用户已经知道答案"或"刚才讨论过了"而跳过。**

## 条目模板

每个新建条目使用以下 Markdown 模板：

```markdown
<!-- issue-id: XXX-XXX-XXX -->
<!-- fingerprint: module|component|error-category|root-cause-category -->

### [XXX-XXX-XXX] 标题

**状态：** 状态
**模块：** 所属模块
**技术标签：** 标签1、标签2
**最后更新：** YYYY-MM-DD

#### 问题现象

简要描述 + 关键日志片段

#### 根本原因

一句话说明根因

#### 定位过程

1. 步骤1
2. 步骤2

#### 解决方案

具体可操作的修复步骤

#### 验证方法

如何确认问题已解决

#### 容易误判的地方

（可选）常见的错误排查方向

#### 相关问题

（可选）链接到知识库中的其他条目
```

## 分类体系

### 01-environment — 环境与工具
IDEA 配置、Maven 构建、Docker 使用、PowerShell 脚本、Git 操作、JDK 配置

### 02-configuration — 服务配置与启动
Spring Profile、Nacos 配置中心、Bean 创建失败、端口冲突、启动顺序、bootstrap/application 配置

### 03-middleware — 中间件
MySQL 连接/导入、Redis/Redisson、RabbitMQ、Elasticsearch、Nacos 服务端、MinIO、MongoDB、XXL-JOB

### 04-business — 业务代码
Gateway 路由/过滤器、Controller/REST API、Service 层、MyBatis/数据库操作、Feign 远程调用、认证鉴权、状态机、消息处理

### 05-methodology — 排错方法论
Spring Boot 日志阅读、异常堆栈分析、网络连通性定位、配置追踪、性能问题排查、调试技巧

## 分类规则

遇到以下情况可以调整分类：

1. **新建二级分类**：同一一级分类下某组件相关问题积累 ≥ 3 条时，可新建二级标题
2. **条目跨类**：属于多个分类时，放在最相关的分类，在另一分类下用"相关问题"链接
3. **分类不确定**：优先归类到"相关性最高"的分类，宁可在 tags 中多打标签

## 禁止事项

- ❌ 不把每轮聊天原文追加到文档
- ❌ 不重复创建同一个问题（检查 issue-id 和 fingerprint）
- ❌ 不把 WARN/SKIPPED 误判为根因
- ❌ 不把未验证的推测标记为"已解决"
- ❌ 不因为标题不同就认定是新问题
- ❌ 不大范围改写用户手工修改的内容
- ❌ 不删除旧的有效解决方案
- ❌ 不自动修改项目代码（除非用户明确要求）
- ❌ 不保存密码、Token、密钥等敏感值
- ❌ 不保留超过 10 行的重复堆栈日志

## 使用示例

### 示例 1：新建问题

```
用户："Gateway 启动报 connect timed out 怎么处理？"

Skill 流程：
1. 分析日志 → 定位 bootstrap-dev.yml 中 Nacos 地址错误
2. 给出解决方案
3. 结构化 → issue_id: GW-NACOS-001
4. Grep 搜索 → 无相同条目
5. 在 02-configuration.md 末尾追加
6. 更新 README.md 快速索引
7. 汇报：📝 已新建 GW-NACOS-001
```

### 示例 2：合并补充

```
用户："又是 Nacos 连接超时，但这次是 namespace 不对"

Skill 流程：
1. 分析 → 同一异常大类但根因不同
2. Grep 搜索 → 找到 GW-NACOS-001
3. 决定 → 新增子案例（不是合并，因为根因不同）
4. 新建 GW-NACOS-002，在"相关问题"链接到 GW-NACOS-001
```
