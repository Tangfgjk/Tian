# 天机学堂 — 技术问题知识库

> 这不是聊天记录，而是一份按技术领域组织的、可长期维护的项目问题知识库。

## 📖 使用说明

每个问题条目包含：现象 → 定位过程 → 根因 → 解决方案 → 验证方法。

遇到问题时：
1. 先在对应分类文档中搜索错误关键词
2. 找不到再查"快速排错索引"
3. 仍无法解决则提新问题，由问题总结 Skill 整理入库

## 🗂️ 分类文档

| 文档 | 分类 | 内容 |
|------|------|------|
| [01-environment.md](./01-environment.md) | 环境与工具 | IDEA、Maven、Docker、PowerShell、Git |
| [02-configuration.md](./02-configuration.md) | 服务配置与启动 | Profile、Nacos、Bean、端口、启动顺序 |
| [03-middleware.md](./03-middleware.md) | 中间件 | MySQL、Redis、RabbitMQ、Elasticsearch |
| [04-business.md](./04-business.md) | 业务代码 | Gateway、Controller、Service、MyBatis、Feign |
| [05-methodology.md](./05-methodology.md) | 排错方法论 | 日志阅读、堆栈分析、网络定位、配置追踪 |

## 🔍 快速排错索引

| 关键词 | 跳转 |
|--------|------|
| `SocketTimeoutException` / `connect timed out` | [02-configuration.md](02-configuration.md) |
| `Connection refused` | [03-middleware.md](03-middleware.md) |
| `Cannot find bean` / `NoSuchBeanDefinitionException` | [02-configuration.md](02-configuration.md) |
| `profile: "dev"` / profile 不对 | [02-configuration.md](02-configuration.md) |
| `bootstrap.yml` / 配置文件加载顺序 | [02-configuration.md](02-configuration.md) |
| Maven 报红 / 依赖下载失败 | [01-environment.md](01-environment.md) |
| Docker 端口冲突 | [01-environment.md](01-environment.md) |
| `SQLSyntaxErrorException` | [03-middleware.md](03-middleware.md) |
| `Access denied for user` | [03-middleware.md](03-middleware.md) |
| `Failed to start bean` | [02-configuration.md](02-configuration.md) |
| `NacosException` | [02-configuration.md](02-configuration.md) |
| 配置改了但不生效 / Nacos 控制台 | [02-configuration.md](02-configuration.md) |

## 📝 问题状态说明

| 状态 | 含义 |
|------|------|
| ✅ 已解决 | 根因已确认，修复已验证 |
| 🔍 待验证 | 已定位根因，等待实际验证 |
| ⏳ 初步定位 | 已分析日志，尚未确定根因 |

---

> 最后更新：2026-08-05
