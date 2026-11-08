# 库存管理

数据以登录会话的当前门店隔离，复用账号订阅、归属和门店营业状态校验。Edge Function 不信任客户端 store_id；所有库存写入仅允许 service_role 调用事务 RPC，客户端角色无直接写权限。新增分类、供应商、设置、审计表启用 RLS，查询按当前会话门店隔离。

## 数据与接口

`inventory_products` 保存商品资料、自动 SKU、启用状态、保质期和可选单品临期天数；`metadata_revision` 与库存 `version` 分开，资料编辑不改库存成本。新门店的初始化也通过触发器生成 SKU。分类按门店管理，重命名同步当前商品，已有单据快照不变；商品仍引用分类时不能删除。供应商独立持久化姓名、联系人、电话、备注，旧商品供应商名称自动迁移。

| action | 用途 |
| --- | --- |
| inventory_list / inventory_get | 商品、总值、批次、流水、预警、月耗用 |
| inventory_options | 当前门店分类、供应商、预警配置 |
| inventory_create / inventory_update | 商品新增/资料修改 |
| inventory_enable / inventory_disable | 零库存停用及恢复启用 |
| inventory_supplier_save | 保存完整供应商资料 |
| inventory_category_save / inventory_category_delete | 分类新增、重命名与删除 |
| inventory_settings_save | 乐观锁保存门店预警设置 |
| inventory_documents / inventory_document_get | 当前门店真实单据及详情 |
| inventory_draft / inventory_document | 继续草稿、保存草稿、提交 |
| inventory_quote | 后端 FIFO/盘点成本预览 |
| inventory_void | 校验后作废，并反向库存流水/撤销开支 |
| inventory_lookup | 当前门店 SKU 精确匹配 |
| inventory_assignments | 真实启用技师及最近工单 |

附件复用私有 `expense-vouchers` 上传和短时签名读取接口；库存提交再次校验文件真实存在且属于当前门店，最多六张，采购关联开支带同一组附件。

## 一致性

- 按门店事务锁串行化库存写入。商品/分类/供应商/设置/作废用请求 ID + 原始输入持久幂等；失败回滚后同 ID 可重试，已成功请求不能换内容。前端网络失败保留输入和请求 ID。
- 单据 ID + 修订号 + 提交原文保证草稿冲突和提交重放安全；历史展示另存商品快照，不破坏重试比较。价格与成本由服务端批次计算，保存资料不改加权成本。
- 单据作废采用保守规则：所有受影响商品仍处于该单提交后的库存版本，且单位适用，才可恢复原批次数量；任何后续变动（包括其他单据作废）都会阻止逆序撤销，避免覆盖经营数据。旧已提交单据没有可靠快照，不能作废。
- 盘点支持独立范围快照、盲盘、全店暂停出入库和单张草稿约束；提交校验所盘商品版本。作废盘点草稿释放锁，不改变库存。手工出库不足时整体回滚，展示真实缺货商品和缺少数量。
- 采购开支/盘亏成本在同一数据库事务记账；预算阻止时不落库存。库存作废只冲销本单产生的开支，不伪造外部支付/退款。
- 商品自定义临期天数优先，未指定时用门店默认值；剩余批次已过期也计入临期提醒。停用商品不计库存预警，月耗用排除已作废单据。

## 验证与发布

`supabase/tests/inventory_management.mjs` 加载全部迁移，在隔离 PostgreSQL 验证 SKU/供应商/分类、请求重放、门店隔离、批次恢复、开支撤销、盘点锁、保质期、版本冲突及调用权限。它已接入 Supabase CI。`store_initialization.mjs` 回归新门店初始化，防止 SKU 唯一约束破坏首店/分店创建。

前端专项测试覆盖真实数据绑定、无示例回退、筛选、商品和供应商保存、单据导航、浅色/深色布局及网络错误重试。相机接口需在 iOS/Android 真机确认权限与条码识别；Web/自动化环境可验证手动编码查询及结果绑定。

复现模板：在仓库根目录执行 `python apps/merchant/tools/design_to_flutter.py --bind-inventory`，再用 Dart formatter 格式化输出模板（不要手改 gen/）。数据库迁移先于 Edge Function 部署；未配置消息通知渠道，通知开关仍明确提示未接通。外部工单自动扣料、员工账号授权不在此库存页面接口中实现。

## 托管开发库的历史兼容

早期 PR #9（`7c789ec`）发布了 `202611050001_inventory_catalog` 和 `202611050002_inventory_counts_scan`，之后合并丢失了文件。两份原文件按原始校验和保存在 `supabase/deploy/legacy_inventory/`，不重新插入生产库的不可变迁移序列。

开发 CI 的 `bridge_dev_inventory.py` 只允许指定托管开发项目运行：验证两条历史版本名称与已知结构，按同一个事务应用所有待执行迁移；升级时保存原商品开关、供应商及 ID、条码和盘点草稿，旧供应商表保留为私有归档，旧盘点写接口撤权。迁移历史不删除、不改写；CI 仅在本次检出中恢复两份原历史文件供 Supabase CLI 识别已执行版本。生产迁移与校验和不变。未知历史、结构冲突或执行失败都会拒绝继续，事务整体回滚。

`legacy_inventory_bridge.mjs` 覆盖旧数据保留、暂停盘点、后续 FIFO 与末尾故障回滚；桥接脚本的单元测试验证未知历史拒绝、重复执行与开发项目限制。
