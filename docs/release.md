# 发布约定

- `main` 合入后，按受影响目录执行各端 CI / 内测发布；生产发布采用各端独立版本和审批。
- 商户端使用 `.github/workflows/merchant-internal.yml` 执行 Flutter 检查和内测打包；后台端仍由独立工作流处理。后端由 `.github/workflows/supabase-dev.yml` 独立检查和部署，仅在 `supabase/` 目录变更时运行，不触发商户端打包。
- iOS 标识为 `com.yoonzm.autocare.merchant`。先在 Apple Developer / App Store Connect 创建对应 App ID、App 和 App Store 描述文件；再在新 GitHub 仓库配置 `BUILD_CERTIFICATE_BASE64`、`P12_PASSWORD`、`BUILD_PROVISION_PROFILE_BASE64`、`ASC_KEY_ID`、`ASC_ISSUER_ID`、`ASC_PRIVATE_KEY`。不要复制 LanScope 的描述文件。配置完成后在仓库 Variables 中设置 `ENABLE_MERCHANT_TESTFLIGHT=true`，此前 iOS 发布任务会跳过。
- 商户端检查在任意分支推送 `apps/merchant/` 变更后运行；仅 `main` 与当前 `feat/merchant-supabase-v1` 分支同时执行内测打包。V1 验证结束后应移除特性分支上传条件。TestFlight 上传仍受 `ENABLE_MERCHANT_TESTFLIGHT` 和 `merchant-testflight` 环境签名配置约束。
- Android 当前 APK 使用 Flutter 默认调试签名，不可用于正式商店发布。正式发布需专用 keystore、上传渠道及审批流程。
- Supabase 开发项目 `autocare-dev`：任意分支推送 `supabase/` 变更后只运行后端检查；`main` 或 `feat/merchant-supabase-v1` 通过检查后还会自动部署 `merchant-v1`，不触发商户端打包。GitHub Secret `SUPABASE_DEV_ACCESS_TOKEN` 为仅限此开发项目的部署令牌，不得放入代码或客户端。数据库迁移暂不自动应用：首个 migration 已经通过 Dashboard 执行但未登记 CLI 历史；涉及 `supabase/migrations/` 的推送会明确失败，避免重复执行或函数先于 schema 发布。对齐历史并配置数据库凭据后才可启用 `db push`。生产环境使用独立项目、令牌及审批。
- 新增端时增加各自 CI / 发布工作流，保持版本号与发布状态独立；共享包变化需触发所有依赖它的端。
