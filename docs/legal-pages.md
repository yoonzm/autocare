# 用户协议与隐私政策（静态 HTML）

## 地址与维护位置

- 隐私政策：https://autocare.mymember.ltd/legal/privacy.html
- 用户协议：https://autocare.mymember.ltd/legal/terms.html
- 正文分别维护在 `supabase/static/legal/privacy.html`、`supabase/static/legal/terms.html`，修改正文时同步更新页面中的更新日期。
- 生产 Caddy 直接提供静态文件，不经过云函数，不需要登录、apikey 或自定义请求头。旧云函数地址已移除，不兼容或重定向。
- App 的登录页、注册页、关于页继续通过 `lib/pages/account/legal_web_page.dart` 展示网页，保留原有布局、加载、错误和重试交互。App 使用 `?theme=light` 或 `?theme=dark` 同步当前主题；外部无参数访问跟随系统主题。
- 页面仅包含一段在渲染前设置主题的脚本，WebView 开启 JavaScript，CSP 只允许该脚本的 SHA-256 哈希，不允许其他脚本或外部资源。修改脚本必须同步更新 `supabase/deploy/legal.caddy` 的哈希并安装生产路由配置；部署测试校验二者一致。
- 运营主体西安追慕科技有限公司、客服电话 18706849256 直接维护在 HTML 中，不再读取环境变量；App 客服热线仍使用原有独立配置。

## 更新与部署

1. 修改 HTML 正文和更新日期，保留样式，确保符合实际数据处理。
2. 提交并推送到 `main` 后，`supabase-prod.yml` 将两个文件随部署包发布到 `/srv/autocare/legal/`，页面缓存为 5 分钟。部署失败时恢复上一次函数和静态文件。
3. 本次 App 链接切换需要构建新版；后续正文更新无需重新发布 App。App Store Connect 隐私政策字段应使用上方新地址。
4. 涉及用户权益的重大修改须另行落实 App 内通知及同意流程。

## 生产配置

- `/etc/caddy/Caddyfile` 的站点块中导入 `/etc/caddy/autocare-legal.caddy`，位于 API 和后台访问规则之前；模板维护在 `supabase/deploy/legal.caddy`。
- 仅公开两个文件的 GET / HEAD，其他 `/legal/*` 路径或方法返回 404。返回 HTML 类型、禁止 MIME 嗅探及限制脚本和外部资源的 CSP。
- 初始化或修改路由时，管理员将 `supabase/deploy/install_legal.py`、`legal.caddy` 和 `supabase/static/legal/` 按仓库目录结构复制到服务器，执行 `sudo python3 <仓库根目录>/supabase/deploy/install_legal.py`。脚本先备份，再验证配置并 reload Caddy；失败自动恢复。
- 受信部署入口 `/usr/local/lib/autocare-deploy/production.py` 及其依赖 `legal_checks.py` 必须由管理员安装为 root 所有，普通部署包不能替换这些脚本。
- 2026-11-20 已撤销此前两条云函数 GET 的运行时 JWT 例外，恢复原始鉴权；协议页面不再依赖 Edge Runtime 配置。
- 本次安装备份：`/var/lib/autocare-deploy/static-legal-20261120T091307531778Z`，其中 `0` 为原 Caddyfile。恢复它并 reload Caddy 可撤销静态路由，但新链接将不可访问；正常正文回滚应恢复静态文件并保留路由。

## 验收

```bash
python3 supabase/deploy/legal_checks.py --expected-directory supabase/static/legal
```

检查匿名访问、HTML 正文与源文件一致、安全响应头、HEAD、禁止的路径/方法，以及商户、运营后台、会员接口仍要求鉴权。部署入口和 Actions 均执行检查。App 测试覆盖新链接、无鉴权请求头和错误重试。

## 正文依据

正文沿用当前真实功能：手机号验证码 / 密码登录；会员、车辆、订单、库存、开支、员工数据；相机与相册；短信（助通）；车牌识别（阿里云百炼）；账号自助注销立即生效、业务数据保留；限时免费，不收费、不代收货款。功能或实际数据处理变化时须同步更新正文。
