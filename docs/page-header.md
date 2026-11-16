# 页面顶部栏（固定头部）

顶部栏不随内容滚动，统一用 `AppPageHeader`（`apps/merchant/lib/kit/page_header.dart`）。

- **HPage 页面**：`HPage(header: AppPageHeader(...), flow: ...)`。头部在滚动区外，自带状态栏留白和左右 20 边距，flow 里不要再写头部和 `topInset`；flow 顶部留 8（头部下方自带 8，合起来是设计稿的 16 间距）。
- **ListView 页面**：`HHeaderFrame(bg:, header:, body: ListView(...))`，ListView 顶部 padding 用 8。
- 内容滚到头部下方时出现一条淡分隔线，没滚动时和原来一样。
- `AppPageHeader` 参数：`title` 或 `center`（自定义标题区）、`leading`（`back` / `close` / `none`）、`onLeading`、`leadingEnabled`、`trailing`（`AppHeaderAction` 黑/彩色圆钮，`AppHeaderCircle` 白色圆钮）。

## 迁移进度

- 已迁移（第一批）：开支列表、员工与权限、库存单据、挂单、消费记录、会员卡种与权益（两处）、员工施工记录、订单列表、订单详情、全部商品。
- 预约管理页本来就用 `SubHeader` 固定在滚动区外，未改。
- 暂未迁移：带大标题的主标签页（会员、库存主页、首页、统计、设置）；其余表单页、详情页、员工端页面；登录注册流程。
- `ui_kit` 里还有一个同名 `AppPageHeader`（返回图标与设计稿不一致），后续统一时合并。
