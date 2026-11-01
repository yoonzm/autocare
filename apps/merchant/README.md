# Merchant app

汽美管家商户端 Flutter 原型，从 LanScope 仓库的 `claude/sleepy-clarke-4ehenr` 分支（提交 `e696c67`）迁入。邮箱注册/登录、门店信息、会员、服务项目、会员卡种已接入 Supabase；其余页面仍为 mock 原型，不应当作真实营业数据。

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

默认连接开发项目 `autocare-dev`。也可通过 `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...` 切换环境。仅使用公开的 publishable key；数据库结构和权限见 `../../supabase/migrations/`。

当前认证使用邮箱密码。托管 Supabase 默认要求邮箱验证，注册后先验证邮件再登录；短信登录尚未配置短信服务商，因此原手机号/验证码原型未接入。

`feat/merchant-supabase-foundation` 分支每次推送会自动运行分析、测试和无签名 iOS 构建；检查通过后构建 Android APK，并在 GitHub Actions 的 Artifacts 中保留 14 天。该 APK 仅用于内部测试，不可直接上架。正式内测发布仍仅由 `main` 的独立工作流触发。

应用标识：iOS 与 Android 均为 `com.yoonzm.autocare.merchant`。iOS 发布需为该标识重新创建 Apple App、Provisioning Profile 和 Actions Secrets，不得沿用 LanScope 的描述文件。
