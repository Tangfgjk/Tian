# 排错方法论

> 日志阅读技巧、堆栈分析方法、网络问题定位、配置追踪策略

---

<!-- issue-id: METHOD-LOG-001 -->
<!-- fingerprint: general|log-reading|spring-boot-exception|stack-trace -->

### [METHOD-LOG-001] Spring Boot 启动失败的日志阅读方法

**状态：** ✅ 已解决
**技术标签：** Spring Boot、异常堆栈、日志分析
**最后更新：** 2026-08-05

#### 核心原则

不要被几千行重复堆栈吓到，用 **三步定位法** 快速找到根因：

#### 第一步：找第一个 ERROR

搜索 `ERROR`，找到**时间最早的那条**，忽略后续所有重复：

```text
22:37:06.920-ERROR --- [hFetchJwkThread] com.alibaba.nacos.client.naming :
[NA] failed to request
java.net.SocketTimeoutException: connect timed out
```

后面几十条 ERROR 都是同一原因的重试，不需要读。

#### 第二步：提取目标信息

从第一条错误中提取：

| 信息 | 来源 |
|------|------|
| 目标地址 | `servers: [192.168.150.101:8848]` |
| 异常类型 | `SocketTimeoutException` |
| 操作类型 | `connect timed out` |
| 失败 API | `/nacos/v1/ns/instance/list` |

#### 第三步：找 Caused by 链条末端

Spring Boot 异常通常是嵌套的：

```text
ApplicationContextException  ← 最外层（Spring 包装）
  → UndeclaredThrowableException
    → NacosException          ← 业务层
      → SocketTimeoutException ← 最底层根因
```

**Caused by 越往下越接近根本原因**。

#### 补充：关注 Profile 声明

启动日志的前 20 行通常包含关键信息：

```text
The following 1 profile is active: "dev"
```

这行告诉你实际使用的配置环境，是排查配置问题的第一步。

#### 容易忽略但重要的日志

- `Located property source` — 列出了所有加载的 Nacos 配置文件
- `Netty started on port` — 确认成功启动的端口
- `ConditionEvaluationReportLoggingListener` — Bean 条件装配报告
