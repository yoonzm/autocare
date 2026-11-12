# Shared packages

待出现实际复用需求时再建立契约或共享包；不预设跨技术栈的 UI 复用。

当前 Flutter 两端已有实际复用：

| 包 | 职责 | 依赖边界 |
| --- | --- | --- |
| `async_kit` | Spinner、骨架元素与通用布局、空/错误态、Toast、异步按钮、数据加载状态和主题令牌 | 运行时仅依赖 Flutter；不包含业务页面、路由或后端 SDK |
| `ui_kit` | 基础组件库（`autocare_ui_kit`）：令牌 `AppTokens`、基础元素、组合组件、页面容器，按设计稿「组件库」画板实现，浅色 / 深色自动切换 | 仅依赖 Flutter 与 `async_kit`（空 / 加载 / 错误 / Toast 直接引用）；不含业务逻辑、路由、后端 SDK，也不引用任何应用代码 |
| `supabase_adapter` | 在 API 边界把 Supabase 异常转换成 `AppError` | 依赖 `async_kit` 和 Supabase SDK；共享 UI 不反向依赖它 |

`async_kit/lib/async_kit.dart` 是公共入口，实现按职责放在 `lib/src/`。各端完整主题在各端维护，通过 `AsyncKitTheme` 注入共享反馈所需令牌及权限提示；不共享应用级全局亮度状态。

商户生成页面动作清单与服务/卡种/资料页骨架仍在商户应用。原 `apps/merchant/lib/kit/async_kit.dart` 统一导出共享组件及这些商户适配，保留既有导入路径，生成页面无需修改。

各包分别运行 `flutter pub get`、`flutter analyze`、`flutter test`。共享包变更同时触发两端 CI；边界测试确保 UI 包没有后端 SDK 依赖或商户专用配置。

`ui_kit` 的分层、封装约定与目录见 [`ui_kit/README.md`](ui_kit/README.md)。当前只有后台端使用（「我的 → 组件库」预览页），商户端与既有业务页面暂不迁移，保持原有实现；后续迁移时按页面逐个替换，并保持设计稿视觉不变。
