# App 站内消息

用户于 2026-11-25 批准恢复站内消息，覆盖老板、店长、前台、技师。2026-11-26 追加批准阿里云 EMAS iOS 系统推送及生产配置；微信通知仍不在范围。

## 接收与入口

- 老板/店长商家首页、前台/技师工作台提供铃铛。统一路由 `Messages`，旧 `StMsgs` 兼容。
- 挂单进入待结算：老板和有收银权限的在职店长/前台分别收到消息；状态未变的更新不重复发送。
- 消费订单收银：老板收到订单消息；挂单提交人沿用收银通知，新增消费单跳转。
- 员工派工、到店、提成、权限变更沿用现有业务触发器。已转交/删除的任务点击后提示不可访问；未转挂单的有效预约指向今日到店。
- 老板历史上没有收件人记录，本次不伪造历史通知；从迁移上线后的新业务事件开始收件。

## 数据和安全

复用 `staff_messages`，员工 `staff_id` 与老板 `owner_id` 互斥。新 `inbox_*` 接口从已验证会话解析门店和收件人，忽略客户端传入的身份字段；数据库二次校验在职员工或门店所有者，消息表不对客户端直接开放。任务归属检查同时修正空资源 ID 的 SQL NULL 绕过问题。

每页 30 条，使用 `(created_at,id)` 游标，支持全部/任务/到店/系统筛选。单条已读幂等；全部已读仅处理列表读取截止时间之前的消息，不吞掉随后到达的新消息。跳转通过服务端白名单、当前权限和业务归属核验，不执行任意存储路由字符串。

App 前台每 30 秒读取未读数，恢复前台立即刷新；后台暂停轮询。身份变化清空未读缓存和列表，旧身份的迟到响应被丢弃。读取失败保留上次未读数并提示更新失败，列表支持重试，分页失败不丢已加载内容。列表下拉刷新，未读数变化自动刷新已打开列表。

## 验证与交付

- `supabase/tests/inbox.mjs`：在隔离的嵌入式 PostgreSQL 中执行所有迁移及消息 SQL 断言；包含同时间戳分页、跨门店/跨员工隔离、老板收件箱、已读截止时间、派工/待结算/收银通知、归属变化及数据库权限。
- `inbox_rules.test.ts`：请求参数和身份不可由客户端指定；生产 CI 接入 inbox SQL 测试。
- `apps/merchant/test/inbox_test.dart`：分页、已读失败、失效业务链接、身份切换迟到响应、前后台轮询、铃铛入口。
- 生产生效需要先应用 `202611250006_inbox.sql` 并部署 merchant-v1，再更新 App；本地完成不代表生产已部署或手机系统推送已开通。

已有 `staff_tasks.sql` 的完整施工回归在本地检查中发现预约关联结算引用了不存在的 `appointments.order_id`，不属于本次消息实现；消息回归使用不关联预约的真实挂单结算验证收银事件。预约关联结算仍需单独修复和验收。

## iOS 系统推送生产接入（2026-11-26）

- `staff_messages` 仍是唯一消息来源。新消息仅在收件人有有效设备绑定时写入 `push_outbox`，不补发历史消息。设备绑定从登录会话解析门店和身份；同设备换账号/门店覆盖归属。点击通知只使用 `message_id`，复用 `inbox_target` 的权限检查和原有导航。
- Apple App ID `com.yoonzm.autocare.merchant` 已启用 Push Notifications。APNs Key ID 为 `9WAD59PN7X`，Team ID 为 `6F7QRYSM6W`；按 [EMAS P8 配置要求](https://help.aliyun.com/zh/document_detail/434644.html) 使用 Sandbox & Production 密钥，实际后端设为 `PRODUCT`。私钥不进入仓库。
- EMAS 项目 `AutoCare`（`3925570`），iOS 应用“我的汽美管家”，AppKey `335766950`；P8 鉴权配置已保存。GitHub Secrets 已配置 `ALIYUN_PUSH_IOS_APP_KEY`、`ALIYUN_PUSH_IOS_APP_SECRET`，并更新包含 `aps-environment=production` 的 `BUILD_PROVISION_PROFILE_BASE64`。打包检查会拒绝缺少推送权限的描述文件。
- 私有化生产环境通过 `/opt/supabase/.env.push`（root、0600）注入 `ALIYUN_ACCESS_KEY_ID`、`ALIYUN_ACCESS_KEY_SECRET`、`ALIYUN_PUSH_IOS_APP_KEY`、`ALIYUN_PUSH_IOS_APNS_ENV`。部署入口创建空文件但不覆盖已有凭据。`supabase/deploy/push_dispatch.py --install` 安装 `autocare-push-dispatch.timer`，每分钟调用仅允许 service-role 的 `push_dispatch_run`；缺少配置或渠道失败会使定时任务报错，不打印密钥。
- 生产已应用 `202611260002_push_ios.sql`，部署来源基线为 `1ebbf43411f932800b8fecd65da252baf963682d`，精确后端摘要为 `fb5faf471fe21e91f3a46219ca9fbd2693884c51d95455e89ee28fff1c9091c5`（包含未提交工作区改动）。发布前已备份，配置备份位于 `/var/lib/autocare-deploy/config-backups/push-ios-1795681521845816643`。三个云函数、公开协议及鉴权健康检查通过；定时任务已启用并验证自动执行成功。
- 本次验证：商户端 `flutter analyze` 无问题、全量 `flutter test` 813 项通过；三个云函数类型检查和 170 项 Deno 测试通过；20 项部署脚本测试、5 项 App 构建脚本测试及生产 CI 中全部 18 个数据库测试入口通过。推送测试的参数校验移至纯函数 `push_rules.ts`，避免测试导入运行时环境变量。
- 真实接口连通检查修正了原默认域名，改用 [官方服务接入地址](https://help.aliyun.com/zh/document_detail/2249911.html) `https://cloudpush.aliyuncs.com`；原 `mpush.aliyuncs.com` 在生产无法解析。修正后已重新完成商户后端全量测试并发布。
- RAM 专用用户 `autocare-push-prod` 已绑定自定义策略 `AutoCareProductionPush`，仅允许 `mpush:Push` 操作本应用资源 `acs:mhub:*:1101618831318931:app/335766950`。使用真实凭据与无效测试设备 ID 调用后，从授权前的 `NoPermission` 变为 `InvalidDeviceId.Format`，验证签名及应用权限生效；未向实际设备发送通知。
- 待完成：提交并推送当前 App 与构建配置后生成新版 TestFlight；在 iPhone 验证授权、设备绑定、前后台/冷启动收件与点击跳转。当前生产设备与队列均为 0，空队列调用成功不代表已完成真实推送送达验收。
