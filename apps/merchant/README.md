# Merchant app

汽美管家商户端 Flutter App，老板、店长、前台和技师共用同一应用。业务数据走真实接口；未接通的渠道或能力明确标注 TODO 并阻止假成功，不提供未登录设计预览或样例数据回退。一期范围见 [`docs/mvp-v1.md`](../../docs/mvp-v1.md)。

页面按业务组织在 `lib/pages/`，共享图标在 `lib/resources/`，导航在 `lib/navigation/`。后续直接维护 Dart 源码，设计稿仅作视觉参考；设计转 Flutter 的生成、派生与绑定脚本已经删除。维护规范见 [`docs/frontend-guidelines.md` 第 18 节](../../docs/frontend-guidelines.md)，逐页验收证据见 [`docs/frontend-migration.json`](../../docs/frontend-migration.json)。`tools/golden/` 仅用于视觉回归，不生成页面代码。

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

当前本地 Android release 构建沿用工程内的调试签名配置，用于构建验证；发布签名需在发布流程中另行配置。

原始界面从 LanScope 仓库的 `claude/sleepy-clarke-4ehenr` 分支（提交 `e696c67`）迁入，保留的界面继续以既有视觉为基线。
