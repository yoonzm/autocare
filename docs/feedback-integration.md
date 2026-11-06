# 商户反馈提交

本次只接通“关于 → 意见反馈 → 提交反馈”，成功提示“反馈已提交”并返回原“关于”页。商户不新增工单列表、详情、查看回复、追加回复和通知入口。已有相关后端接口保留，等页面设计完成后接线。

## 界面保持与数据接入

- 保持反馈类型、描述框、三张截图槽位、联系方式、底部按钮、导航、尺寸和深浅色样式。联系方式移除演示号码，初始为空，保留 placeholder。
- 用户已同意将“我们会在 1–3 个工作日内通过站内消息回复”改为“反馈提交后将由平台处理，暂不支持查看进度和回复”。
- 输入、类型和图片由真实草稿驱动。新表单直接展示，无首次请求骨架。提交中整个表单禁止操作、按钮使用统一 `hBusy`，失败保留草稿，成功才跳转。有修改时返回需确认；登录失效的草稿仅供同一账号再次进入反馈时恢复，进程退出后不保留。
- 生成页只能由 `apps/merchant/tools/design_to_flutter.py` 更新。仓库暂缺原始 HTML，可运行 `python apps/merchant/tools/design_to_flutter.py --rewrite-existing apps/merchant/lib/pages/gen`；HTML 生成与现有文件升级共用幂等的 `bind_feedback` 规则。
- 后台仍用现有工单页和会话气泡；首条反馈附上类型、联系方式，有截图时在消息内展示真实图片，无附件的旧消息布局保持原样。

## 接口与安全

1. `merchant-v1.support_upload`：传 `data`（base64），后端验证登录会话、门店、JPEG/PNG 签名及 5MB 上限，上传到私有 `support-attachments` bucket，返回上传记录 `id`。客户端不传门店 ID、Storage 路径或公开图片 URL。
2. `merchant-v1.support_create`：传 `category`、`text`、`contact`、`attachments`（上传记录 ID 数组），请求头带 `X-Request-Id`。后端限制现有四种类型、正文 1–5000 字、联系方式最多 200 字、截图最多三张且不重复；截图必须属于本人及本店且未用于其他消息。
3. 工单、首条消息、附件归属及幂等结果同一事务提交，任意校验失败均不建单。后端生成标题，商户无需填写新字段。同一内容重试复用原请求编号，编辑内容后使用新编号；服务端已提交但响应丢失时可安全重试。
4. `admin-v1.ticket_attachment`：运营账号通过 JWT、活跃会话、账号状态和初始密码修改检查后，凭已关联消息的截图 ID 获取五分钟签名 URL。匿名、普通商户及未提交截图没有此入口权限；客户端不能直接读上传记录或 bucket。
5. 服务暂停、套餐到期时仍沿用客服工单的非经营会话校验，允许求助；账号被冻结或会话失效则拒绝。员工账号和授权不在本次范围。

## 部署与验证

先应用 `202611060005_support_submission.sql`，再部署 `merchant-v1` 与 `admin-v1`，最后发布两个客户端。迁移依赖现有后台平台迁移与 Supabase Storage，不需要新增渠道密钥。不修改历史工单正文，反馈元数据由后台查询组装；新增私有底层函数不对 `anon`、`authenticated` 或 `service_role` 直接开放。

- 数据库：`node supabase/tests/admin.mjs <pglite/dist/index.js>`，包含元数据、附件、请求复用、校验回滚、跨店、重复附件和权限断言。
- 云函数：两个目录运行 `deno task check` / `deno test`。
- 商户：`flutter analyze`、`flutter test`；`feedback_test.dart` 验证超时重试幂等与截图复用；`feedback_page_test.dart` 验证已登录真实表单、未登录引导、尺寸、防连点、失败保留与成功返回。设置 `FEEDBACK_RENDER_DIR` 可导出手机深浅色截图。
- 后台：`flutter analyze` / `flutter test`，回归现有工单流程与深浅色布局。

## 尚未接入 / TODO

- `support_list/get/reply` 的商户页面、站内消息、推送、短信、未读标记：待设计及通知渠道，不声明已送达。
- 放弃表单、替换图片或上传响应丢失时可能留下尚未关联消息的私有上传对象。TODO：增加后端定时清理接口 `support_cleanup_uploads`，仅清理超过保留期且 `message_id is null` 的记录及对象；当前不自动清理，不影响真实提交及已提交附件。不得清理已经关联工单的截图。
- 目标环境部署和真实双端冒烟需在发布时执行；本地隔离测试不向现有商户账号提交工单或发送短信。
