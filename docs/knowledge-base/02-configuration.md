# 服务配置与启动

> Profile、Nacos 配置、Bean 创建、端口冲突、启动顺序相关问题

---

<!-- issue-id: GW-NACOS-001 -->
<!-- fingerprint: tj-gateway|nacos|connection-failure|wrong-address -->

### [GW-NACOS-001] Gateway 连接 Nacos 超时

**状态：** ✅ 已解决
**模块：** `tj-gateway`
**技术标签：** Spring Boot、Nacos、Spring Profile、bootstrap.yml
**最后更新：** 2026-08-05

#### 问题现象

启动 `GatewayApplication`，Netty 成功启动在端口 10010，但随后报错退出：

```text
SocketTimeoutException: connect timed out
servers: [192.168.150.101:8848]
request: /nacos/v1/ns/instance/list failed
```

完整异常链：

```text
ApplicationContextException: Failed to start bean 'webServerStartStop'
  → UndeclaredThrowableException
    → NacosException: failed to req API:/nacos/v1/ns/instance after all servers
      → SocketTimeoutException: connect timed out
```

#### 根本原因

1. `bootstrap.yml` 中 `spring.profiles.active: dev`
2. `bootstrap-dev.yml` 中 Nacos 地址硬编码为 `192.168.150.101:8848`（原课程环境虚拟机）
3. 本机未配置环境变量覆盖，直接使用了远程地址

#### 定位过程

1. 搜索第一个 `ERROR`：`[NA] failed to request`
2. 发现目标地址：`servers: [192.168.150.101:8848]`
3. 确认异常类型：`SocketTimeoutException: connect timed out`
4. 回到启动日志开头确认 Profile：`The following 1 profile is active: "dev"`
5. 检查 `bootstrap-dev.yml` 中的 `server-addr` 配置

#### 解决方案

1. 在 IDEA Run Configuration 中设置环境变量覆盖 Nacos 地址

2. `bootstrap-dev.yml` 和 `bootstrap-local.yml` 中的 Nacos 地址改为 `127.0.0.1:8848`

3. 启动前先确保 Docker 中间件已运行

#### 验证方法

- 启动日志第一行显示 `profile: "local"`
- 日志中不再出现 `192.168.150.101`
- Nacos 控制台 `服务管理 → 服务列表` 中出现 `gateway-service`

#### 容易误判的地方

- 容易误判为"Nacos 没启动"，先去 `docker ps` 确认容器状态
- 如果 `192.168.150.101` 能 ping 通但 Nacos 端口不通，问题可能不同

#### 相关问题

- [ENV-MAVEN-PROFILE-001] Spring Boot 启动使用了错误的 Profile（本问题的前置问题）
- [CFG-BOOTSTRAP-001] bootstrap.yml 的作用及 dev/local 文件的分工（Profile 机制完整解释）

---

<!-- issue-id: CFG-BOOTSTRAP-001 -->
<!-- fingerprint: spring-cloud|bootstrap-config|config-error|profile-mechanism-unknown -->

### [CFG-BOOTSTRAP-001] bootstrap.yml 的作用及为什么有 dev/local 两个变体文件

**状态：** ✅ 已解决
**模块：** 所有模块
**技术标签：** Spring Cloud、bootstrap.yml、Profile、配置加载顺序
**最后更新：** 2026-08-05

#### 问题现象

项目中每个模块都有三个文件：`bootstrap.yml`、`bootstrap-dev.yml`、`bootstrap-local.yml`，不清楚它们的分工和加载机制。

#### 根本原因

对 Spring Cloud 的引导配置机制和 Profile 叠加机制不熟悉。

#### 定位过程

Spring Cloud 的配置加载链路：

```
bootstrap.yml                  ← 步骤 1：先加载（连接 Nacos 必需）
    ↓
根据 profile 叠加 bootstrap-{profile}.yml  ← 步骤 2：环境差异配置
    ↓
连接 Nacos，拉取 shared-configs            ← 步骤 3：远程共享配置
    ↓
加载 application.yml                        ← 步骤 4：本地业务配置
```

#### 核心机制

**bootstrap.yml** 是 Spring Cloud 的"引导配置"，在 application.yml **之前**加载。它只负责一件事：告诉应用 Nacos 在哪、需要拉哪些共享配置。

以 Gateway 为例（`tj-gateway/src/main/resources/bootstrap.yml`）：

```yaml
spring:
  profiles:
    active: dev              # 默认激活 dev
  application:
    name: gateway-service    # Nacos 中的服务名
  cloud:
    nacos:
      config:
        file-extension: yaml
        shared-configs:      # 从 Nacos 拉取这些
          - data-id: shared-spring.yaml
          - data-id: shared-redis.yaml
```

**三个文件不是三选一，而是叠加关系**：

| 文件 | 内容 | 何时加载 |
|------|------|----------|
| `bootstrap.yml` | 公共配置：服务名、端口、路由、共享配置列表 | 所有环境都加载 |
| `bootstrap-dev.yml` | Nacos 地址、注册 IP（原远程环境） | `profile=dev` 时叠加上去 |
| `bootstrap-local.yml` | Nacos 地址、注册 IP（本机环境） | `profile=local` 时叠加上去 |

**最终生效的配置 = bootstrap.yml + bootstrap-{profile}.yml + Nacos 远程配置 + application.yml + 环境变量覆盖**

#### 为什么需要变体文件

同一个项目在不同环境运行时，只有少数配置不同：

```
dev  环境：Nacos = 192.168.150.101:8848
local环境：Nacos = 127.0.0.1:8848
prod 环境：Nacos = nacos.prod.svc.cluster.local
```

把公共部分放 `bootstrap.yml`，差异部分放 `bootstrap-{profile}.yml`，切换环境只需改 `SPRING_PROFILES_ACTIVE` 一个值。

#### 本项目的实际问题

1. `bootstrap.yml` 中 `spring.profiles.active: dev` 是写死的默认值
2. 启动时未设置环境变量覆盖，自动加载了 `bootstrap-dev.yml`
3. `bootstrap-dev.yml` 中 Nacos 地址是远程 IP `192.168.150.101`
4. 所有连接超时的根因都是这个链路

#### 解决方案

设置环境变量 `SPRING_PROFILES_ACTIVE=local` 切换到本地配置，再配合其他环境变量覆盖 Nacos 和中间件地址。

#### 相关问题

- [ENV-MAVEN-PROFILE-001] Spring Boot 启动使用了错误的 Profile（操作层面的解法）
- [GW-NACOS-001] Gateway 连接 Nacos 超时（bootstrap.yml 选错 profile 导致的连锁故障）

---

<!-- issue-id: CFG-NACOS-IMPORT-001 -->
<!-- fingerprint: nacos|config-center|config-error|disk-vs-server -->

### [CFG-NACOS-IMPORT-001] 改了磁盘上的 Nacos 配置文件但未生效

**状态：** ✅ 已解决
**模块：** 所有模块
**技术标签：** Nacos、配置中心、import-nacos.ps1
**最后更新：** 2026-08-05

#### 问题现象

修改了 `nacos/DEFAULT_GROUP/shared-redis.yaml` 磁盘文件中的 Redis 地址为 `127.0.0.1`，但重启 Gateway 后 Redis 仍然连接 `192.168.150.101:6379`。

#### 根本原因

**Nacos 服务器不读磁盘文件**。Nacos 将配置存储在自己的内嵌数据库中：

```
nacos/DEFAULT_GROUP/shared-redis.yaml   ← 磁盘文件（源）
         ↓  import-nacos.ps1 一次性推送
Nacos 内嵌数据库                         ← Nacos 实际读取的地方
         ↓  服务启动时实时拉取
Gateway 获取 Redis 配置
```

修改磁盘文件不会自动同步到 Nacos 服务器。必须重新导入或手动在控制台修改。

#### 定位过程

1. 确认磁盘文件已改为 `127.0.0.1`
2. Gateway 启动日志仍显示 `Unable to connect to 192.168.150.101:6379`
3. 检查启动日志中拉取的 Nacos 配置列表，确认 shared-redis.yaml 来自 Nacos 远程
4. 打开 Nacos 控制台确认配置内容仍是旧值

#### 解决方案

修改磁盘文件后必须重新导入：

```powershell
cd docker-local
.\import-nacos.ps1
```

或在 Nacos 控制台（http://127.0.0.1:8848/nacos/）直接编辑发布。

#### 验证方法

1. Nacos 控制台中的 `shared-redis.yaml` 内容已更新
2. 重启 Gateway 后不再出现旧地址连接错误

#### 容易误判的地方

- 误以为改了磁盘文件就等于改了 Nacos 配置
- 反复检查代码和环境变量，却忽略了配置来源是 Nacos 服务器而非磁盘文件

#### 相关问题

- [GW-NACOS-001] Gateway 连接 Nacos 超时（Nacos 地址本身的配置）
