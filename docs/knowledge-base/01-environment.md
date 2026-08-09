# 环境与工具

> IDEA、Maven、Docker、PowerShell、Git 相关问题

---

<!-- issue-id: ENV-DOCKER-PORT-001 -->
<!-- fingerprint: docker|port-mapping|wrong-port|env-config -->

### [ENV-DOCKER-PORT-001] Docker 容器端口映射与 Nacos 配置端口不一致

**状态：** ✅ 已解决
**模块：** `docker-local`
**技术标签：** Docker、端口映射、.env
**最后更新：** 2026-08-05

#### 问题现象

本地 Docker 启动了 MySQL（13306）和 Redis（16379），但微服务启动时仍然连不上。

#### 根本原因

`.env` 中端口映射到了非默认端口（MySQL: 13306, Redis: 16379），但环境变量未传递给 IDEA Run Configuration，微服务使用了 Nacos 配置文件中的默认端口（MySQL: 3306, Redis: 6379）。

#### 定位过程

1. 检查 `.env` 确认实际映射端口
2. 检查 IDEA Run Configuration 的 Environment variables
3. 确认环境变量 `TJ_JDBC_PORT` 和 `TJ_REDIS_PORT` 未设置

#### 解决方案

在 IDEA Run Configuration 中设置完整环境变量覆盖默认端口：

```
TJ_JDBC_PORT=13306
TJ_REDIS_PORT=16379
```

#### 验证方法

启动任意微服务，日志中不再出现 MySQL/Redis `Connection refused`。

#### 容易误判的地方

- 端口映射错误容易被误判为"密码错误"或"容器未启动"
- 先 `docker ps` 确认容器在运行，再检查端口，最后检查密码

---

<!-- issue-id: ENV-PS-SCRIPT-001 -->
<!-- fingerprint: powershell|script-execution|path-error|cwd-wrong -->

### [ENV-PS-SCRIPT-001] PowerShell 脚本路径错误

**状态：** ✅ 已解决
**模块：** `docker-local`
**技术标签：** PowerShell、工作目录
**最后更新：** 2026-08-05

#### 问题现象

```powershell
.\start-infra.ps1 : 无法将".\start-infra.ps1"项识别为 cmdlet...
```

#### 根本原因

在项目根目录执行了脚本，但脚本位于 `docker-local/` 子目录下。

#### 解决方案

```powershell
cd docker-local
.\start-infra.ps1
```

或使用完整路径：

```powershell
.\docker-local\start-infra.ps1
```

---

<!-- issue-id: ENV-MAVEN-PROFILE-001 -->
<!-- fingerprint: maven|profile-config|wrong-profile|spring-boot -->

### [ENV-MAVEN-PROFILE-001] Spring Boot 启动使用了错误的 Profile

**状态：** ✅ 已解决
**模块：** 所有模块
**技术标签：** Spring Boot、Profile、bootstrap.yml、环境变量
**最后更新：** 2026-08-05

#### 问题现象

启动日志显示 `The following 1 profile is active: "dev"`，但期望使用 `local`。

#### 根本原因

`bootstrap.yml` 中写死了 `spring.profiles.active: dev`。环境变量未覆盖时默认使用 `dev`。

#### 解决方案

在 IDEA Run Configuration 的 Environment variables 中设置：

```
SPRING_PROFILES_ACTIVE=local
```

#### 验证方法

启动日志第一行显示：`The following 1 profile is active: "local"`

#### 相关问题

- [GW-NACOS-001] Gateway 连接 Nacos 超时（dev Profile 导致的连锁问题）
