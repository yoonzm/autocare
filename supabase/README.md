# Supabase 商户 V1

本目录包含商户注册/登录、服务项目、会员卡种的数据库迁移和 `merchant-v1` Edge Function。所有业务写入和归属校验都在云函数中；客户端不持有 `service_role` 密钥。会员、订单等不在 V1 范围。

开发项目：`autocare-dev`（`wghsytekrmpcofpugyua`）。当前迁移及函数已通过 Supabase Dashboard 应用于此开发项目；后续正式环境应使用 CLI 迁移历史独立部署，**不要误以为 Dashboard SQL 已写入 CLI 迁移历史**。

部署顺序：

1. 在目标项目执行 `migrations/202611010002_merchant_v1.sql`，先在备份/测试环境验证迁移。旧表如已有数据，迁移前必须人工审查，不能直接删除。
2. 部署 `functions/merchant-v1/index.ts` 为 `merchant-v1`。公共注册/登录动作需要关闭平台层 JWT 校验（`config.toml`），函数内部对所有业务动作自行验证访问令牌。
3. 仅开发项目可设置 Edge Function 密钥 `ALLOW_MOCK_SMS=true`，固定验证码 `123456`。生产环境不得设置；真实短信与 OTP 流程尚为 `TODO`，因此生产注册暂不可用。
4. 客户端只使用项目 URL 与 publishable key。绝不将 `SUPABASE_SERVICE_ROLE_KEY` 下发到 App。

云函数已提供 `send_mock_code`、`register`、`login_password`、`list/save/delete`（服务项目与卡种）接口。后端接口已通过开发项目 API 冒烟测试，但商户端生成的服务/卡种编辑页面尚缺少稳定的记录 ID 和输入适配；客户端目前仅消费服务项目列表，保存/卡种列表仍标 `TODO`，不能视作端到端完成。
