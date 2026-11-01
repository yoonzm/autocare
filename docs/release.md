# 发布约定

- `main` 合入后，按受影响目录执行各端 CI / 内测发布；生产发布采用各端独立版本和审批。
- 商户端统一使用 `.github/workflows/merchant-internal.yml`：一个工作流内按变更目录执行 Flutter 检查、Supabase 云函数类型检查及内测打包。后台端仍由独立工作流处理。
- iOS 标识为 `com.yoonzm.autocare.merchant`。先在 Apple Developer / App Store Connect 创建对应 App ID、App 和 App Store 描述文件；再在新 GitHub 仓库配置 `BUILD_CERTIFICATE_BASE64`、`P12_PASSWORD`、`BUILD_PROVISION_PROFILE_BASE64`、`ASC_KEY_ID`、`ASC_ISSUER_ID`、`ASC_PRIVATE_KEY`。不要复制 LanScope 的描述文件。配置完成后在仓库 Variables 中设置 `ENABLE_MERCHANT_TESTFLIGHT=true`，此前 iOS 发布任务会跳过。
- 商户端内测发布在 `main` 的商户端变更或当前 `feat/merchant-supabase-v1` 的同仓库 PR 更新后自动运行；其他 PR 只做检查。V1 验证结束后应移除特性分支上传条件。TestFlight 上传仍受 `ENABLE_MERCHANT_TESTFLIGHT` 和 `merchant-testflight` 环境签名配置约束。Supabase 单独变更只做类型检查，不打包商户端。
- Android 当前 APK 使用 Flutter 默认调试签名，不可用于正式商店发布。正式发布需专用 keystore、上传渠道及审批流程。
- Supabase 尚未启用。启用时分离 staging / production 项目，所有 schema 变更提交 migration 并先部署后端兼容变更，再发布客户端。
- 新增端时增加各自 CI / 发布工作流，保持版本号与发布状态独立；共享包变化需触发所有依赖它的端。
