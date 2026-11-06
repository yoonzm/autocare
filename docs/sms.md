# 短信验证码

一期使用助通（`zhutong`），参考 `my-baas/common-cloudcode/sms/zhutong.js` 的 v2 模板接口。现有 App 页面、导航和输入布局保持不变；发送成功统一提示查收短信，任何环境都不向 App 返回验证码。

## 渠道和配置

业务入口在 `merchant-v1/auth.ts`，验证码存取在 `otp.ts`，发送编排在 `sms.ts`。渠道统一实现 `sms_types.ts` 的 `SmsProvider`，一期适配器为 `sms_zhutong.ts`。后续新增渠道只需实现适配器并登记到 `sms.ts`，不需要改注册、登录和数据库校验逻辑。

助通使用固定 HTTPS 地址 `/v2/sendSmsTp`，签名为 `md5(md5(password) + 秒级时间戳)`，模板参数仅由服务端生成的 `{code}` 构成。只把 HTTP 成功且业务 `code=200` 当作已受理；超时、非 JSON 和渠道拒绝都返回明确失败，且不自动重发。受理成功不代表运营商已经送达，本期未接状态回执。

配置样例为 `supabase/deploy/sms.env.example`。用户已指定复用 my-baas 的助通账号、签名及模板：

| 用途 | purpose | 模板变量 | 当前模板 |
| --- | --- | --- | --- |
| 注册 | `register` | `ZHUTONG_TEMPLATE_REGISTER` | 485812 |
| 验证码登录 | `login` | `ZHUTONG_TEMPLATE_LOGIN` | 485814 |
| 找回密码 | `reset_password` | `ZHUTONG_TEMPLATE_RESET_PASSWORD` | 498536（暂用绑定模板） |
| 验证原手机号 | `change_phone_old` | `ZHUTONG_TEMPLATE_VERIFY` | 498536 |
| 验证新手机号 | `change_phone_new` | `ZHUTONG_TEMPLATE_BIND_PHONE` | 498536 |
| 申请注销 | `delete_account` | `ZHUTONG_TEMPLATE_DELETE_ACCOUNT` | 498536（暂用绑定模板） |

每个用途可独立替换模板。账号、密码只放服务器 `/opt/supabase/.env.sms`，文件权限 600，不进入代码、App 或 GitHub Actions。部署程序通过 `env_file` 注入该文件；首次部署如文件不存在会创建空配置，不会使用占位账号发送。审核后由管理员从 my-baas 配置中安全写入实际账号和密码，不能把配置内容打印进终端日志。

所有环境通过 `SMS_PROVIDER=zhutong` 选择真实渠道；渠道配置缺失返回 501。短信 mock 的开关、旧接口和运行时分支均已移除。车牌识别使用独立的 `ALLOW_MOCK_RECOGNITION` 开关，正式部署仍将其设为 false。

## 接口和校验

App 调用 `send_code`，携带 `phone` 和 `purpose`。所有环境响应均为 `ok/retry_after/expires_in`，没有验证码；App 必须与本次后端更新配套升级。

- 注册、登录和找回密码可在未登录状态申请；登录、找回密码要求门店账号存在，注册和新手机号要求号码未被使用。
- 换号、注销的发送接口验证用户登录和门店归属；原手机号、注销验证码只能发到当前账号绑定号码。
- 保留既有手机号映射到 Auth 邮箱别名的方式，避免已有账号在引入真实短信后失去密码登录能力。短信通过应用渠道发送，不启用 GoTrue 原生手机号发送接口。
- 注册首屏 `check_code` 和找回密码首屏 `forgot_verify` 只做非消费校验；最终注册、验证码登录、重置密码、换号、注销会原子消费验证码。同一个验证码不能跨用途使用，也不能重复提交。
- 更换手机号时，原、新两个验证码全部正确才同时消费。数据库故障或渠道受理后写入失败不伪装发送成功，验证码保持不可用；业务执行失败后已消费的码不会恢复，需要重新获取。

## 数据库和限流

新增迁移 `202611060001_sms_channels.sql`，须先执行再部署函数和新版 App。旧未过期验证码保留为 `legacy/failed`，不能用于新流程，需要重新获取。迁移不改变现有账号、门店和业务数据。

验证码为随机 6 位数字、5 分钟有效，数据库仅存绑定手机号和用途的 HMAC-SHA256。HMAC 使用 `SMS_OTP_PEPPER`，未配置时使用运行时的 `JWT_SECRET`。更换该密钥会使尚未使用的验证码失效。

数据库原子预约发送，所有用途合并按手机号限制：60 秒一次、北京时间自然日最多 10 次；全环境默认每天最多 200 次，防止公开接口无界消耗短信余额。发送尝试计入额度，渠道超时也不退回额度，以免重复扣费。额度目前定义在迁移函数中，需要调整时新增迁移。验证码错误最多尝试 5 次，之后必须重新获取；客户端倒计时只负责反馈，限制以数据库为准。

新增 RPC 仅允许 `service_role` 执行，验证码表沿用 RLS，客户端不能读取、写入或直接校验验证码。

## 验证与上线

`sms.test.ts` 使用注入的 HTTP stub 检查助通签名、请求体、失败处理、渠道选择和真实响应不含验证码；不会访问助通接口。`supabase/tests/sms.mjs` 在独立本地 PGlite 中检查完整迁移、额度、用途、有效期、错误次数、单次消费、原新号码同时消费及权限。

```sh
cd supabase/functions/merchant-v1
deno task check
deno test
# 仓库根目录：
node supabase/tests/sms.mjs /path/to/@electric-sql/pglite/dist/index.js
```

App 回归覆盖登录、注册、找回密码、更换手机号和注销按钮，以及真实发送响应没有验证码时的提示和倒计时。生产部署健康检查使用无效手机号验证新接口，绝不向固定号码发送真实短信。现有短信配置必须在审核后写入服务器；真实通道收发联调需要用户明确指定测试手机号，属于另一步操作。
