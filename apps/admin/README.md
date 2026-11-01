# 后台端 App（运营后台）

汽美管家平台运营后台 Flutter 前端原型，依据设计稿中的 21 个 `Ad*` 页面实现，全部使用内存 mock 数据，尚未接入 Supabase。

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

应用标识：iOS 与 Android 均为 `com.yoonzm.autocare.admin`。

## 演示账号

| 用户名 | 角色 | 密码 |
| --- | --- | --- |
| `ops_xiaoli` | 运营（默认） | `admin123` |
| `wang_admin` | 超级管理员 | `admin123` |
| `zhang_ops` | 已禁用，无法登录 | — |

新建账号、被重置密码的账号，首次登录必须先修改密码。

## 功能与交互

| 模块 | 设计稿页面 | 交互 |
| --- | --- | --- |
| 登录 | AdLogin | 用户名/密码校验、显隐密码、禁用账号拦截、首次登录/重置后强制改密 |
| 概览 | AdHome | MRR 与商家统计随操作联动；待办入口（审核/到期/工单）、本周新增跳转商家 |
| 商家 | AdMerchants / AdMerchantDetail / AdAdjust / AdMerchantAcct | 搜索、状态筛选；延长 7 天、升级专业版（生成补差订单）、暂停/恢复；联系店主；重发验证码、重置登录、冻结/解冻 |
| 到期跟进 | AdFollow / AdFollowLog | 已到期/7 日内/30 日内；新增并保存跟进记录 |
| 开通审核 | AdReviews / AdReviewDetail | 待审核/已通过/已驳回；证照预览；通过后商家入库，驳回需选原因 |
| 订阅与收入 | AdSubs / AdOrder / AdRefund | 收入与图表联动（点柱查看）；订单详情；退款（金额校验，仅超级管理员） |
| 工单 | AdTickets / AdTicketDetail | 状态分组；回复后自动转“处理中”；标记已解决 |
| 套餐管理 | AdPlans / AdPlanEdit | 价格、员工数上限、功能开关（仅超级管理员可改） |
| 运营账号 | AdAccounts / AdAccountEdit / AdAccountAction | 新增账号（姓名/用户名/初始密码校验，用户名查重）、重置为临时密码、升降级、禁用/启用；不能禁用自己、至少保留一名超级管理员 |
| 我的 | AdMine | 角色信息、各模块入口与角标、外观切换（跟随系统/浅色/深色，与商户端一致）、退出登录 |

权限：运营不能退款、改套餐、管理账号；这些入口点击后给出提示。所有写操作都记入 `store.audit`（操作人 · 动作）。

## 结构

```
lib/
  main.dart            入口
  theme.dart           设计稿色板（含深色令牌）与文字样式
  ui.dart              通用组件（卡片、分段控件、表单、操作弹层、提示等）
  data/models.dart     数据模型
  data/theme_state.dart 全局外观模式
  data/store.dart      mock 数据与全部业务操作（ChangeNotifier）
  pages/               各页面
test/flow_test.dart    主流程 widget 测试
```
