# Supabase 商户 V1

本目录包含商户注册/登录、服务项目、会员卡种的数据库迁移和 `merchant-v1` Edge Function。所有业务写入和归属校验都在云函数中；客户端不持有 `service_role` 密钥。会员、订单等不在 V1 范围。

开发项目：`autocare-dev`（`wghsytekrmpcofpugyua`）。`supabase/` 变更推送到 `main` 或当前 `feat/merchant-supabase-v1` 后，GitHub Actions 会先检查函数类型，再自动部署 `merchant-v1`；每次推送只触发一个后端工作流。部署令牌在 GitHub Secret `SUPABASE_DEV_ACCESS_TOKEN`，限定开发项目，永不过期但可手动吊销。当前首个迁移已通过 Supabase Dashboard 应用，**尚未写入 CLI 迁移历史**；因此迁移文件变更会阻止自动部署，不能直接执行 `db push`。后续正式环境应使用独立的 CLI 迁移历史和凭据。

部署顺序：

1. 在目标项目执行 `migrations/202611010002_merchant_v1.sql`，先在备份/测试环境验证迁移。旧表如已有数据，迁移前必须人工审查，不能直接删除。
2. 部署 `functions/merchant-v1/index.ts` 为 `merchant-v1`。公共注册/登录动作需要关闭平台层 JWT 校验（`config.toml`），函数内部对所有业务动作自行验证访问令牌。
3. 仅开发项目可设置 Edge Function 密钥 `ALLOW_MOCK_SMS=true`，固定验证码 `123456`。生产环境不得设置；真实短信与 OTP 流程尚为 `TODO`，因此生产注册暂不可用。
4. 客户端只使用项目 URL 与 publishable key。绝不将 `SUPABASE_SERVICE_ROLE_KEY` 下发到 App。

云函数按 `auth.ts`、`services.ts`、`cards.ts`、`shared.ts`、`types.ts`、`index.ts` 分模块，`types.ts` 定义动作及数据模型。已提供 `send_mock_code`、`register`、`login_password`、`list/save/delete`（服务项目与卡种）接口。服务项目删除为物理删除；卡种因既有界面文案为“停用”，`delete` 为软删除（`active=false`），列表只显示启用卡种。后端接口已通过开发项目 API 冒烟测试。商户端保留生成的编辑页面代码，通过非生成代码适配输入与保存动作；卡种列表由设计页面的卡片模板派生并绑定真实数据。

开发时执行 `cd supabase/functions/merchant-v1 && deno task check` 检查模块类型。Dashboard 部署须同时包含入口及其依赖模块；`types.ts` 是编译期类型文件，不含运行时代码。
