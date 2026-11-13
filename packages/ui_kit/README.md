# autocare_ui_kit · 基础组件库

`AppSmsCodeButton(sending:, seconds:, sent:, onPressed:)`：纯展示验证码按钮，固定宽 132、视觉高 36、热区高 44；可发送、发送中、倒计时及重发四态，发送 / 倒计时 / 空回调禁点。不计时、不请求后端，调用端持有发送与错误状态。商户端复用 `SmsCodeController`，后台组件预览包含全部状态。

普通按钮提前预留 loading 的内容宽度，原文案保持不变；图标按钮 loading 保留背景，图标隐藏、20px 转圈居中，按钮尺寸不变。

按设计稿「组件库」画板（总览、令牌、按钮、选择类、输入类、展示类、提示与状态、页面容器、图片上传、业务组件拆分、封装与定制约定）实现的 Flutter 基础组件库。页面只做组合，不写样式。

```dart
import 'package:autocare_ui_kit/autocare_ui_kit.dart';
```

## 分层

| 层 | 目录 | 内容 |
| --- | --- | --- |
| 1 令牌 | `src/tokens` | `AppTokens`（颜色、字号、阴影，浅色 / 深色）、`AppRadius`、`AppSpacing` |
| 2 基础元素 | `src/atoms` | `AppButton`、`AppIconButton`、`AppChoiceChip` / `AppChoiceGroup`、`AppSwitch`、`AppCheck` / `AppRadio` / `AppAddToggle`、`AppStepper`、`AppStatusTag`、`AppBadge`、`AppAvatar` |
| 3 组合组件 | `src/molecules` | `AppCard` / `AppSectionTitle`、`AppListRow`（`size`：54 / 60 / 70）/ `AppListGroup`、`AppTextField`（标签在上）、`AppFormCard` / `AppFormRow` / `AppNumberBox` / `AppSelectField` / `AppAmountField` / `AppTextArea`、`AppSearchBar`、`AppSegmented`、`AppBanner`、`AppHeroCard`（含 `custom` 与渐变样式）、`AppImageUploader`（grid / slot） |
| 4 页面容器 | `src/containers` | `AppPageHeader`、`AppBottomBar`、`showAppBottomSheet`、`showAppDialog`、`AppBottomNav` |
| 状态 | `src/states` | 直接引用 `async_kit` 的 `EmptyView`、`ErrorView`、`AppSkeleton`、`AppToast` 等，不重复实现 |

第 5 层「业务组件」（商品行、会员行、结算明细）放在各业务模块里，不在本包；设计稿的拆分示例在后台预览页「业务组件拆分」里演示。上层可以引用下层，下层不能反向引用。

> 使用规范（后台端强制、商户端优先但不牺牲设计稿）见 `docs/frontend-guidelines.md` 第 17 节。

## 封装约定

- 取值：`AppTokens.of(context)`。应用主题里注册了 `AppTokens` 扩展就用扩展，否则按主题亮度取 `light` / `dark`。
- 颜色只从令牌取：除 `app_tokens.dart` 外不写 `Color(0x…)`、`Colors.*`（测试 `package_boundary_test` 检查）。
- 定制只走语义参数（`kind`、`size`、`tone`、文案、图标、插槽），没有 `color`、`radius`、`textStyle` 这类自由样式参数（同样有测试检查）。
- 组件受控：选中、开关、数值都由外部传入；组件不持有业务数据、不请求数据。
- 通用逻辑内置在组件里：防重复点击、点击热区 44、长按连续增减、搜索防抖 300ms、数字范围钳制、手机号分段与金额千分位格式化、语义标签。
- 表单输入的 `hint` 必填，没值时一定有占位文字。

## 按钮图标与加载态

- `AppButton`、`AppIconButton`（含 `.pill`）保留 `icon: IconData`，新增 `svg: String` 和可选 `darkSvg: String`，直接接收现有 SVG 源码；`icon` 与 `svg` 互斥，`darkSvg` 必须配合 `svg`。
- SVG 用于单色按钮图标，路径保留，颜色统一跟随按钮语义、主题和禁用状态；不用于保留多色插画。未提供 `darkSvg` 时复用 `svg`。
- `AppIconButton(loading: true)` 使用 `async_kit.AppSpinner` 原位显示 20px 转圈，隐藏原图标、文字和数量，禁用点击，保留正常状态的宽高；主色按钮用前景色，其余用主色。小号按钮仍保留至少 44px 点击热区。
- 本次能力依据现有商户 SVG 图标及 `docs/frontend-guidelines.md` 的图标按钮加载规范补齐；不修改业务页面及已有按钮默认外观。

```dart
AppButton(label: '新增', svg: addSvg, onPressed: add);
AppIconButton(
  svg: saveSvg,
  darkSvg: saveDarkSvg,
  semanticLabel: '保存',
  loading: submitting,
  onPressed: save,
);
```

## 选择标签：单选、多选与排列

2026-11-13 用户确认商户标签统一采用组件库标准外观；预约时段保留三列等宽，移除“原时段”专用标记。此扩展沿用组件库选择类画板的 pill / tile 样式，不引入自由颜色或尺寸参数。

- `AppChoiceGroup<T>` 保留 `items / selected / onChanged / kind / expanded` 单选接口。重复点击当前选项不再回调；禁用项不可点击，也不显示为有效选中。
- `AppChoiceGroup<T>.multiple` 使用 `selectedValues: Set<T>` 与 `onChanged: ValueChanged<Set<T>>`。点击已选项取消，结果为新的只读集合，不修改调用者集合；状态始终由调用者持有。
- 默认 `layout: AppChoiceLayout.wrap` 自动换行，横纵间距均为 8。
- `layout: AppChoiceLayout.horizontal` 单行横向滚动，适用于动态分类；可用 `trailing` 放独立操作，操作不参与选择。外层须提供有限宽度。
- `columns: 3` 等宽三列，保持 8px 间距；最后一行不足三项时不拉伸。须提供有限宽度，不能与 horizontal / expanded 同时使用。
- `expanded: true` 保留既有每项一行、撑满宽度的行为。
- `semanticLabel` 提供组名称；单选带互斥语义，多选不带互斥语义。业务层负责动态选项失效后的回退、权限和异步锁。
- 标签文字保持单行，空间不足时省略，读屏仍获得完整文案。禁用外观遵循标准组件，不使用删除线。

```dart
AppChoiceGroup<String>.multiple(
  items: skills,
  selectedValues: selectedSkills,
  onChanged: setSkills,
);
AppChoiceGroup<String>(
  items: slots,
  selected: selectedTime,
  onChanged: setTime,
  kind: ChipKind.tile,
  columns: 3,
);
AppChoiceGroup<String?>(
  items: categories,
  selected: category,
  onChanged: setCategory,
  layout: AppChoiceLayout.horizontal,
);
```

商户顶部会员卡种、服务分类和回访筛选使用横向标签；真正的分段条、会员等级卡、复杂支付/充值选择卡不属于此次标签迁移。

## 预览与验证

- 后台端「我的 → 组件库」（仅超级管理员）逐个展示所有组件的全部状态，可切换浅色 / 深色对照，不影响业务功能。
- `flutter analyze`、`flutter test`（每个组件的行为测试、令牌取值、深色渲染、包边界）。

## 暂未做

- 后台端已迁移到本包（见下）；商户端已统一按钮与普通选择标签，其他组件仍按设计差异保留现有实现。
- 图片上传组件只负责展示：选图、压缩、HEIC 转 JPG、权限申请与上传请求属于适配层，尚未提供。
- 没有 golden 截图测试（字体与平台差异会让截图不稳定）。

## 后台端的使用方式

- `apps/admin/lib/ui.dart` 只保留后台自己的页面骨架（`AdPage`）和业务展示（`KV`、`ToneTile`、`pickOption`），并 `export` 本包；按钮、卡片、状态标签、列表行、输入框、开关、分段控件、弹层、对话框等一律用本包组件。
- 提交类按钮只传 `loading`：页面自己维护加载状态，组件负责转圈、降透明度和防重复点击；对话框和弹层的异步确认用 `showAppDialog(onConfirm:)`，处理期间确认按钮 loading、取消不响应，失败时保持打开并提示。
- 后台主题注册了 `AppTokens` 扩展，`test/theme_tokens_test.dart` 保证后台令牌 `C` 与 `AppTokens` 取值一致。
- 迁移中补进本包的语义：`AppTextField`；`Tone.violet / gold / okOnDark / dark`；`SegmentItem.badgeTone`；`AppHeroCard.custom` 与渐变样式；`AppChoiceGroup(expanded)`；`AppIconButton(kind: primary)`；`AppSearchBar(keyboard)`；`showAppDialog(onConfirm / onError)`；`showAppBottomSheet(subtitle)`。
- 后台端没有迁移的：底部 4 项标签栏（设计稿没有中间扫码按钮，`AppBottomNav` 固定为 4 项加扫码）、商家渐变图标块 `ToneTile`、各页面里的头像渐变与深色卡上的白字等页面级样式。
