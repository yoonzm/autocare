# AutoCare 商户端与后端全量代码审查记录

- **审查日期**：2026-11-27
- **审查范围**：`apps/merchant/lib`（全部 264 个 Dart 文件）、`supabase/functions`（`merchant-v1` / `admin-v1` / `member-v1` 全部非测试 TypeScript 文件）、`supabase/migrations`（全部 88 个 SQL 迁移文件），合计 443 个核心源码文件。
- **审查基准**：已排除 `AGENTS.md` 中明确约定的一期有意设计（如暂停订阅收费、缺少外部渠道的 TODO 占位动作等），仅保留确凿存在的 Bug 与明显不合理的架构/安全/数据设计。

---

## 总览统计（去重后）

| 严重级别 | 数量 | 核心风险领域 |
| --- | --- | --- |
| **P0 · Critical（紧急安全/数据泄露）** | 1 | 数据库表漏开 RLS 导致全平台退款数据暴露 |
| **P1 · High（高危安全/资金账务/核心崩溃）** | 38 | 权限 Fail-Open、双扣库存、双发提成、浮点拒单、旧 RPC 重载冲突、401 误踢登出、跨店脏缓存、预约串单等 |
| **P2 · Medium（明显设计缺陷/边界 Bug/性能隐患）** | 48 | 统计截断、请求重复鉴权放大、状态不同步、UI 死路、内存泄漏、时区混用等 |

---

## 一、P0 紧急安全漏洞（必须立即修复）

### 1. `public.order_refunds` 缺失 RLS 与表级权限回收，存在跨门店越权读写风险
- **位置**：`supabase/migrations/202611240004_refund_and_package_refund.sql:19-38`
- **问题**：新建 `public.order_refunds` 表后，本文件及后续所有迁移均未执行 `alter table public.order_refunds enable row level security;` 与 `revoke all on public.order_refunds from public, anon, authenticated;`。同期新建的其他表均做了 RLS + 权限回收。
- **后果**：在 Supabase 默认 `public` schema 权限下，任意持有 `anon` key 或普通登录态的客户端均可通过 PostgREST 跨门店读取、篡改甚至删除全平台消费退款记录。
- **建议**：立即新增迁移开启 RLS 并回收 `public`/`anon`/`authenticated` 权限，仅授权 `service_role`。

---

## 二、P1 高危问题（按领域分类）

### A. 后端安全与权限边界

#### A1. `gateStaff` 与 `technicianScope` 在瞬时异常时 Fail-Open 放行越权
- **位置**：`supabase/functions/merchant-v1/staff_access.ts:7-32`、`supabase/functions/merchant-v1/index.ts:48-51`、`supabase/functions/merchant-v1/account.ts:94-147`
- **问题**：
  1. `gateStaff()` 是大部分接口唯一的 RBAC 边界，但当 `admin.auth.getUser(token)` 出错或 `resolveSession()` 返回 503 Response 时，函数返回 `null`（放行）。若下游 handler 重新鉴权时瞬时错误恢复，员工请求将绕过全部 RBAC 校验直接执行。
  2. 同文件的 `technicianScope()` 在鉴权/会话异常时也返回 `null`（调用方 `supabase/functions/merchant-v1/appointments.ts:109-133` 将 `null` 视为“非技师，不限范围”），与同文件 `orderScopeOf`/`hasCap` 的 fail-closed 不一致。
  3. `supabase/functions/merchant-v1/account.ts:94-147` 对 `change_password`/`change_phone`/`delete_account` 缺少 `isOwner` 纵深校验，且 `delete_account` 传入了门店 `ownerId` 而非 `user.id`。
- **建议**：将公开接口路由前置，鉴权路由统一在入口层只解析一次 `SessionState` 并透传下游（同时消除单请求 2~4 次重复 `getUser`/RPC）；所有异常一律 fail-closed 返回 401/503。

#### A2. `recognize_plate` 向仅具 `member_lookup` 权限的员工泄露完整未脱敏会员 PII
- **位置**：`supabase/functions/merchant-v1/members.ts:94-97`、`supabase/functions/merchant-v1/plate_lookup.ts:52-86`
- **问题**：`staff_gate.ts:31` 允许仅具 `member_lookup` 权限的技师调用 `recognize_plate`，但后端未校验 `member_view` 权限，直接返回 `members.*`（明文手机号、储值余额、积分、生日、备注、VIN 车架号）。
- **建议**：无 `member_view` 权限时仅返回与员工端会员简况一致的脱敏字段。

#### A3. `staff_invite` 短信分支绕过角色/状态校验，且幂等头 `x-request-id` 未生效
- **位置**：`supabase/functions/merchant-v1/staff.ts:86-111`、`supabase/functions/merchant-v1/index.ts:78-84`
- **问题**：链接邀请走 `manage_store_staff` RPC（校验店长不能操作店长/本人、目标未停用/未激活），但 `via === 'sms'` 分支直接查表发短信，绕过上述全部校验；同时 `index.ts:78` 先路由到 `handleStaff`，第 84 行才注入 `input.__request`，导致短信幂等键恒为 `null` 且可被 body 伪造。
- **建议**：短信邀请分支统一先经由 SQL RPC 校验角色与状态，直接读取 `request.headers.get('x-request-id')`。

#### A4. `order_in_scope` 漏查 `orders.technician_ids`，且 scoped RPC 传 `NULL` 时 Fail-Open
- **位置**：`supabase/migrations/202611190005_order_scope.sql:5-71`、`supabase/migrations/202611240005_restore_order_scope.sql:58-81`
- **问题**：
  1. `order_in_scope` 仅查 `appointments.technician_id`，漏查 `orders.technician_ids`，导致仅具“查看本人订单”权限的技师看不到自己直接开单或无预约挂单的订单。
  2. `order_feed_scoped`/`order_detail_scoped` 未禁止 `p_resource is null`，为空时 `current_setting` 为空导致数据库层放行全店订单/充值/次卡流水。
- **建议**：在 scoped RPC 入口强制校验 `p_resource is not null`，并在 `order_in_scope` 中同时匹配 `o.technician_ids`。

#### A5. 库存配置/供应商表 RLS 缺失 `platform_session_live()`，已撤销会话仍可直读
- **位置**：`supabase/migrations/202611080003_inventory_management.sql:52-61`
- **问题**：`inventory_categories`/`inventory_suppliers`/`inventory_settings` 的 RLS 仅检查 `platform_store_access(store_id)`，未检查 `platform_session_live()`，已注销/踢出的旧 JWT 过期前仍可直读主门店数据。
- **建议**：补齐 `public.platform_session_live()` 策略校验。

#### A6. `change_password` 泄漏未注销的幽灵会话，且不踢出其他设备
- **位置**：`supabase/functions/merchant-v1/account.ts:106-113`
- **问题**：用 `signInWithPassword` 校验旧密码时创建了新 `auth.sessions` 记录却未 `signOut`，每次改密都在“登录设备”中永久残留一条“未识别设备”，且改密后未撤销其他设备会话。
- **建议**：校验后立即 `admin.auth.admin.signOut(session.access_token, 'local')`，并在改密后撤销除当前会话外的其余设备会话。

#### A7. 后台管理端（`admin-v1`）存在多处安全与幂等高危缺陷
- **透传未知 action**：`supabase/functions/admin-v1/index.ts:70-71` 将未知 action 透传给 `admin_command`，暴露了仅供内部调用的 `password_changed` 分支，普通 `ops` 可伪造审计日志。
- **改密不验原密码**：`supabase/functions/admin-v1/auth.ts:57-88` `change_password` 仅校验新密码不等于旧密码，未要求验证当前密码，泄露短期 token 即可直接接管超管账号。
- **通知群发越权与缺幂等/易超时**：`supabase/functions/admin-v1/permissions.ts:5-18` 未限制 `notification_*` 权限（普通 `ops` 可全站群发付费短信、撤回他人弹窗）；`supabase/functions/admin-v1/notifications.ts:118-289` 丢弃了 `context.requestId` 且在单次 HTTP 请求内串行发短信，极易超时导致审计丢失与重试重复群发。

---

### B. 资金、账务、库存与数据一致性

#### B1. 充值与订单退款的两位小数校验存在 IEEE-754 浮点 Bug，误拒 `19.99` 等合法金额
- **位置**：`supabase/functions/merchant-v1/member_rules.ts:116-119`、`supabase/functions/merchant-v1/order_rules.ts:112-121`、`apps/merchant/lib/pages/catalog/service_edit_page.dart:277`
- **问题**：使用 `Math.round(n * 100) !== n * 100` 判断两位小数。在 JS 浮点下 `19.99 * 100 === 1998.9999999999998`、`1.15 * 100 === 114.99999999999999`、`2.3 * 100 === 229.99999999999997`，大量常见金额直接被拒。同源 Bug 也存在于商户端耗材用量校验（`(q * 1000).round() != q * 1000` 误拒 `0.57`、`1.15` 等）。此外 `order_rules.ts` 在 `scope === 'full'` 时未清空残留 `amount`。
- **建议**：统一用正则（`/^\d+(?:\.\d{1,2})?$/`、`/^\d+(?:\.\d{1,3})?$/`）校验原始输入字符串，并在 `scope === 'full'` 时强制 `amount: null`。

#### B2. 预约转挂单完工后结算，服务绑定耗材被双重扣减库存
- **位置**：`supabase/migrations/202611200004_unify_hold_tasks.sql:91-96, 371-373`、`supabase/migrations/202611170001_service_consumables.sql:48-89`
- **问题**：`staff_task_finish` 在技师提交完工时若关联预约，调用 `service_consumables_deduct` 扣减一次库存；随后前台调用 `settle_held_order` 结算挂单时，未设置事务变量 `autocare.consumables_done = 'on'`，导致 `checkout_order`/`checkout_walkin` 再次扣减同一笔服务的耗材库存。
- **建议**：在 `held_orders` 记录已扣减标记/明细，结算挂单时若已扣减则跳过二次扣减。

#### B3. 预约挂单结算改派技师时触发器两次记账，给原技师和新技师发双份提成
- **位置**：`supabase/migrations/202611200004_unify_hold_tasks.sql:100-101, 498-534`、`supabase/migrations/202611240001_hold_bay_finish_and_closed_dates.sql:153-158`
- **问题**：`settle_held_order` 先更新 `orders.appointment_id`（此时 `technician_ids` 为空），触发 `orders_staff_commission` 回退给预约原技师写提成；随后 `checkout_with_technicians` 更新 `orders.technician_ids`，再次触发给新技师写提成，但从未清理第一次给原技师写入的记录。
- **建议**：合并 `appointment_id` 与 `technician_ids` 为单次更新，或在触发器中更新非空 `technician_ids` 时先清理旧提成行。

#### B4. 订单退款未冲销技师提成，且首页、收支、营业统计、员工业绩全未扣除退款
- **位置**：`supabase/migrations/202611040001_order_center.sql:289-348`、`supabase/migrations/202611030001_home_stats.sql:15-19`、`supabase/migrations/202611030005_expenses.sql:166`、`supabase/migrations/202611130001_business_stats.sql:50-87`、`supabase/migrations/202611090001_staff.sql:185-192`、`supabase/migrations/202611100002_staff_tasks.sql:149-153`
- **问题**：消费订单整单或部分退款后，既未冲销 `staff_commissions`，上述全部统计 RPC 也均按原 `orders.payable` 汇总，导致营收、利润和技师提成全面虚高。
- **建议**：退款事务同步冲销/按比例扣减 `staff_commissions`，各统计 RPC 统一按净实收（扣除 `refunded_amount` / 排除 `status = 'refunded'`）口径汇总。

#### B5. `refund_order` / `refund_package` 未删除旧 5 参数重载，存在 RPC 歧义或回退旧逻辑风险
- **位置**：`supabase/migrations/202611240004_refund_and_package_refund.sql:228-230, 376-378`
- **问题**：扩展为 6 参数（末尾带 default）时未 `drop function` 删除旧 5 参签名，PostgreSQL 中新旧重载并存，5 参调用可能触发 PGRST203 歧义或路由到旧逻辑绕过 `order_refunds` 记账。
- **建议**：显式 `drop function if exists` 删除旧 5 参数重载。

#### B6. `inventory_workorder_costs` 读不存在的 `payload.total`，导致工单领料成本恒为 ¥0.00
- **位置**：`supabase/functions/merchant-v1/inventory.ts:366-415`、`apps/merchant/lib/pages/inventory/stock_docs_bound_template.dart:135-226`
- **问题**：数据库将 FIFO 算出的成本写入顶层列 `inventory_documents.total`，但 `inventory_workorder_costs` 漏查 `total` 列而读取 `payload.total`，结果恒为 0（且若客户端 payload 夹带 `total` 还能伪造成本）。
- **建议**：查询 `total` 列并统一读取 `doc.total`。

#### B7. 储值自定义金额命中档位值时，前端提示“不享赠送”但后端仍自动发赠送金
- **位置**：`apps/merchant/lib/pages/members/wallet_controller.dart:153-223`、`apps/merchant/lib/pages/members/wallet_page.dart:792`、`supabase/functions/merchant-v1/member_rules.ts:106-124`
- **问题**：前端自定义输入框明确提示“输入金额，不享赠送”且按 0 赠送预览，但提交只传 `amount`，后端直接用 `giftFor(amount)` 匹配 1000/2000/5000/10000 档位自动多充 ¥100–¥2,500，造成账实不符。
- **建议**：统一前后端储值赠送规则（传递明确档位标识或同步前端预览口径）。

#### B8. `operatorOf(storeId)` 始终归属门店联系人，员工操作资金与库存单据的经办人全部记错
- **位置**：`supabase/functions/merchant-v1/members.ts:29-34`、`supabase/functions/merchant-v1/ops.ts:52-388`、`supabase/functions/merchant-v1/inventory.ts:291-292`、`supabase/functions/merchant-v1/appointments.ts:341`、`supabase/functions/merchant-v1/orders_center.ts:68`
- **问题**：店长/前台执行的收银、充值、退款、次卡操作和库存入出库盘点，经办人全部错误记录为店主/门店联系人，破坏审计追溯与经办人筛选。
- **建议**：`operatorOf` 按当前登录 `SessionState` 解析，员工操作时写入 `store_staff` 姓名与角色。

#### B9. `store_sms_overview` 未聚合查询，月短信超 1000 条静默截断
- **位置**：`supabase/functions/merchant-v1/store_sms.ts:60-114`（同问题亦见 `cards.ts:55`、`packages.ts:15-16`）
- **问题**：全量 `.select(...)` 在内存中统计，受 PostgREST 默认 1000 行上限截断。
- **建议**：改为 PostgreSQL `GROUP BY` / `COUNT(*) FILTER (...)` 聚合 RPC。

#### B10. `admin_snapshot` 被后续迁移覆盖回退，工单附件/分类/联系方式永久丢失
- **位置**：`supabase/migrations/202611200008_admin_staff_count.sql:19-43`（覆盖回退了 `202611060005_support_submission.sql:68-84`）
- **问题**：运营后台工单列表丢失了 `category`、`contact` 和 `support_uploads` 截图附件；且 `orders` 列表含模拟订单而 `more` 分页计数排除了模拟订单。
- **建议**：在最新 `admin_snapshot` 中恢复附件/分类/联系方式字段并统一分页计数口径。

---

### C. 后端并发与账号生命周期

#### C1. `push_claim_outbox` 认领后未置为 `sending`，并发 Worker 重复推送且崩溃任务无限重试
- **位置**：`supabase/migrations/202611260002_push_ios.sql:132-173`
- **问题**：`for update skip locked` 认领后仅 `attempts + 1` 不改 `status`，RPC 提交即释放行锁，下一轮立即重复认领同一批 `pending` 消息；且 `pending` 分支未限制 `attempts < 5`，崩溃任务会无限重推。
- **建议**：增加 `'sending'` 状态与 `claimed_at`，超时后按次数回收重试。

#### C2. `refund_package` 与 `checkout_order`/`staff_redeem_package` 加锁顺序相反，存在死锁风险
- **位置**：`supabase/migrations/202611010011_packages_orders_visits.sql:317-405`、`supabase/migrations/202611110002_staff_quick_orders.sql:73-77`
- **问题**：前者先锁 `member_packages` 再锁 `members`，后两者先锁 `members` 再锁 `member_packages`，并发执行会触发 PostgreSQL 40P01 死锁。
- **建议**：全库统一加锁顺序为 `members -> member_packages`。

#### C3. 员工登录产生的 `auth.users` 碰撞，导致员工无法注册自己门店、老板换号消耗 OTP 后报 409
- **位置**：`supabase/functions/merchant-v1/auth.ts:70-183`、`supabase/functions/merchant-v1/account.ts:120-127`
- **问题**：员工验证码登录会创建 `auth.users`（无 `merchant_accounts`），但注册与换绑手机号仅查 `merchant_accounts`，放行发码并消耗 OTP 后在 `createUser`/`updateUserById` 报 409 失败。
- **建议**：注册时复用仅属于员工的既有 `auth.users`；换绑手机号前校验 `auth.users` 占用。

---

### D. 商户端核心架构、认证、推送与状态管理

#### D1. `MerchantApi.invoke()` 401 刷新无并发单飞锁，且任意重试错误/断网误触发全局强制登出
- **位置**：`apps/merchant/lib/backend/merchant_api.dart:201-228`
- **问题**：首页/恢复前台并发请求遇 401 会同时多次调用 `refreshSession()`（触发 Supabase Refresh Token 轮换竞争踢人）；且 `refreshAuth()` 与重试 `send()` 共用 `try/catch (_)`，任何 400/403/500/超时都会递增 `authExpired.value++` 强制登出。
- **建议**：为 `refreshAuth()` 增加单飞去重锁，并拆分刷新失败与业务重试失败的异常处理。

#### D2. 退出登录/注销/重置密码从未调用 `PushService.unregisterBeforeSignOut()`，离职/交接设备持续收原门店推送
- **位置**：`apps/merchant/lib/backend/push_service.dart:152-171`、`apps/merchant/lib/backend/merchant_api.dart:636-649`、`apps/merchant/lib/backend/access_flow.dart:211-224`
- **问题**：`unregisterBeforeSignOut()` 和 `syncBadge()` 在全项目无任何调用方，登出后 iOS 设备继续接收原门店推送，且桌面角标永不更新/清零。
- **建议**：在各登出路径调用 `client.auth.signOut()` 之前执行 `unregisterBeforeSignOut()` 与 `syncBadge(0)`，并在 `InboxStore.acceptUnread()` 同步角标。

#### D3. `MerchantApi.signOut()` 在服务端登出前就清空本地状态，弱网失败陷入“半登出损坏态”
- **位置**：`apps/merchant/lib/backend/merchant_api.dart:636-649`、`apps/merchant/lib/backend/access_flow.dart:211-217`
- **问题**：先清 `StoreContext`/`storeProfile`/`Access` 再调远端 `signOut()`，若网络失败停在原页面，`hasSession == true` 但身份与门店上下文全空。
- **建议**：先远端登出（失败时按需降级 `SignOutScope.local`）再清理本地状态。

#### D4. 切换门店/身份未清理 `HoldStore`/`CatalogCounts`/`storeProfile`，存在跨店脏缓存串显
- **位置**：`apps/merchant/lib/backend/access_flow.dart:68-155`、`apps/merchant/lib/backend/hold_store.dart:24-77`、`apps/merchant/lib/backend/store_context.dart:7-11`
- **问题**：切店后立即展示旧门店挂单和卡项数量；同门店切角色不递增 `StoreContext.epoch`，无法作废旧角色在途请求。
- **建议**：切店/切身份时统一重置门店级缓存并强制递增 `StoreContext.epoch`。

#### D5. 注册开通绕过 `StoreSessionGate` 且未初始化 `Access`，新店首次会话站内信/推送/弹窗全部失效
- **位置**：`apps/merchant/lib/routes.dart:482-493`、`apps/merchant/lib/pages/account/reg_shop_page.dart:84-119`、`apps/merchant/lib/pages/account/reg_done_page.dart:700-701`
- **问题**：注册完成跳 `openRoute(context, 'Main')` 直接进 `Shell` 未包 `StoreSessionGate`，`Access.context` 为空，直至强杀重启前站内信、推送和平台公告全部停摆。
- **建议**：`routes.dart:488` 改为 `const StoreSessionGate(child: Shell())`，并在注册完成后补齐 `identity('context')` 与 `Access.apply()`。

---

### E. 商户端各业务模块明确 Bug

| 编号 | 模块 | 位置 | 问题描述与影响 |
| --- | --- | --- | --- |
| **E1** | 开单收银 | `apps/merchant/lib/pages/orders/order_page.dart:344, 633`、`order_checkout.dart:60-67` | **预约开单切换客户后未解绑原预约 ID**：收银仍走 `checkoutAppointment` 扣除**原预约会员**的余额/次卡，回执却显示新客户姓名；挂单也会把新客户错绑到原预约。 |
| **E2** | 开单收银 | `apps/merchant/lib/pages/orders/order_page.dart:601-603`、`order_live_pages.dart:994-995` | **无车会员收银把占位文案 `'未登记车辆'` 落库为车牌**：未像 `_hold()` 那样过滤，详情页经 `plateText` 错显为 `'未登·记车辆'`。 |
| **E3** | 账号安全 | `apps/merchant/lib/pages/account/profile_edit_page.dart:404-420`、`security_page.dart:102-206`、`change_phone_page.dart:63` | **非老板角色可进入仅老板可用的换号/改密/注销页**：且因 `account_phone` 为空回退读 `storeProfile.phone`，误将门店对外电话当作账号手机号发码并必遇 403。 |
| **E4** | 会员记录 | `apps/merchant/lib/pages/members/member_records_live_page.dart:412-501` | **加载/切 Tab 错误状态损坏**：失败仍置 `_loaded = true` 致切 Tab 误显“暂无记录”；切 Tab 失败残留旧 Tab 数据；分页重试跳回第 1 页；未监听 `memberChanged`。 |
| **E5** | 会员筛选/调级 | `apps/merchant/lib/pages/members/member_adjust_page.dart:254-512`、`member_filter_sheet.dart:174-384` | **硬编码 4 个卡种槽位**：超过 4 个卡种时第 5 个起无法选择；少于 4 个时渲染幽灵 `'—'` 选项点击报错。 |
| **E6** | 会员回访 | `apps/merchant/lib/pages/members/reminder_widgets.dart:225-260` | **发续卡/生日短信按钮无 `runBusy` 和稳定 `requestId`**：连点会重复发送真实付费短信并写多条回访记录。 |
| **E7** | 库存扫码 | `apps/merchant/lib/pages/inventory/inventory_management_controller.dart:281-304` | **手动输码 `enterBarcode` 共享 `runBusy` 死锁**：弹窗打开期间一直占锁，结果弹层里的“入库补货/详情/新增商品”全部静默无响应。 |
| **E8** | 库存商品 | `apps/merchant/lib/pages/inventory/product_edit_live_page.dart:549-573` | **停用/启用商品无 `catch`**：库存非零被后端拒绝时静默失败并抛未捕获异常，用户看不到任何提示。 |
| **E9** | 库存出库 | `apps/merchant/lib/pages/inventory/inventory_controller.dart:355-363`、`stock_out_line_template.dart:12-88` | **切出库原因残留隐藏工单号**（报废/退供被算进工单成本）；**出库明细无删除按钮**且数量减到 0 导致实时估价报错。 |
| **E10** | 员工提成 | `apps/merchant/lib/pages/staff/staff_commission_template.dart:45-58, 350` | **重载出现新服务时强解包崩溃**：未实现 `didUpdateWidget` 补充 controller，`_overrides['${s['id']}']!` 直接抛出空指针异常。 |
| **E11** | 员工转交 | `apps/merchant/lib/pages/staff/staff_transfer_template.dart:354-359` | **取消转交漏传 `staffId`**：点击取消后打开损坏的 `'请先选择员工'` 错误弹层。 |
| **E12** | 员工端完工 | `apps/merchant/lib/pages/staff_app/st_done_template.dart:632`、`apps/merchant/lib/routes.dart:318-325` | **`StDone` 未加入 `resultPages` 且返回用 `maybePop()`**：点击「返回工作台」反而退回已提交的完工表单页，再点确认触发重复提交报错。 |
| **E13** | 员工端权限 | `apps/merchant/lib/pages/staff_app/st_task_detail_template.dart:506-608`、`st_member_info_template.dart:809-868`、`routes.dart:363-378` | **多处员工操作与路由缺失前端权限拦截**：无 `progress_update` 仍可点开始施工/完工；无 `order_submit` 仍可弹出次卡核销；`_routeCaps` 漏配多个员工路由导致先发请求再 403。 |
| **E14** | 员工端我的 | `apps/merchant/lib/pages/staff_app/st_mine_template.dart:469-553, 927-949` | **权限变更未重载导致渲染 `'null 位'`，且子接口 403 阻断退出登录**：`Future.wait` 任一计数接口 403 会让整个「我的」页崩溃为错误页，无法切换身份或登出。 |
| **E15** | 支出管理 | `apps/merchant/lib/pages/expenses/expense_controller.dart:187-279`、`supabase/functions/merchant-v1/expense_rules.ts:21`、`voucher_gallery.dart:38-46` | **三处联动问题**：1) 库存同步的负金额退款支出点“确认付款/编辑”必被后端 `>= 0` 拒绝；2) 编辑凭证返回后 `UploadGallery` 无 key/`didUpdateWidget` 持续显示旧图；3) 切月失败后标题月份与报表数据错位。 |

---

## 三、P2 明显设计缺陷、边界 Bug 与性能隐患

### 1. 后端与数据库
- **短信并发双扣配额**：`supabase/migrations/202611260004_admin_notification_sms_logs.sql:26-61` `reserve_notice_sms` 将 `request_id` 判重移到了 `pg_advisory_xact_lock` 之前，并发重试会双扣配额并重发短信。
- **退款幂等与极小值边界**：`supabase/migrations/202611240004_refund_and_package_refund.sql:255-286` 幂等命中未校验 `order_id`/`member_package_id` 归属；`(0, 0.005)` 金额四舍五入为 0 却把订单标成 `partial_refunded`。
- **会员自助预约锁顺序与限额竞态**：`supabase/migrations/202611100003_member_portal.sql:167-207` 缺少前置门店咨询锁，与商户端改约存在死锁风险，并发可绕过 5 条预约上限和 2 小时取消限制。
- **技师改名未同步排班资源**：`supabase/migrations/202611100005_profile_edit.sql:37` 未同步更新 `appointment_resources.name`，导致预约、工单和会员小程序仍显示旧姓名。
- **单请求重复鉴权放大**：`merchant-v1/index.ts:49`、`shared.ts:83-91`、`staff_access.ts:7-63` 每次请求触发 2~4 次 `auth.getUser` 与 `platform_merchant_session` RPC。
- **`staff_cash_queue` N+1 扇出**：`supabase/functions/merchant-v1/staff_orders.ts:93-107` 单次请求最多并发 50 次 `quote_order` RPC 且静默吞错。
- **`orders.hold_remind` 与 `follow_ups.notify` 缺权限配置 & 伪造回访结果**：`supabase/functions/merchant-v1/ops.ts:198-391` 店长/前台调用必 403；发短信后回访结果硬编码 `'已预约到店'`。
- **服务定价与停用卡种校验漏洞**：`supabase/functions/merchant-v1/services.ts:27-60` `''`/`null`/`false` 转 `0` 通过定价校验，编辑耗材失败不回滚主表；`cards.ts:110-112` 未查 count 错误。
- **其他后端健壮性**：
  - `supabase/functions/merchant-v1/stores.ts:21-26` 泄露原始 PostgreSQL 错误且 40001 映射成 400；
  - `supabase/functions/merchant-v1/aliyun_push.ts:121-125` `fetch` 无超时；
  - `supabase/functions/merchant-v1/appointment_reminders.ts:11-64` 用 `Promise.all` 导致单条异常中断整批状态回写；
  - `supabase/functions/member-v1/portal.ts:53-193` DB 错误被误报为 403 非会员或 ¥0 估价；
  - `supabase/functions/merchant-v1/staff_members.ts:61-70` 与 `ops.ts:394-416` 忽略查询 error 静默返回空列表；
  - `supabase/functions/merchant-v1/expenses.ts:152-165` 智能预算尾差塞入 0 权重的“损耗”；
  - `supabase/migrations/202611030005_expenses.sql:102-104` `on conflict(id) do update` 缺少 `where store_id = p_store`；
  - `supabase/migrations/202611010010_member_wallet.sql:58` 与 `202611010011_packages_orders_visits.sql:268` 缺少正数兜底校验；
  - `supabase/functions/admin-v1/auth.ts:13-34` 登录限流仅按用户名无 IP 保护，固定超管名 `superman` 易遭锁定 DoS；
  - `supabase/functions/admin-v1/accounts.ts:30-64` 跨 Auth/DB 两阶段操作破坏幂等重试；
  - `supabase/functions/admin-v1/notifications.ts:187-191` 硬编码助通绕过 `SMS_PROVIDER` 开关。

### 2. 商户端（Flutter）
- **首页硬编码静态日期**：`apps/merchant/lib/pages/shared/home_page.dart:206` 直接写死 `Text('周六 · 10月31日')`。
- **空名 / 数值 / 时间崩溃隐患**：
  - `apps/merchant/lib/pages/members/member_detail_page.dart:302-305` 与 `pages/booking/appointment_detail_template.dart:60` 对空姓名 `.substring(0, 1)` 抛 `RangeError`；
  - `apps/merchant/lib/pages/members/wallet_controller.dart:148-160` 粘贴 `Infinity`/`NaN` 直接红屏崩溃；
  - `apps/merchant/lib/pages/staff_app/st_perf_template.dart:36` `(days[i]['amount'] as num)` 强转崩溃；
  - `apps/merchant/lib/pages/booking/appointment_schedule_live.dart:26-34` 营业时间倒挂时 `.clamp(0, gridHeight)` 抛 `ArgumentError`。
- **资源泄漏与错误框架用法**：
  - `apps/merchant/lib/backend/push_service.dart:176-199` 异步回调调 `InboxScope.of(ctx)` 导致整个 `Navigator` 订阅 30 秒轮询重建；
  - `apps/merchant/lib/pages/inventory/inventory_management_controller.dart:52-55` 非扫码模式也初始化 `MobileScannerController(autoStart: true)`；
  - `apps/merchant/lib/kit/pickers.dart:393-606` `pickAmount`/`pickCarModel` 泄漏 Controller；
  - `apps/merchant/lib/kit/upload_gallery.dart:368-374` 预览触发 N+1 次重复列表请求。
- **状态与交互明显 Bug**：
  - `apps/merchant/lib/pages/orders/order_page.dart:889-940` 切换客户不清空 `_holdRow`（旧挂单备注串单）；收银提交期间未禁用「挂单」按钮；
  - `apps/merchant/lib/pages/orders/order_list_controller.dart:107-137` 分页失败后继续滚动反复触发请求风暴；
  - `apps/merchant/lib/pages/shared/sms_logs_page.dart:33-86` 切筛选丢弃请求导致列表与标签错位；
  - `apps/merchant/lib/widgets/app_popup_dialog.dart:72` 公告确认失败未移出 `_handledIds` 导致永不重试；
  - `apps/merchant/lib/pages/members/member_detail_page.dart:577` 仅对索引 `i == 1` 的次卡显示到期日；
  - `apps/merchant/lib/pages/members/members_page.dart:119-120` 顶部卡种芯片与筛选弹层卡种取 AND 互斥导致空列表；
  - `apps/merchant/lib/pages/members/packages/package_detail_page.dart:342-420` 永久有效次卡延期预览错显为 30 天后，已退/用完次卡未禁用操作；
  - `apps/merchant/lib/pages/staff_app/st_redeem_sheet.dart:58-78` 无可用次卡时仍可发送真实短信验证码；
  - `apps/merchant/lib/pages/inventory/inventory_controller.dart:31-41` 幂等键复用导致同会话“删分类再建同名分类”被静默吞掉；入库行缺 `Key` 导致删行后数量文本串行；
  - `apps/merchant/lib/pages/catalog/services_page.dart:28` 硬编码 4 个分类芯片过滤掉了自定义分类，且在 `builder` 中修改状态；
  - `apps/merchant/lib/pages/booking/appointments_page.dart:713-721` 已到店预约展示必失败的「改期」按钮；
  - `apps/merchant/lib/pages/staff/staff_edit_template.dart:38`、`pages/booking/bay_edit_template.dart:34`、`business_hours_template.dart:33` 蓝色按钮放蓝色 `AppSpinner` 致加载态隐形；
  - `apps/merchant/lib/pages/staff/staff_add_template.dart:699-711` / `staff_edit_template.dart:727-739`「查看并调整角色权限」仍调 TODO 占位；`staff_detail_template.dart:511-524` 点店长权限错跳技师页；
  - `apps/merchant/lib/pages/expenses/expense_controller.dart:109` / `pages/booking/booking_settings_controller.dart:85-86` 混用设备本地 `DateTime.now()` 与 UTC+8。

---

## 四、建议修复优先级路线图

1. **第一批（止血 · 安全与数据保护）**：补齐 `order_refunds` 与库存表 RLS；修复 `gateStaff`/`technicianScope`/`order_in_scope` fail-open；修复 `recognize_plate` PII 泄露；修复 `admin-v1` 透传 action、改密验原密码与通知权限。
2. **第二批（止损 · 资金/库存/提成准确性）**：修复 `19.99` 浮点小数校验（前后端）；删除 `refund_order`/`refund_package` 旧 5 参重载；修复耗材双重扣减与改派技师双发提成；修复退款冲销提成与各统计口径；修复 `inventory_workorder_costs` 与自定义储值赠送不一致；修复 `operatorOf` 真实经办人；修复 `push_claim_outbox` 与 `reserve_notice_sms` 并发重发。
3. **第三批（体验与稳定性 · 商户端核心与业务 Bug）**：重构 `MerchantApi.invoke()` 401 单飞刷新与 `signOut()` 顺序；接入 `PushService.unregisterBeforeSignOut()`；修复切店清缓存与注册绕过 `StoreSessionGate`；修复预约开单切客户串单、`enterBarcode` 死锁、`StDone` 返回路径、`HomePage` 硬编码日期等业务 Bug。
