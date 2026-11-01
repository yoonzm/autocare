# Merchant app

汽美管家商户端 Flutter 原型，从 LanScope 仓库的 `claude/sleepy-clarke-4ehenr` 分支（提交 `e696c67`）迁入。V1 在不修改已设计界面的前提下接入 Supabase：开发环境注册、密码登录、服务项目读取；服务编辑和会员卡种编辑页仍为设计预览，尚未保存到后端，打开时会提示。其他业务继续使用原型数据。

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

默认连接 `autocare-dev` Supabase 项目。切换项目须以 `--dart-define=SUPABASE_URL=...` 和 `--dart-define=SUPABASE_PUBLISHABLE_KEY=...` 指定。开发短信 mock 返回固定验证码 `123456`，**禁止用于生产**；验证码登录、真实短信和生成页面的数据绑定见 `TODO`。后端部署及安全边界见 [`supabase/README.md`](../../supabase/README.md) 与 [`docs/backend-integration.md`](../../docs/backend-integration.md)。

应用标识：iOS 与 Android 均为 `com.yoonzm.autocare.merchant`。iOS 发布需为该标识重新创建 Apple App、Provisioning Profile 和 Actions Secrets，不得沿用 LanScope 的描述文件。
