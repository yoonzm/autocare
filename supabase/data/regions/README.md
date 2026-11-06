# 公共地区字典

数据随后端迁移初始化，前端无内置地区清单。来源固定为 [china-division 2.7.0](https://www.npmjs.com/package/china-division/v/2.7.0)，上游为 [modood/Administrative-divisions-of-China](https://github.com/modood/Administrative-divisions-of-China)。原始文件与实际随包附带的 LICENSE 保存在本目录（npm 元数据标 MIT，包内 LICENSE 为 WTFPL，以保留的原文供审查）。

- `mainland.json`：上游 `dist/pca-code.json`，大陆数据截止 2023-06-30，非 2026 最新区划承诺；含统计用功能区，不将其宣称为纯民政行政区划。
- `hk-mo-tw.json`：上游 `dist/HK-MO-TW.json`，上游未注明独立统计日期。导入脚本补齐金门县、连江县及其乡镇。补充项是人工维护数据，后续应随权威区划资料复核。
- 共 34 个省级、396 个选择器第二级、3335 个第三级节点。`level` 表示选择器层级，不能用于推断法定行政级别。
- 大陆原 2/4 位编码补零到 6 位；直辖市合并“市辖区/县”到同名城市（如重庆的区和县全部归于 `500100`）。这些中间节点用于展示。
- 省直辖县级单位提升到第二级，保留原县级编码；没有区县的城市不伪造第三级，原始数据中的 9 位乡镇不导入。
- 港澳台补充节点采用 `HK-xx`、`MO-xx`、`TW-xx` 及其子级内部编码，**不是国家行政区划编码**，后续更新必须保留既有 ID，不能按新的排序重新编号。台湾的市/县作为第二级，香港与澳门按原始地理分组作为第二级。

运行 `python3 tools/build_regions.py` 可复现初始迁移。初始迁移部署后禁止修改；未来更新要新增版本化迁移，通过 `upsert` 新增/改名，停用旧节点而非删除，保留历史门店引用。数据版本由 SQL 根据所有有效节点内容计算，字典变化会自动改变版本。

接口：对 `merchant-v1` POST `{"action":"regions"}`，无须登录，返回 `{version, items:[{code,name,parent_code,level}]}`。携带上次 `version` 时未变化返回 `{version,unchanged:true}`。聚合 RPC 返回完整字典，避免 PostgREST 默认 1000 行截断。数据库对匿名与普通登录用户不开放直接读写，由 Edge Function 只读出口提供数据。

客户端缓存真实接口数据，一小时内复用；应用重启或缓存过期时向后端校验版本。缓存存储失败不阻止选择，网络失败显示重试。注册只展示省、市并提交 `province_code`、`city_code`，后端验证有效状态、层级与父子关系，使用字典名称生成兼容的 `city` 展示文本；不相信客户端名称。旧门店编码留空，原文本原样保留。

部署顺序：应用 `202611060003_regions.sql` → 部署 `merchant-v1` → 发布客户端。旧客户端不提交区划编码，注册会被要求重新选择，需协调客户端发布；不自动猜测旧的“城市·区县”文本。
