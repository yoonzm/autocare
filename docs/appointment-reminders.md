# 商户端预约短信提醒

商户端新建预约可开启到店前两小时短信提醒。预约表保存开关、时间、状态、请求 ID、领取时间、尝试次数和下次执行时间；短信正文和渠道结果复用 `sms_logs`，没有独立任务表。会员端代码不变，其新预约默认不开启提醒。现有商户端改期保留开关并重算提醒时间；任何入口取消或到店均使旧提醒失效。会员端取消旧预约再新建的改约不会继承提醒。

保持预约页面布局、导航、预约确认通知逻辑不变，只接通原提醒开关、提交字段和说明。新建/改期时距到店不足两小时的提醒标为 `skipped`，不补发；预约确认短信仍由独立开关控制。早已创建的到期提醒允许调度延迟后补发，但不能晚于预约时间。时间按带时区时间戳保存，短信显示北京时间。

## 发送与并发

`save_merchant_appointment` 在同一事务中保存预约和开关；无有效客户手机号时回滚并明确报错。`claim_appointment_reminders` 每轮原子领取最多 20 条，使用 `FOR UPDATE SKIP LOCKED`。发送前重读预约状态和请求 ID，改期会更新 ID，旧结果不会覆盖新提醒。已经交给渠道的短信无法撤回；发送前检查与外部渠道受理之间仍有很短的竞态窗口。

短信 `sent` 仅指渠道受理，不表示运营商送达。手机号/全局日限额、配置和明确渠道拒绝记为失败。只有尚未发送的冷却限流允许一分钟后重试，最多三次且不超过预约时间。网络超时、重复请求、写入结果异常及超过五分钟未完成的发送标为 `unknown`，不自动重发。提醒状态在预约记录中可查询，渠道记录继续由现有后台短信记录查询；本次未新增状态展示页面。

公共 `reserve_notice_sms` 也补上重复请求保护：相同请求 ID 不再消耗额度或再次调用短信渠道。此保护覆盖现有通知短信调用，不改变验证码额度。

## 生产启用

1. 按现有发布流程执行 `202611240006_appointment_reminder.sql` 并部署 `merchant-v1`。
2. 将仓库中的 `supabase/deploy/appointment_reminders.py` 安全复制到生产服务器，使用 root 执行 `python3 appointment_reminders.py --install`。脚本安装 systemd service/timer，每分钟调用一次服务端接口。部署归档当前只包含迁移和云函数，因此首次安装定时器是单独的服务器步骤。
3. 定时器复用 `/opt/supabase/.env` 中的 `SERVICE_ROLE_KEY` 和 `SUPABASE_PUBLIC_URL`，不新增渠道账号或在日志打印密钥。已有助通自定义短信配置必须有效。
4. 用 `systemctl status autocare-appointment-reminders.timer` 和 `journalctl -u autocare-appointment-reminders.service` 检查运行。停止发送可执行 `systemctl disable --now autocare-appointment-reminders.timer`；这不会撤回已受理短信。
5. 发布新版商户 App。真实短信联调仅使用用户明确指定的测试手机号。

服务端入口 `appointment_reminders_run` 仅接受 service-role Bearer 密钥，不能由商户会话或公开 key 调用。数据库相关 RPC 也仅向 service_role 授权。定时器以一分钟为粒度，单次处理 20 条；积压或故障会增加延迟，需通过运行日志及预约中逾期 pending/sending 状态监控。

## 验证

- `deno check supabase/functions/merchant-v1/index.ts`
- `deno test supabase/functions/merchant-v1/appointment_rules.test.ts supabase/functions/merchant-v1/sms.test.ts`
- `node supabase/tests/appointment_reminders.mjs /path/to/@electric-sql/pglite/dist/index.js`
- `flutter test test/appointments_test.dart`（apps/merchant）

数据库测试加载全部迁移，验证创建、改期、重复提交、取消、到店、两小时内跳过、重复领取、陈旧发送结果、限流重试、权限、无手机号事务回滚，以及会员端默认关闭。所有自动测试使用隔离数据库或桩，不发送真实短信。
