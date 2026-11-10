# Merchant app

汽美管家商户端 Flutter 原型，从 LanScope 仓库的 `claude/sleepy-clarke-4ehenr` 分支（提交 `e696c67`）迁入。V1 在保留已设计页面布局和样式的前提下接入 Supabase：注册、密码登录，以及服务项目和会员卡种的列表、新增、修改、删除/停用。其他业务继续使用原型数据。

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

App 与 GitHub Actions 的 Merchant Build 均连接私有化正式环境 `https://autocare.mymember.ltd`，普通 `flutter run` / `flutter build` 不需要额外参数。

公开客户端密钥可随 App 发布，服务端密钥禁止放入客户端。

短信一期接入助通，按注册、登录、找回密码、换号和注销用途发送并校验；所有环境都使用真实短信，响应不返回验证码，App 只提示查收。短信 mock 配置与调试验证码提示已移除。渠道或模板未配置时明确报错；现有账号密码登录不受短信配置影响。配置与安全边界见 [`docs/sms.md`](../../docs/sms.md)。现有设计页的服务项目可维护名称、分类与门店价；卡种可维护名称与项目折扣，“停用此卡种”为软删除。后端部署及安全边界见 [`supabase/README.md`](../../supabase/README.md) 与 [`docs/backend-integration.md`](../../docs/backend-integration.md)。

应用标识：iOS 与 Android 均为 `com.yoonzm.autocare.merchant`。iOS 发布需为该标识重新创建 Apple App、Provisioning Profile 和 Actions Secrets，不得沿用 LanScope 的描述文件。
