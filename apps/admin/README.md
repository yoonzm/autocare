# 后台端 App（运营后台）

汽美管家平台运营后台 Flutter 前端原型，依据设计稿中的 21 个 `Ad*` 页面实现，全部使用内存 mock 数据，尚未接入 Supabase。

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

## 演示账号

| 账号 | 角色 | 密码 |
| --- | --- | --- |
| `ops@chiguang.example` | 运营（默认） | `admin123` |
| `wang@chiguang.example` | 超级管理员 | `admin123` |
| `zhang@chiguang.example` | 已禁用，无法登录 | — |

登录后需二次验证，演示验证码 `123456`。

## 功能与交互

| 模块 | 设计稿页面 | 交互 |
| --- | --- | --- |
| 登录 | AdLogin | 邮箱/密码校验、显隐密码、禁用账号拦截、短信二次验证 |
| 概览 | AdHome | MRR 与商家统计随操作联动；待办入口（审核/到期/工单）、本周新增跳转商家 |
| 商家 | AdMerchants / AdMerchantDetail / AdAdjust / AdMerchantAcct | 搜索、状态筛选；延长 7 天、升级专业版（生成补差订单）、暂停/恢复；联系店主；重发验证码、重置登录、冻结/解冻 |
| 到期跟进 | AdFollow / AdFollowLog | 已到期/7 日内/30 日内；新增并保存跟进记录 |
| 开通审核 | AdReviews / AdReviewDetail | 待审核/已通过/已驳回；证照预览；通过后商家入库，驳回需选原因 |
| 订阅与收入 | AdSubs / AdOrder / AdRefund | 收入与图表联动（点柱查看）；订单详情；退款（金额校验，仅超级管理员） |
| 工单 | AdTickets / AdTicketDetail | 状态分组；回复后自动转“处理中”；标记已解决 |
| 套餐管理 | AdPlans / AdPlanEdit | 价格、员工数上限、功能开关（仅超级管理员可改） |
| 运营账号 | AdAccounts / AdAccountEdit / AdAccountAction | 新增账号（邮箱查重）、重置密码、升降级、禁用/启用；不能禁用自己、至少保留一名超级管理员 |
| 我的 | AdMine | 角色信息、各模块入口与角标、退出登录 |

权限：运营不能退款、改套餐、管理账号；这些入口点击后给出提示。所有写操作都记入 `store.audit`（操作人 · 动作）。

## 结构

```
lib/
  main.dart            入口
  theme.dart           设计稿色板与文字样式
  ui.dart              通用组件（卡片、分段控件、表单、操作弹层、提示等）
  data/models.dart     数据模型
  data/store.dart      mock 数据与全部业务操作（ChangeNotifier）
  pages/               各页面
test/flow_test.dart    主流程 widget 测试
```
