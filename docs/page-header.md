# 页面顶部栏（固定头部）

顶部栏不随内容滚动，统一用 `AppPageHeader`（`apps/merchant/lib/kit/page_header.dart`）。

- **HPage 页面**：`HPage(header: AppPageHeader(...), flow: ...)`。头部在滚动区外，自带状态栏留白和左右 20 边距，flow 里不要再写头部和 `topInset`；flow 顶部留 8（头部下方自带 8，合起来是设计稿的 16 间距）。
- **ListView 页面**：`HHeaderFrame(bg:, header:, body: ListView(...))`，ListView 顶部 padding 用 8。
- 内容滚到头部下方时出现一条淡分隔线，没滚动时和原来一样。
- `AppPageHeader` 参数：`title` 或 `center`（自定义标题区）、`leading`（`back` / `close` / `none`）、`onLeading`、`leadingEnabled`、`trailing`（`AppHeaderAction` 黑/彩色圆钮，`AppHeaderCircle` 白色圆钮）。

## 迁移进度

- 全部带返回/关闭按钮的页面都已迁移（HPage 页面 ≈ 65 个，另有订单列表/详情、全部商品、商品编辑、新增供应商用 `HHeaderFrame`），两个骨架屏（员工、预约设置）也改用同一个头部。
- 本来就固定、没动的：预约管理、会员详情、服务项目、新建预约、我的（用 `SubHeader`，在 `Column` 里固定）；法律协议页（WebView 上方固定）。
- 没有顶部栏的页面：完成页、全屏相机（扫码）、员工端认证/无权限/身份页。`test/page_header_guard_test.dart` 约束：新增 HPage 页面必须传 `header:`，否则要加进白名单。
- **例外（已确认，保持现状）**：带大标题的主标签页（会员列表、库存主页、首页、统计、员工端首页/前台首页）的大标题随内容滚动，不做固定头部：可视区域更大。新增主标签页沿用这个写法；有「返回 / 关闭」的二级页面仍必须用固定头部。
- 修了一个附带问题：忘记密码 / 注册 / 修改密码 / 修改手机号 / 编辑卡种·套餐·项目等页面原来的返回按钮没有点击事件，现在统一能返回。
- `ui_kit` 里还有一个同名 `AppPageHeader`，`SubHeader`（`widgets/common.dart`）也是一套头部，后续合并。
