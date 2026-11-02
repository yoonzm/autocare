# Supabase 商户 V1

本目录包含商户注册/登录、服务项目、会员卡种、次卡套餐配置的数据库迁移和 `merchant-v1` Edge Function。所有业务写入和归属校验都在云函数中；客户端不持有 `service_role` 密钥。会员、订单等不在 V1 范围。

开发项目：`autocare-dev`（`wghsytekrmpcofpugyua`）。`supabase/` 变更推送后只运行后端检查；推送到 `main` 或当前 `feat/merchant-supabase-v1` 时，通过检查后依次验证迁移历史、执行 `supabase db push`、部署 `merchant-v1`。数据库通过 IPv4 Session Pooler 连接，密码在 GitHub Secret `SUPABASE_DEV_DB_PASSWORD`；部署令牌在 `SUPABASE_DEV_ACCESS_TOKEN`，限定开发项目，永不过期但可手动吊销。首个迁移已通过 Dashboard 应用并登记到 CLI 迁移历史，后续数据库变更必须添加新的版本化 SQL 迁移文件，不要直接修改已部署迁移。正式环境应使用独立的项目、迁移历史和凭据。

部署顺序：

1. 在目标项目执行版本化迁移，先在备份/测试环境验证。旧表如已有数据，迁移前必须人工审查，不能直接删除。开发项目由 GitHub Actions 自动执行 `db push`。
2. 部署 `functions/merchant-v1/index.ts` 为 `merchant-v1`。公共注册/登录动作需要关闭平台层 JWT 校验（`config.toml`），函数内部对所有业务动作自行验证访问令牌。
3. 仅开发项目可设置 Edge Function 密钥 `ALLOW_MOCK_SMS=true`：`send_mock_code` 会生成随机 6 位验证码，只存 SHA-256 哈希到 `phone_otps` 表（5 分钟有效、同一手机号 60 秒内不能重复获取、错误 5 次作废），并把明文随响应返回给开发环境的 App（代替短信）。`check_code` 只校验不消耗，`register` 校验通过后才创建账号并使验证码失效（一次性）。生产环境不得设置该密钥；真实短信供应商接入仍为 `TODO`，因此生产注册暂不可用。
4. 客户端只使用项目 URL 与 publishable key。绝不将 `SUPABASE_SERVICE_ROLE_KEY` 下发到 App。

云函数按 `auth.ts`、`services.ts`、`cards.ts`、`shared.ts`、`types.ts`、`index.ts` 分模块，`types.ts` 定义动作及数据模型。已提供 `send_mock_code`（同一手机号每天最多发 10 次，超限返回“今日发送次数已达上限”，按东八区自然日计）、`check_code`、`forgot_verify`（忘记密码第 1 步：验证码正确且该手机号是已开通门店的账号）、`reset_password`（第 2 步：再次校验验证码并设置新密码，随后让该账号的全部会话失效，所有设备都要重新登录）、`register`（保存城市、地址、联系人、身份、工位数量、主营业务，开通 14 天试用，并给新门店初始化设计稿里的示例数据：按所选主营业务生成设计稿的服务项目（洗车美容 → 洗车 + 内饰，镀晶镀膜 → 镀晶镀膜，隐形车衣 → 贴膜；设计稿没有改色膜、保养维修的示例，只选这两项时服务项目为空；默认三项共 8 个），以及黑金卡、金卡、银卡、普通会员 4 个卡种；任何一步失败都会整体回滚，不留半成品门店；数据定义在 `defaults.ts`，店主之后自行修改）、`login_password`、`get_store`（读取当前门店资料）、`change_password`（校验当前密码）、`change_phone`（当前号码与新号码两个验证码）、`delete_account`（进入 15 天注销冷静期，期间重新登录即撤销；到期清除的定时任务仍为 `TODO`）、`login_code`（验证码登录：校验一次性验证码、确认手机号已注册后签发会话）、`list/save/delete`（服务项目与卡种）、卡种的 `rules` / `save_rules`（门店通用规则）接口；卡种 `save` 还保存卡面颜色、升级条件、积分倍率、生日礼、预约优先、有效期。服务项目删除为物理删除；卡种因既有界面文案为“停用”，`delete` 为软删除（`active=false`），列表只显示启用卡种。次卡套餐（`kind=packages`，迁移 `202611010008_card_packages.sql`，逻辑在 `packages.ts` / `package_rules.ts`）：`list` 返回套餐及其包含服务（含服务名称、单次价），`save` 经 SECURITY DEFINER 函数 `save_card_package` 在一个事务里写套餐与服务明细并校验服务属于本店，`delete` 为软删除（`deleted_at`，已下架 `active=false` 的仍在列表中显示“已下架”）；保存字段：名称、售价、有效期（3/6/12/24 个月或永久）、每人限购、适用车型、是否在会员小程序展示、说明、上架状态、包含服务及次数。服务项目被套餐引用时删除会被拒绝（提示“该服务项目已被次卡套餐使用，请先从套餐中移除”）。后端接口已通过开发项目 API 冒烟测试。商户端保留生成的编辑页面代码，通过非生成代码适配输入与保存动作；卡种列表由设计页面的卡片模板派生并绑定真实数据。

开发时执行 `cd supabase/functions/merchant-v1 && deno task check` 检查模块类型。Dashboard 部署须同时包含入口及其依赖模块；`types.ts` 是编译期类型文件，不含运行时代码。
