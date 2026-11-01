# Merchant app

汽美管家商户端 Flutter 原型，从 LanScope 仓库的 `claude/sleepy-clarke-4ehenr` 分支（提交 `e696c67`）迁入。V1 在保留已设计页面布局和样式的前提下接入 Supabase：开发环境注册、密码登录，以及服务项目和会员卡种的列表、新增、修改、删除/停用。其他业务继续使用原型数据。

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

默认连接 `autocare-dev` Supabase 项目。切换项目须以 `--dart-define=SUPABASE_URL=...` 和 `--dart-define=SUPABASE_PUBLISHABLE_KEY=...` 指定。开发短信 mock 会随机生成 6 位验证码（5 分钟有效、一次性、服务端校验）并直接返回给 App，**禁止用于生产**；注册、验证码登录和密码登录均已接通；真实短信供应商以及会员权益/升级规则等非 V1 字段见 `TODO`。现有设计页的服务项目可维护名称、分类与门店价；卡种可维护名称与项目折扣，“停用此卡种”为软删除。其他设计控件保留原样但暂不生效，点击会提示。后端部署及安全边界见 [`supabase/README.md`](../../supabase/README.md) 与 [`docs/backend-integration.md`](../../docs/backend-integration.md)。

应用标识：iOS 与 Android 均为 `com.yoonzm.autocare.merchant`。iOS 发布需为该标识重新创建 Apple App、Provisioning Profile 和 Actions Secrets，不得沿用 LanScope 的描述文件。
