# 后台端 App（运营后台）

汽美管家平台运营后台 Flutter App，保留设计稿中的 19 个 `Ad*` 页面，通过 Supabase `admin-v1` 接入真实认证及运营数据。运行前先部署数据库迁移和函数；接口缺失时展示错误和重试，不回退演示数据。

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

应用标识：iOS 与 Android 均为 `com.yoonzm.autocare.admin`。

## 自动化打包

`.github/workflows/admin-ci.yml` 在后台端 PR 时只运行分析与测试；合入 `main` 后再次检查，通过后构建 Android 测试 APK，并在 `ENABLE_ADMIN_TESTFLIGHT=true` 时签名 iOS IPA 上传 App Store Connect。功能分支与 PR 不打包。Android APK 保留 14 天，iOS IPA 与构建日志保留 7 天，可从对应 GitHub Actions 运行页下载。

后台 iOS App 标识为 `com.yoonzm.autocare.admin`。TestFlight 使用仓库已有的发布证书与 App Store Connect API 密钥，以及后台专用的 `ADMIN_BUILD_PROVISION_PROFILE_BASE64` 描述文件密钥。上传成功后仍需等待 Apple 处理构建版本，并在 App Store Connect 中配置内部测试人员；若 Apple 开发者协议待账号持有人接受，上传/测试可能受阻。

## 账号与环境

默认管理员用户名为 `superman`。在目标环境运行 `supabase/deploy/bootstrap_admin.py` 创建真实账号并一次性输出随机初始密码；脚本不保存密码，不重置已有账号。首次登录及密码重置后必须先修改密码。仓库没有默认通用密码或内存演示账号。

默认连接私有化正式环境；可使用 `SUPABASE_URL` 和 `SUPABASE_PUBLISHABLE_KEY` 两个 `--dart-define` 指定环境，客户端不接收服务端密钥。详细边界、部署顺序及验收见 `docs/backend-integration.md` 的“运营后台”一节。

## 功能与交互

| 模块 | 设计稿页面 | 交互 |
| --- | --- | --- |
| 登录 | AdLogin | 用户名/密码校验、显隐密码、禁用账号拦截、首次登录/重置后强制改密 |
| 概览 | AdHome | MRR 与商家统计随操作联动；待办入口（到期/工单）、本周新增跳转商家 |
| 商家 | AdMerchants / AdMerchantDetail / AdAdjust / AdMerchantAcct | 搜索、状态筛选、延长 7 天、暂停/恢复；真实验证码、重置登录、冻结/解冻；升级与外呼暂明确阻止 |
| 到期跟进 | AdFollow / AdFollowLog | 已到期/7 日内/30 日内；新增并保存跟进记录 |
| 订阅与收入 | AdSubs / AdOrder / AdRefund | 真实收入与趋势（点柱查看）、已支付订单详情；原路退款渠道未接通，入口明确阻止 |
| 工单 | AdTickets / AdTicketDetail | 状态分组；回复后自动转“处理中”；标记已解决 |
| 套餐管理 | AdPlans / AdPlanEdit | 套餐价格/试用期与版本保存；员工上限先保存配置；未实现的功能权益开关拒绝启用（仅超级管理员可改） |
| 运营账号 | AdAccounts / AdAccountEdit / AdAccountAction | 新增账号（姓名/用户名/初始密码校验，用户名查重）、重置为临时密码、升降级、禁用/启用；不能禁用自己、至少保留一名超级管理员 |
| 短信记录 | AdSms / AdSmsDetail | 仅超级管理员：验证码短信的发送记录（验证码明文、手机号不脱敏），按全部 / 验证码 / 通知 / 失败筛选，按手机号查最新验证码，详情含内容、场景、通道与验证状态，验证码可复制，失败或需要时可重发（真实渠道，受冷却与每日额度限制）；运营账号看不到入口，服务端同样拒绝 |
| 用户账号 | AdUsers / AdUserDetail / AdUserForce | 仅超级管理员：查看全部老板与员工账号（手机号不脱敏），按全部 / 注销中 / 已注销 / 已冻结筛选，按手机号、姓名、门店名搜索；详情含门店身份、登录与安全、操作记录；强制注销需选择原因并输入「强制注销」确认，立即生效：只停用账号并让所有设备退出，不删除、不改动任何门店数据；冻结账号本期未接通（`TODO account_freeze`）并明确提示 |
| 组件库预览 | 对照设计稿「组件库」画板 | 仅超级管理员，入口在「我的 → 组件库」：展示 `packages/ui_kit` 里每个基础组件的全部状态（令牌、按钮、选择类、输入类、展示类、提示与状态、页面容器、图片上传、业务组件拆分、封装约定），可切换浅色 / 深色对照；只展示，不请求数据，也不影响业务功能 |
| 我的 | AdMine | 角色信息、各模块入口与角标、外观切换（跟随系统/浅色/深色，与商户端一致）、退出登录 |

权限：运营不能退款、改套餐、管理账号；客户端提示之外，服务端对每次请求重新验证权限及会话。写操作在数据库事务中写入审计日志，失败与越权尝试另行留痕。

支付升级、原路退款、外呼和工单通知尚未具备渠道闭环，在调用处明确阻止或说明 TODO，不会生成假支付、退款或通知结果。商家端工单来源 API 已提供，商家帮助页面的提交入口仍待接入。

## 结构

```
lib/
  main.dart            入口
  theme.dart           设计稿色板（含深色令牌）与文字样式
  ui.dart              通用组件（卡片、分段控件、表单、操作弹层、提示等）
  data/models.dart     数据模型
  data/theme_state.dart 全局外观模式
  data/store.dart      真实数据缓存、分页快照与异步业务调用（ChangeNotifier）
  data/admin_api.dart  超时、只读重试、会话刷新和写请求幂等标识
  pages/               各页面
test/flow_test.dart    真实数据边界、失败保留、登录、强制改密和异步提交测试
test/visual_test.dart 手机尺寸下的浅色/深色页面回归（测试数据只存在测试文件）
```
