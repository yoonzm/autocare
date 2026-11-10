# AutoCare

汽美管家多端产品仓库。已有 Flutter 商户端与后台端原型，其余端与 Supabase 后端按需逐步建设。

| 路径 | 用途 | 状态 |
| --- | --- | --- |
| `apps/merchant` | Flutter 商户端（iOS / Android） | V1 注册/密码登录、服务项目和会员卡种维护接入 Supabase；其余见 TODO |
| `apps/member-mini` | 会员端小程序（原生微信小程序） | 19 页接入真实后端；线上支付、通知等见 TODO |
| `apps/staff-mini` | 店员端小程序 | 预留 |
| `apps/admin` | Flutter 后台端（运营后台） | 已实现，mock 数据 |
| `apps/desktop` | 桌面端 App | 预留 |
| `packages` | 共享契约与业务包 | 预留 |
| `supabase` | 数据库迁移、Edge Functions | 商户 V1 基础后端 |

## 开发

```sh
cd apps/merchant
flutter pub get
flutter analyze
flutter test
flutter run
```

目前有商户端、后台端两个相互独立的 Flutter 工程，暂不建立 Dart workspace；出现共享代码时再评估。各端独立构建和版本化，不把小程序或 Supabase 纳入 Dart workspace。

后台端同理：`cd apps/admin`，命令相同，详见 `apps/admin/README.md`。

后端接入必须遵守 [开发约束](AGENTS.md) 与 [后端接入标准](docs/backend-integration.md)。

会员端小程序：`cd apps/member-mini && npm test`；用微信开发者工具导入该目录预览，说明见 `docs/member-mini-integration.md`。

## 发布

PR 运行商户端检查；`main` 的商户端变更触发内测构建。iOS TestFlight 发布必须先配置独立应用和签名，Android APK 目前仅供内部测试，不是商店正式包。详见 `docs/release.md`。

本仓库从原仓库的 `claude/sleepy-clarke-4ehenr` 分支提交 `e696c67` 快照建立；原仓库未被修改。
