# autocare_ui_kit · 基础组件库

按设计稿「组件库」画板（总览、令牌、按钮、选择类、输入类、展示类、提示与状态、页面容器、图片上传、业务组件拆分、封装与定制约定）实现的 Flutter 基础组件库。页面只做组合，不写样式。

```dart
import 'package:autocare_ui_kit/autocare_ui_kit.dart';
```

## 分层

| 层 | 目录 | 内容 |
| --- | --- | --- |
| 1 令牌 | `src/tokens` | `AppTokens`（颜色、字号、阴影，浅色 / 深色）、`AppRadius`、`AppSpacing` |
| 2 基础元素 | `src/atoms` | `AppButton`、`AppIconButton`、`AppChoiceChip` / `AppChoiceGroup`、`AppSwitch`、`AppCheck` / `AppRadio` / `AppAddToggle`、`AppStepper`、`AppStatusTag`、`AppBadge`、`AppAvatar` |
| 3 组合组件 | `src/molecules` | `AppCard` / `AppSectionTitle`、`AppListRow` / `AppListGroup`、`AppFormCard` / `AppFormRow` / `AppNumberBox` / `AppSelectField` / `AppAmountField` / `AppTextArea`、`AppSearchBar`、`AppSegmented`、`AppBanner`、`AppHeroCard`、`AppImageUploader`（grid / slot） |
| 4 页面容器 | `src/containers` | `AppPageHeader`、`AppBottomBar`、`showAppBottomSheet`、`showAppDialog`、`AppBottomNav` |
| 状态 | `src/states` | 直接引用 `async_kit` 的 `EmptyView`、`ErrorView`、`AppSkeleton`、`AppToast` 等，不重复实现 |

第 5 层「业务组件」（商品行、会员行、结算明细）放在各业务模块里，不在本包；设计稿的拆分示例在后台预览页「业务组件拆分」里演示。上层可以引用下层，下层不能反向引用。

## 封装约定

- 取值：`AppTokens.of(context)`。应用主题里注册了 `AppTokens` 扩展就用扩展，否则按主题亮度取 `light` / `dark`。
- 颜色只从令牌取：除 `app_tokens.dart` 外不写 `Color(0x…)`、`Colors.*`（测试 `package_boundary_test` 检查）。
- 定制只走语义参数（`kind`、`size`、`tone`、文案、图标、插槽），没有 `color`、`radius`、`textStyle` 这类自由样式参数（同样有测试检查）。
- 组件受控：选中、开关、数值都由外部传入；组件不持有业务数据、不请求数据。
- 通用逻辑内置在组件里：防重复点击、点击热区 44、长按连续增减、搜索防抖 300ms、数字范围钳制、手机号分段与金额千分位格式化、语义标签。
- 表单输入的 `hint` 必填，没值时一定有占位文字。

## 预览与验证

- 后台端「我的 → 组件库」（仅超级管理员）逐个展示所有组件的全部状态，可切换浅色 / 深色对照，不影响业务功能。
- `flutter analyze`、`flutter test`（每个组件的行为测试、令牌取值、深色渲染、包边界）。

## 暂未做

- 现有业务页面（后台端 `ui.dart`、商户端 `kit/`）仍使用各自的实现，尚未迁移到本包。
- 图片上传组件只负责展示：选图、压缩、HEIC 转 JPG、权限申请与上传请求属于适配层，尚未提供。
- 没有 golden 截图测试（字体与平台差异会让截图不稳定）。
