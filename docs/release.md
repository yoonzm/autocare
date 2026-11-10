# 发布约定

- `main` 合入后，按受影响目录执行各端 CI / 内测发布；各端独立版本。Supabase 正式后端按下述流程自动部署，App 签名和发布约束保持原有配置。
- 商户端使用 `.github/workflows/merchant-internal.yml` 执行 Flutter 检查和内测打包；后台端仍由独立工作流处理。后端由 `.github/workflows/supabase-dev.yml` 独立检查和部署，仅在 `supabase/` 目录变更时运行，不触发商户端打包。
- iOS 标识为 `com.yoonzm.autocare.merchant`。先在 Apple Developer / App Store Connect 创建对应 App ID、App 和 App Store 描述文件；再在新 GitHub 仓库配置 `BUILD_CERTIFICATE_BASE64`、`P12_PASSWORD`、`BUILD_PROVISION_PROFILE_BASE64`、`ASC_KEY_ID`、`ASC_ISSUER_ID`、`ASC_PRIVATE_KEY`。不要复制 LanScope 的描述文件。配置完成后在仓库 Variables 中设置 `ENABLE_MERCHANT_TESTFLIGHT=true`，此前 iOS 发布任务会跳过。
- 商户端检查在任意分支推送 `apps/merchant/` 变更后运行；仅 `main` 与当前 `feat/merchant-supabase-v1` 分支同时执行内测打包。V1 验证结束后应移除特性分支上传条件。TestFlight 上传仍受 `ENABLE_MERCHANT_TESTFLIGHT` 和 `merchant-testflight` 环境签名配置约束。
- Android 当前 APK 使用 Flutter 默认调试签名，不可用于正式商店发布。正式发布需专用 keystore、上传渠道及审批流程。
- Supabase 开发项目 `autocare-dev`：任意分支推送 `supabase/` 变更后只运行后端检查；`main` 或 `feat/merchant-supabase-v1` 通过检查后依次核对迁移历史、自动执行 `db push`、部署 `merchant-v1`，不触发商户端打包。GitHub Secret `SUPABASE_DEV_ACCESS_TOKEN` 为仅限开发项目的函数部署令牌，`SUPABASE_DEV_DB_PASSWORD` 为开发库连接密码，均不得放入代码或客户端。首个 migration 已登记 CLI 历史；后续 schema 变更必须通过新增 `supabase/migrations/` SQL 文件提交，不得直接修改已部署迁移。生产环境使用独立项目、令牌及审批。
- 新增端时增加各自 CI / 发布工作流，保持版本号与发布状态独立；共享包变化需触发所有依赖它的端。

## 私有化正式后端

- `.github/workflows/supabase-prod.yml` 在 `main` 的 `supabase/**` 或本工作流变更时自动执行，也支持在 `main` 手动 Run workflow。类型检查、Deno 测试及部署包安全检查通过后，发布到 `https://autocare.mymember.ltd`。Cloud 开发环境仍由 `supabase-dev.yml` 独立部署，两边不自动同步业务数据。
- GitHub Environment `supabase-prod` 仅允许 `main`，配置 `SUPABASE_PROD_SSH_KEY` 和 `SUPABASE_PROD_KNOWN_HOSTS` 两个 Secret。部署专用 SSH key 只允许调用服务器 root 所有的 `/usr/local/lib/autocare-deploy/production.py`，禁用任意命令、终端和端口转发。数据库和服务端密钥留在服务器，不上传到 Actions。
- 部署包由 `supabase/deploy/package.py` 生成，统一换行为 LF，保证 Windows 手动部署与 Linux Actions 的迁移校验值一致。服务器接收包前检查路径、文件类型、重复项和大小限制。
- 部署先运行 `/usr/local/sbin/supabase-backup`，按版本逐条事务执行未应用 SQL，同时登记 `supabase_migrations.schema_migrations` 和 `autocare_deploy.migrations`。已应用迁移内容变化、遗漏历史或插入旧版本会拒绝发布。后续改表必须新增 SQL，不能修改旧文件。
- 同时更新 `merchant-v1`、`admin-v1` 与 `member-v1` 后重建 functions 容器，并经公网 HTTPS 验证公开登录入口、未登录业务鉴权、短信输入校验和会员端未登录守卫（不带令牌必须 401，不会调用微信或短信）。接口检查失败时同时恢复上一份函数代码；已成功提交的数据库迁移保留，不自动回滚数据，需评估后使用新迁移修复或从备份恢复。发布版本记录在服务器 `/opt/supabase/.autocare-release.json`；`revision` 为来源 Git 基线，`source_sha256` 标识打包的精确后端内容（包含尚未提交的工作区变更），服务器在部署前重新校验内容摘要。
- 初次部署或更新 `supabase/deploy/production.py` 时，需要管理员通过现有 SSH 将该文件安装到上述 root 所有的入口，再发布。此文件是服务器受信任的执行程序，不由上传包替换。手动部署和 Actions 使用同一个包格式、同一个入口。
- 短信一期使用助通，凭据和按用途配置的模板放服务器 `.env.sms`，由 Compose 注入；所有环境均使用真实短信，移除短信 mock 配置，详见 `sms.md`。车牌识别使用服务器 `.env.recognition` 中的百炼配置，由 Compose 独立注入；随机 mock 已移除，详见 `plate-recognition.md`。更新服务器部署入口后再部署新增迁移和函数，渠道配置缺失时明确返回未启用错误。健康检查只用无效号码探测真实短信入口，不会发送付费短信。私有化发布安装结构和函数，不复制 Cloud 开发用户或业务数据。

## 商户端后端选择

- App 默认地址和客户端公开密钥指向私有化正式环境。自动打包沿用默认值，不需要额外配置。
- 需要 Cloud 测试包时，在 Merchant Build 手动触发并选择 `backend_environment=development`；本地在 `apps/merchant` 执行 `flutter build apk --release --dart-define-from-file=config/dev.json`，iOS 同理。
- 测试与正式环境使用同一个 App 标识，安装会覆盖原包；切换时重新登录，不共享两边会话。页面、导航和交互布局不变。

## 会员端小程序

- 源码 `apps/member-mini`，用微信开发者工具上传体验版 / 提审，版本与其他端独立。`.github/workflows/member-mini.yml` 在 `apps/member-mini/**` 变更时运行 Node 测试与样式生成检查，不自动上传（上传需要小程序密钥，不放进 Actions）。
- 后端：迁移 `202611100001_member_portal.sql` 与独立的 `member-v1` 云函数随 `supabase-prod.yml` 自动部署（开发项目的 `supabase-dev.yml` 同样单独部署 `member-v1`）；微信凭证 `/opt/supabase/.env.wechat` 由管理员配置（样例 `supabase/deploy/wechat.env.example`），更新后的 `production.py` 需管理员重新安装到服务器入口。详见 `docs/member-mini-integration.md`。
- 临时测试：`.github/workflows/member-mini-publish.yml`（手动）可把会员端上传到 my-baas-helper 日志监控小程序（`wxdba60af414abc8db`）的开发版本或生成预览二维码，需要环境密钥 `MEMBER_MINI_UPLOAD_KEY`；不是正式发布，开发版本不得提交审核。
