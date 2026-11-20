# 发布约定

## App Store 首版资料（2026-11-20）

- 商店名称与 iOS 显示名称：我的汽美管家；Bundle ID 保持 `com.yoonzm.autocare.merchant`。
- 仅声明 iPhone 设备支持，不提供原生 iPad 版本；iPad 上的 iPhone 兼容运行不由这一设置禁止。
- APP 备案号：`陕ICP备2022007344号-6A`（用户提供，提审时需核对 App Store Connect 与备案信息一致）。
- 用户已确认上一版 TestFlight 真机验收完成；本次名称与设备范围调整需重新打包，不能用旧构建代表新配置。
- 审核使用用户名/密码登录；审核凭据仅填写 App Store Connect 的审核专用字段，不保存在仓库。
- 运营主体：西安追慕科技有限公司（Xi'an Zhuimu Technology Co., Ltd）；2026-11-20 从用户已登录的 App Store Connect 商务页核对。
- 审核联系信息可参照同账号“我的会员管家”的审核专用字段；用户已批准公开客服信息与技术支持页复用“我的会员管家”的配置。
- 公开客服电话：`18706849256`；客服邮箱：`wodehuiyuanguanjia@163.com`（来源：[我的会员管家公开联系方式](https://mymember.ltd/member/assets?name=privacy-policy.html)）。公开客服邮箱与审核联系邮箱分别维护。
- 技术支持网址：`https://member.mymember.ltd/member-sit/`（2026-11-20 匿名 GET 验证为 HTTP 200）；按用户要求，商户 App 保留原微信客服入口 `https://work.weixin.qq.com/kfid/kfc6eaf7469b168651b`，不随支持页配置更换。
- 上述电话和邮箱已纳入上架资料；本次未更改生产服务器环境变量。复用客服配置不替换商户端专属隐私政策，隐私政策仍需准确反映本 App 的实际数据处理。
- 隐私政策与用户协议匿名访问已于 2026-11-20 修复并验证（HTTP 200 / HTML）；维护和回滚见 [协议页面说明](legal-pages.md)。
- 待完成：真实 iPhone 截图、App Privacy 申报及归档隐私清单核验。账号注销说明必须与实际数据处理一致，不能将停用账号表述为删除全部数据。
- 中国大陆分发除 APP 备案外，当前 App Store Connect 还要求填写 AIGC 与安全评估相关声明。仅车牌识别不等于面向用户提供内容生成服务，但须按实际功能和第三方服务用途核对问卷，不自动复制其他 App 的答案；只有适用受监管功能时才提供相应备案及报告。参见 [Apple 中国大陆合规说明](https://developer.apple.com/help/app-store-connect/manage-compliance-information/view-china-mainland-compliance-information)。

### 简体中文商店文案草案

| 字段 | 内容 |
| --- | --- |
| 名称 | 我的汽美管家 |
| 副标题 | 汽车美容门店的会员与经营管理助手 |
| 主分类 | 商务 |
| 次分类 | 效率（可选） |
| 版权 | 2026 西安追慕科技有限公司 |
| 技术支持网址 | https://member.mymember.ltd/member-sit/ |
| 关键词 | 汽车美容,洗车管理,门店管理,会员管理,预约开单,库存管理,员工管理 |
| 推广文本 | 从会员建档、预约排班到开单记账、库存与员工协作，我的汽美管家帮助汽车美容门店理清日常业务，让每一次服务有记录、每一笔经营有依据。 |
| 价格 | 免费（当前版本无软件订阅或内购入口） |
| 首版说明 | 首次发布，提供会员与车辆档案、预约管理、开单记账、储值与次卡记录、库存管理、员工协作及经营统计。 |

描述：

我的汽美管家是一款面向汽车美容、洗护、贴膜和养护门店的经营管理工具，让老板与员工在一部手机上处理日常业务。

【会员与车辆】管理会员资料、车辆档案、储值与次卡记录，查看服务及消费记录，方便持续服务客户。

【预约与开单】安排到店预约，选择服务项目、工位与技师，跟进挂单和施工任务，记录线下收款结果。

【库存与开支】管理商品、供应商和出入库单据，记录经营开支及凭证，掌握日常物料使用情况。

【员工协作】管理员工角色与权限，分配施工任务，记录工作进度，查看业绩与提成。

【经营概览】查看营业、订单和会员等经营数据，为日常管理提供依据。

当前版本免费提供门店管理功能。收银、会员充值与次卡销售用于记录门店线下业务，App 不代收代付，不提供线上充值或支付服务。

### 审核备注草案（凭据另填审核专用字段）

This app is a business management tool for car detailing and car-care shops. It is used by shop owners and authorized staff to manage customers, vehicles, appointments, service orders, inventory and work tasks.

To sign in, select the password-login option on the login screen, enter the phone-number username and password provided in the App Review Information sign-in fields, accept the user agreement and privacy policy, and sign in. Use password login rather than SMS-code login.

The current version is free and has no software subscription or in-app purchase flow. Checkout, stored-value top-ups and service packages are bookkeeping records for physical services paid for outside the app. The app does not process payments or transfer funds.

Camera and photo-library access are used for vehicle plate recognition and uploading business photos or receipts. The app does not require external hardware for its core workflows.

提交前确认审核账号可正常使用且有可供审核的门店业务记录；不要将上述说明视为账号已登录核验。

### iPhone 截图文案

使用实际运行截图，避开真实客户的手机号、车牌和照片；不使用虚构功能画面。图片尺寸以 App Store Connect 当前 iPhone 槽位要求为准。

1. 门店经营，一屏掌握 —— 首页经营概览。
2. 会员车辆，有序管理 —— 会员列表与详情。
3. 预约到店，从容安排 —— 预约与工位视图。
4. 服务开单，记录清楚 —— 开单与订单页面。
5. 库存进出，心中有数 —— 商品与库存页面。
6. 员工协作，进度可查 —— 施工任务页面。

### App Privacy 填写草案

以下是根据当前功能整理的待核验清单，不是已提交的声明，也不是第三方 SDK 或服务商数据实践的完整审计。不能填写“不收集数据”。

| 数据类别 | 当前功能中的例子 | 用途与关联草案 |
| --- | --- | --- |
| 联系信息 | 姓名、手机号、资料邮箱、门店地址 | App 功能；与账号或门店关联 |
| 标识符 | 用户账号 ID；设备标识需核对实际字段 | App 功能与账号安全；与账号关联 |
| 用户内容 | 头像、施工照片、凭证、反馈内容及其他录入资料 | App 功能、客户支持；与账号或门店关联 |
| 购买记录及其他财务信息 | 订单、充值、次卡、经营开支与余额记录 | App 功能；按实际字段核对苹果数据分类，不因仅线下收款就一律排除财务信息 |
| 使用与诊断数据 | 登录及操作日志、服务端错误记录 | 安全和故障处理；按实际上传及留存情况申报 |
| 其他数据 | 车辆档案、车牌等未归入前述分类的记录 | App 功能；与账号或门店关联 |

当前功能未见广告追踪用途；是否选择“不用于追踪”仍需结合全部 SDK 及短信、识别等服务商实际用途确认。相机权限本身不等于收集数据，但图片上传并存储在服务器上属于需要核对申报的数据处理。

参考：[商店字段](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/)、[截图规格](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications)、[隐私申报](https://developer.apple.com/app-store/app-privacy-details/)。

## 自动发布流程

- `main` 合入后，按受影响目录执行各端 CI / 内测发布；各端独立版本。Supabase 正式后端按下述流程自动部署，App 签名和发布约束保持原有配置。
- 商户端使用 `.github/workflows/merchant-internal.yml` 执行 Flutter 检查和内测打包；后台端仍由独立工作流处理。后端由 `.github/workflows/supabase-prod.yml` 独立检查和部署，触发条件见下述正式后端流程，不触发商户端打包。
- iOS 标识为 `com.yoonzm.autocare.merchant`。先在 Apple Developer / App Store Connect 创建对应 App ID、App 和 App Store 描述文件；再在新 GitHub 仓库配置 `BUILD_CERTIFICATE_BASE64`、`P12_PASSWORD`、`BUILD_PROVISION_PROFILE_BASE64`、`ASC_KEY_ID`、`ASC_ISSUER_ID`、`ASC_PRIVATE_KEY`。不要复制 LanScope 的描述文件。配置完成后在仓库 Variables 中设置 `ENABLE_MERCHANT_TESTFLIGHT=true`，此前 iOS 发布任务会跳过。
- 商户端检查在任意分支推送 `apps/merchant/` 变更后运行；仅 `main` 与当前 `feat/merchant-supabase-v1` 分支同时执行内测打包。V1 验证结束后应移除特性分支上传条件。TestFlight 上传仍受 `ENABLE_MERCHANT_TESTFLIGHT` 和 `merchant-testflight` 环境签名配置约束。
- **MVP 阶段只上线 iOS，不上线 Android。** Android 构建不再随推送运行，需要时在 Actions 里手动运行 `Merchant Build` 并勾选 `build_android`。Android 当前 APK 使用 Flutter 默认调试签名，不可用于正式商店发布；将来上 Android 时需专用 keystore、上传渠道及审批流程。
- 新增端时增加各自 CI / 发布工作流，保持版本号与发布状态独立；共享包变化需触发所有依赖它的端。

## 私有化正式后端

- `.github/workflows/supabase-prod.yml` 在 `main` 的 `supabase/**` 或本工作流变更时自动执行，也支持在 `main` 手动 Run workflow。类型检查、Deno 测试及部署包安全检查通过后，发布到 `https://autocare.mymember.ltd`。后续仅维护生产环境。
- GitHub Environment `supabase-prod` 仅允许 `main`，配置 `SUPABASE_PROD_SSH_KEY` 和 `SUPABASE_PROD_KNOWN_HOSTS` 两个 Secret。部署专用 SSH key 只允许调用服务器 root 所有的 `/usr/local/lib/autocare-deploy/production.py`，禁用任意命令、终端和端口转发。数据库和服务端密钥留在服务器，不上传到 Actions。
- 部署包由 `supabase/deploy/package.py` 生成，统一换行为 LF，保证 Windows 手动部署与 Linux Actions 的迁移校验值一致。服务器接收包前检查路径、文件类型、重复项和大小限制。
- 部署先运行 `/usr/local/sbin/supabase-backup`，按版本逐条事务执行未应用 SQL，同时登记 `supabase_migrations.schema_migrations` 和 `autocare_deploy.migrations`。已应用迁移内容变化、遗漏历史或插入旧版本会拒绝发布。后续改表必须新增 SQL，不能修改旧文件。
- 同时更新 `merchant-v1`、`admin-v1` 与 `member-v1` 后重建 functions 容器，并经公网 HTTPS 验证公开登录入口、未登录业务鉴权、短信输入校验和会员端未登录守卫（不带令牌必须 401，不会调用微信或短信）。接口检查失败时同时恢复上一份函数代码；已成功提交的数据库迁移保留，不自动回滚数据，需评估后使用新迁移修复或从备份恢复。发布版本记录在服务器 `/opt/supabase/.autocare-release.json`；`revision` 为来源 Git 基线，`source_sha256` 标识打包的精确后端内容（包含尚未提交的工作区变更），服务器在部署前重新校验内容摘要。
- 初次部署或更新 `supabase/deploy/production.py` 时，需要管理员通过现有 SSH 将该文件安装到上述 root 所有的入口，再发布。此文件是服务器受信任的执行程序，不由上传包替换。手动部署和 Actions 使用同一个包格式、同一个入口。
- 短信一期使用助通，凭据和按用途配置的模板放服务器 `.env.sms`，由 Compose 注入；所有环境均使用真实短信，移除短信 mock 配置，详见 `sms.md`。车牌识别使用服务器 `.env.recognition` 中的百炼配置，由 Compose 独立注入；随机 mock 已移除，详见 `plate-recognition.md`。更新服务器部署入口后再部署新增迁移和函数，渠道配置缺失时明确返回未启用错误。健康检查只用无效号码探测真实短信入口，不会发送付费短信。私有化发布仅安装结构和函数。

### 备份设施初始化与维护

备份设施的维护源码位于 `supabase/deploy/backup/`，包含 `supabase-backup`、`supabase-backup.service`、`supabase-backup.timer` 和安装脚本 `install.sh`。前三个文件于 2026-11-17 从生产服务器核对收录，保留原有备份范围与清理规则。后续从仓库修改、验证并安装，避免只在服务器上修改而丢失版本记录；凭据和备份数据不进入仓库。

新生产环境先完成 Supabase Docker Compose 初始化，具备 `/opt/supabase/docker-compose.yml`、`/opt/supabase/.env`、本地 Storage 目录 `/opt/supabase/volumes/storage` 和 Docker 卷 `supabase_db-config`。备份脚本使用 `supabase/postgres:17.6.1.136` 容器打包配置卷；目录、卷名、镜像或 Storage 后端发生变化时，应同步调整并验证仓库中的脚本。此安装步骤只配置备份设施，不负责初始化 Supabase、SSH 部署入口或渠道密钥。

将仓库放到目标服务器后，在仓库根目录执行（首次安装和更新使用同一命令）：

```bash
sudo bash supabase/deploy/backup/install.sh
```

安装器将脚本安装到 `/usr/local/sbin/supabase-backup`，属主 `root:root`、权限 `700`；创建权限 `700` 的 `/var/backups/supabase`，安装两个 systemd 单元并启用定时器。每天 03:30 按**服务器本地时区**执行，当前生产环境为 `Asia/Shanghai`；`Persistent=true` 会在重新启用时补跑错过的任务。安装不等于已经完成首份备份，需继续验收：

```bash
sudo systemctl start supabase-backup.service
sudo systemctl status supabase-backup.service --no-pager
sudo systemctl list-timers supabase-backup.timer --no-pager
sudo ls -lh /var/backups/supabase
```

检查新生成目录的 `COMPLETE` 标记，并在 root 会话中进入该目录执行 `sha256sum -c SHA256SUMS`。备份内容如下：

| 文件 | 内容 |
| --- | --- |
| `postgres.dump` | `postgres` 数据库的自定义格式逻辑备份，含数据、结构、数据库函数、RLS 等 |
| `globals.sql` | PostgreSQL 角色等全局对象 |
| `config.tar.gz` | `/opt/supabase` 中的配置与代码，排除数据库原始数据目录、Storage 目录及指定日志 |
| `storage.tar.gz` | 本地 Storage 的实际文件，包括公开桶和私有桶中的图片 |
| `db-config.tar.gz` | `supabase_db-config` 配置卷 |

部署前备份与每日定时备份共用这个脚本。清理在备份成功后执行，按每个文件的 `-mtime +7` 判断，即修改时间满 8 个整天后可被清理；不限制份数或总容量，也没有自动异地上传。数据库导出与文件打包顺序执行，不是数据库与 Storage 的同一时刻快照。现有脚本遇到备份锁占用会返回 `0`，所以不能只凭退出成功判断已产生新备份，仍需核对本次目录和 `COMPLETE`。

备份设施与 `production.py` 一样由管理员安装，普通后端发布包不会更新它们。修改这些文件后需重新运行安装器；CI 会检查 Bash 语法，但不执行真实备份或安装服务。恢复数据应先在隔离恢复库验证；发布失败时仍仅尝试恢复云函数代码，不自动回灌数据库备份。

## 商户端后端配置

- App 默认地址和客户端公开密钥指向私有化正式环境。自动打包沿用默认值，不需要额外配置。
- 账号页设备列表、单设备撤销及注销检查需要迁移 `202611120001_account_tools.sql` 与新版 `merchant-v1`，再发布新版 App。客服电话通过服务器 `.env.support` 的 `MERCHANT_SUPPORT_PHONE` 注入；缺少号码时明确提示未配置。需先安装新版 `supabase/deploy/production.py`，使 Compose 加载 `.env.support`（创建时默认为空，不配置示例号码）。

## 会员端小程序

- 源码 `apps/member-mini`，用微信开发者工具上传体验版 / 提审，版本与其他端独立。`.github/workflows/member-mini.yml` 在 `apps/member-mini/**` 变更时运行 Node 测试与样式生成检查，不自动上传（上传需要小程序密钥，不放进 Actions）。
- 后端：迁移 `202611100003_member_portal.sql` 与独立的 `member-v1` 云函数随 `supabase-prod.yml` 自动部署；微信凭证 `/opt/supabase/.env.wechat` 由管理员配置（样例 `supabase/deploy/wechat.env.example`），更新后的 `production.py` 需管理员重新安装到服务器入口。详见 `docs/member-mini-integration.md`。
- 临时测试：`.github/workflows/member-mini-publish.yml`（手动）可把会员端上传到 my-baas-helper 日志监控小程序（`wxdba60af414abc8db`）的开发版本或生成预览二维码，需要环境密钥 `MEMBER_MINI_UPLOAD_KEY`；不是正式发布，开发版本不得提交审核。

## 用户协议与隐私政策（H5）

- 页面由生产 Caddy 静态托管：隐私政策 `https://autocare.mymember.ltd/legal/privacy.html`，用户协议 `https://autocare.mymember.ltd/legal/terms.html`。正文在 `supabase/static/legal/`，随 `supabase-prod.yml` 部署。旧地址不再支持；本次 App 链接切换需要新版，后续正文更新无需发版。详见 `docs/legal-pages.md`。
- 服务器 `.env.support`（已注入函数容器）可增加 `LEGAL_OPERATOR_NAME`（运营主体全称，写入协议开头）；客服电话沿用 `MERCHANT_SUPPORT_PHONE`。两者缺省时页面不写占位文字，只指引到 App 内的客服入口。
- 上线前请法务审核正文，并在应用商店资料里填写这两个页面的网址。
