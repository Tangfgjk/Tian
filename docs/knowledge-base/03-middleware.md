# 中间件

> MySQL、Redis、RabbitMQ、Elasticsearch、Nacos 等中间件相关问题

---

<!-- issue-id: MW-REDIS-PORT-001 -->
<!-- fingerprint: tj-promotion|redis|connection-failure|hardcoded-config -->

### [MW-REDIS-PORT-001] RedisConfig 硬编码连接地址

**状态：** ✅ 已解决
**模块：** `tj-promotion`
**技术标签：** Redis、Redisson、硬编码配置
**最后更新：** 2026-08-05

#### 问题现象

项目中有多处 Redis 配置，`tj-promotion` 模块使用了硬编码的 Redis 地址。

#### 根本原因

`tj-promotion/src/main/java/com/tianji/promotion/config/RedisConfig.java` 中直接写死了 Redis 连接地址：

```java
config.useSingleServer()
    .setAddress("redis://192.168.150.101:6379")
    .setPassword("123321");
```

环境变量无法覆盖此配置。

#### 解决方案

将硬编码地址改为 `127.0.0.1`，端口根据实际环境调整。

> ⚠️ 如果 `.env` 中 Redis 端口是 `16379`，此处端口也需对应修改。

#### 容易误判的地方

- `shared-redis.yaml` 中已配置了正确的 Redis 地址，但这个 `RedisConfig.java` 独立创建了一个 `RedissonClient`，不走 Nacos 配置
- 搜索 `Redisson.create` 或 `redissonClient` 找到所有 Redisson 配置点
