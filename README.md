# 天机学堂

#### 提前说明
我保留大量代码注释，也保留了测试文件，帮助大家更好的吸收，感兴趣的可以克隆参考学习，有不对的地方欢迎大家指正！！

- 分支说明：
- init分支包含最基础功能，所有人刚开始开发都从init分支拉取
- master分支为功能完善的完整源代码，作参考使用(这里未上传，配套资料中有)
- dev分支为本人基于init分支学习并正在开发的分支(未完成)
- [学习文档地址](https://b11et3un53m.feishu.cn/wiki/wikcnrigEuKkRaba6YaZubSuINf)
- [配套资料](https://pan.baidu.com/s/1xH1_5-rp28TSpZz97fmdBg?pwd=1024)

 **🌟对你有帮助的话麻烦点个星星🌟** 
#### 项目简介
天机学堂是一个基于微服务架构的生产级在线教育项目，核心用户不是K12群体，而是面向成年人的非学历职业技能培训平台。相比之前的项目课程，其业务完整度、真实度、复杂度都非常的高，与企业真实项目非常接近。
通过天机学堂项目，你能学习到在线教育中核心的学习辅助系统、考试系统，电商类项目的促销优惠系统等等。更能学习到微服务开发中的各种热点问题，以及不同场景对应的解决方案。学完以后你会收获很多的“哇塞”。

#### 软件架构
天机学堂目前是一个B2C类型的教育网站，因此分为两个端：
- 后台管理端
- 用户端（PC网站）
整体架构如下：
![天机学堂功能](https://foruda.gitee.com/images/1700665982521373114/93d9dd7b_8078688.png "天机学堂功能")
 **技术架构：** 
![天机学堂架构](https://foruda.gitee.com/images/1700666042713339262/1be5f686_8078688.png "天机学堂技术架构")
#### 主流程介绍
 **功能演示**
 
天机学堂分为两部分：

- 学生端：其核心业务主体就是学员，所有业务围绕着学员的展开
- 管理端：其核心业务主体包括老师、管理员、其他员工，核心业务围绕着老师展开

 **老师核心业务** 
![输入图片说明](https://foruda.gitee.com/images/1700666391329708364/9774ad8b_8078688.png "屏幕截图")
虽然流程并不复杂，但其中包含的业务繁多，例如：
课程分类管理：课程分类的增删改查
媒资管理：媒资的增删改查、媒资审核
题目管理：试题的增删改查、试题批阅、审核
课程管理：课程增删改查、课程上下架、课程审核、发布等等

学员核心业务
学员的核心业务就是买课、学习，基本流程如下：
![输入图片说明](https://foruda.gitee.com/images/1700666459641565715/49dd9370_8078688.png "屏幕截图")
#### 我可以学到什么？
相当于学到了三个项目
![输入图片说明](https://foruda.gitee.com/images/1700666508901694539/13af7161_8078688.png "屏幕截图")

 **可迁移的技术方案** 

天机学堂中包含的技术和解决方案有：

基于自定义注解和Redisson的分布式锁工具

XXL-JOB**分布式任务调度工具

Caffeine**本地缓存工具

支持可靠消息、延迟消息的RabbitMQ工具

延迟队列**DelayQueue

基于CompletableFuture和CountDownLatch的并发任务处理方案

高并发高精度的视频进度记录和回放解决方案

学习计划和学习进度统计的学习监督方案

通用的问答（评论）功能实现方案

通用、高性能的点赞系统解决方案

高性能、低存储成本的签到解决方案

实时性强、通用性好的积分排行榜、历史排行榜解决方案

支持大数据量、高性能校验的优惠券兑换码算法

基于LUA脚本的高性能、并发安全的优惠券领取解决方案（秒杀解决方案）

优惠券叠加的智能推荐算法（MapReduce的思想）

基于Redis合并写请求并基于定时任务异步持久化的并发优化方案

基于Redis和MQ的异步写优化方案

基于腾讯VOD的视频加密、视频点播、视频审核、视频雪碧图功能（已实现未讲解）

包含支付宝支付、微信支付的多平台支付系统（已实现未讲解）

订单退款拆单处理方案（已实现未讲解）

等等
#### 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request

---

## 本地开发部署（基于 Docker）

本项目使用本地 Docker 部署中间件，代码在 IDEA 中运行（部署方式与 online-mooc 一致，两者共用同一套本地中间件）。

### 分支说明

- `Origin-code`：初始学习代码快照（来自上游 `lesson-init`，云平台密钥已脱敏为 `xxx`）
- `Dev`：基于 Origin-code 的日常开发分支
- `lesson-init`：上游原始分支（含完整历史，留作对照）

### 中间件清单

| 中间件 | 端口 | 账号/密码 | 控制台 |
|--------|------|-----------|--------|
| Nacos | 8848 / 9848 | 未启用认证 | http://127.0.0.1:8848/nacos/ |
| MySQL | 13390 | root / 541521 | — |
| Redis | 16379 | 541521 | — |
| RabbitMQ | 5672 / 15672 | root / 541521 | http://127.0.0.1:15672/ |
| RocketMQ | 9876 / 10911 | — | — |
| MinIO | 9000 / 9001 | admin / admin123456 | http://127.0.0.1:9001/ |
| XXL-Job | 8880 | admin / 123456 | http://127.0.0.1:8880/xxl-job-admin |
| Seata | 8091 / 7091 | seata / seata | http://127.0.0.1:7091/ |

### 启动步骤

1. 启动 Docker Desktop，等待状态变为 Running
2. 执行 `docker-local\start-infra.ps1` 一键拉起全部中间件
3. 首次部署执行 `docker-local\import-sql-fixed-v2.ps1`（提示时输入 `IMPORT`）导入 14 个业务库
4. 首次部署执行 `docker-local\import-nacos.ps1` 导入 Nacos 配置
5. IDEA 打开项目，在 Run Configuration 中配置环境变量（模板见 `docker-local/idea-env.example.txt`）
6. 按 gateway → auth → user 的顺序启动微服务

### IDEA 环境变量

```
SPRING_PROFILES_ACTIVE=local
SPRING_CLOUD_NACOS_SERVER_ADDR=127.0.0.1:8848
SPRING_CLOUD_NACOS_DISCOVERY_IP=127.0.0.1
TJ_JDBC_HOST=127.0.0.1
TJ_JDBC_PORT=13390
TJ_JDBC_USERNAME=root
TJ_JDBC_PASSWORD=541521
TJ_REDIS_HOST=127.0.0.1
TJ_REDIS_PORT=16379
TJ_REDIS_PASSWORD=541521
TJ_MQ_HOST=127.0.0.1
TJ_MQ_PORT=5672
TJ_MQ_USERNAME=root
TJ_MQ_PASSWORD=541521
TJ_MQ_VHOST=/tjxt
```

### 注意事项

- 与 online-mooc 共用同一套本地中间件，**不要同时启动两个项目的服务**（服务名相同，会互相注册导致负载均衡串了）
- 媒体/短信/支付密钥为脱敏占位符 `xxx`（tj-media、tj-message、tj-pay 的 bootstrap.yml），不影响启动，需要真实功能时填入自己的密钥
- Elasticsearch 未部署在 compose 中（tj-search 配置指向 `127.0.0.1:9200`），搜索功能暂不可用，需要时再补 ES 容器
- 多个含 XXL-Job 的服务同时启动时，需给每个服务配置不同的 `tj.xxl-job.executor.port`（默认 9999 会端口冲突）
- RocketMQ 的 store 使用宿主机目录绑定挂载（`docker-local/rocketmq-store`），这是 Docker Desktop 上避免 broker 启动即退出的必要配置


