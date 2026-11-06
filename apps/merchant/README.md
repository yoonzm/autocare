# Merchant app

汽美管家商户端 Flutter 原型，从 LanScope 仓库的 `claude/sleepy-clarke-4ehenr` 分支（提交 `e696c67`）迁入。V1 在保留已设计页面布局和样式的前提下接入 Supabase：开发环境注册、密码登录，以及服务项目和会员卡种的列表、新增、修改、删除/停用。其他业务继续使用原型数据。

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

默认连接私有化正式环境 `https://autocare.mymember.ltd`，普通 `flutter run` / `flutter build` 不需要额外参数。需要连接 Cloud 测试环境 `autocare-dev` 时手动指定：

```sh
flutter run --dart-define-from-file=config/dev.json
flutter build apk --release --dart-define-from-file=config/dev.json
# iOS 同样支持 --dart-define-from-file=config/dev.json
```

也可同时传入 `--dart-define=SUPABASE_URL=...` 和 `--dart-define=SUPABASE_PUBLISHABLE_KEY=...` 连接其他实例。公开客户端密钥可随 App 发布，服务端密钥禁止放入客户端。两个环境账号和数据独立；切换环境需要重新登录。当前使用同一应用标识，测试包会覆盖已安装的正式包，不能同时安装。

GitHub Actions 的 Merchant Build 默认连接正式环境；需要测试包时从 Run workflow 手动选择 `backend_environment=development`。开发短信 mock 会随机生成 6 位验证码（5 分钟有效、一次性、服务端校验）并直接返回给 App，**禁止用于生产**。正式环境禁用 mock，真实短信接入前，注册、验证码登录、找回密码等短信流程返回明确的未启用错误，已有账号可使用密码登录。现有设计页的服务项目可维护名称、分类与门店价；卡种可维护名称与项目折扣，“停用此卡种”为软删除。后端部署及安全边界见 [`supabase/README.md`](../../supabase/README.md) 与 [`docs/backend-integration.md`](../../docs/backend-integration.md)。

应用标识：iOS 与 Android 均为 `com.yoonzm.autocare.merchant`。iOS 发布需为该标识重新创建 Apple App、Provisioning Profile 和 Actions Secrets，不得沿用 LanScope 的描述文件。
