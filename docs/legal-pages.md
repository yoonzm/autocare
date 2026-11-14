# 用户协议与隐私政策（H5）

## 形态

- 商户端的《用户协议》《隐私政策》是后端提供的 H5 页面，App 内（登录页、注册页、关于页）点开后用网页加载，不再把正文写死在 App 里。
- 地址（同一个 `merchant-v1` 函数，公开只读 GET，不需要登录）：
  - `https://autocare.mymember.ltd/functions/v1/merchant-v1/legal/terms`
  - `https://autocare.mymember.ltd/functions/v1/merchant-v1/legal/privacy`
- 应用商店填写隐私政策网址时可直接使用上面的地址（App 内加载时带客户端公开密钥 `apikey` 请求头；如网关要求且商店审核需要不带任何参数就能打开，需要在网关为这两条路径放行）。

## 如何更新

1. 修改 `supabase/functions/merchant-v1/legal_content.ts` 的正文，同时更新 `LEGAL_UPDATED`。
2. 合入 `main`，`supabase-prod.yml` 自动部署；App 下次打开页面即看到新文案（页面带 5 分钟缓存）。
3. 涉及用户权益的重大变化，需要同时在 App 内通知用户。

## 配置

- `LEGAL_OPERATOR_NAME`：运营主体全称（服务器 `.env.support`）。写入协议和隐私政策开头的“（以下简称“我们”）”前；未配置时显示“汽美管家运营方”。
- `MERCHANT_SUPPORT_PHONE`：客服电话，同时用于账号页客服热线。未配置时只写“通过 App 内“关于汽美管家”“帮助与反馈”联系我们”。

## 正文依据

文案按商户端当前真实功能撰写：手机号验证码 / 密码登录；会员、车辆、订单、库存、开支、员工数据；相机与相册（仅车牌扫描、门店 / 施工 / 凭证 / 反馈图片）；短信（助通）；车牌识别（阿里云百炼，仅发送车牌照片）；账号自助注销立即生效、业务数据保留；限时免费，不收费、不代收货款。功能范围变化（例如重新开放行驶证扫描、线上支付、定位）时要同步改正文。

## 实现说明

- `legal.ts` 把正文渲染成自带样式的单页 HTML（浅色 / 深色自适应），返回 `text/html`，并带 `Content-Security-Policy`（禁止脚本和外部资源）与 5 分钟缓存。
- App 端 `lib/pages/account/legal_web_page.dart` 用 `webview_flutter` 加载，关闭 JavaScript，只允许加载这一个地址；失败显示统一错误视图和重试。
- 注意：部分网关 / 托管环境会把函数返回的 HTML 改成 `text/plain`。首次部署后请在真机打开确认显示为排版页面而不是源码。
- 本文只是按产品功能整理的文本，不构成法律意见；上线前需法务审核。
