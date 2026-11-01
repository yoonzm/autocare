# AutoCare

汽美管家多端产品仓库。当前仅迁入 Flutter 商户端原型，其余端与 Supabase 后端按需逐步建设。

| 路径 | 用途 | 状态 |
| --- | --- | --- |
| `apps/merchant` | Flutter 商户端（iOS / Android） | 登录、门店、会员、服务项目、会员卡种已接 Supabase；其他页面仍为 mock |
| `apps/member-mini` | 会员端小程序 | 预留 |
| `apps/staff-mini` | 店员端小程序 | 预留 |
| `apps/admin` | 后台端 App | 预留 |
| `apps/desktop` | 桌面端 App | 预留 |
| `packages` | 共享契约与业务包 | 预留 |
| `supabase` | 数据库迁移、Edge Functions | 商户基础表与 RLS 已建立 |

## 开发

```sh
cd apps/merchant
flutter pub get
flutter analyze
flutter test
flutter run
```

当前只有一个 Flutter 工程，暂不建立 Dart workspace；出现第二个 Flutter 包时再评估。各端独立构建和版本化，不把小程序或 Supabase 纳入 Dart workspace。

## 发布

PR 运行商户端检查；`main` 的商户端变更触发内测构建。iOS TestFlight 发布必须先配置独立应用和签名，Android APK 目前仅供内部测试，不是商店正式包。详见 `docs/release.md`。

本仓库从原仓库的 `claude/sleepy-clarke-4ehenr` 分支提交 `e696c67` 快照建立；原仓库未被修改。
