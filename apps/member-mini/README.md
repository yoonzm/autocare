# 会员端小程序

原生微信小程序（WXML / WXSS / JS，无运行时依赖）。设计稿为画板 `Mb*`；接入范围、与设计稿的差异、TODO 与部署顺序见 [`docs/member-mini-integration.md`](../../docs/member-mini-integration.md)。

## 目录

| 路径 | 说明 |
| --- | --- |
| `pages/*` | 19 个页面。模板 `*.px.wxml` 的行内样式按设计稿像素书写，生成 `*.wxml` |
| `app.px.wxss` | 全局样式（设计稿像素），生成 `app.wxss` |
| `components/` | `navbar` 自定义导航栏、`icon`、`plate` 车牌、`async-view` 加载 / 空 / 错误 / 重试、`qr-code` |
| `custom-tab-bar/` | 底部三标签 |
| `utils/` | `api` 接口、`session` 会话、`page` 页面公共流程、`format` / `booking` / `view` 纯函数、`qrcode.js`（qrcode-generator，MIT） |
| `tools/px2rpx.py` | 设计稿像素 → rpx（750 / 390） |
| `test/` | Node 内置测试，不依赖第三方包 |

## 开发

```sh
npm test               # 单测 + 结构检查
npm run build:styles   # 修改 *.px.wxss / *.px.wxml 后重新生成 rpx 文件
```

- **只改 `*.px.*` 源文件**，不要直接改生成的 `.wxss` / `.wxml`；提交时一并提交生成结果（CI 会检查）。
- 所有会请求网络的页面用 `utils/page.js` 的 `load` + `<async-view>`（骨架顶部对齐、错误可重试、过期响应丢弃）；提交类按钮用 `.btn.busy` + `.spin`，尺寸不变、只显示转圈。规范见 `docs/frontend-guidelines.md`。
- 所有输入框必须有 placeholder（结构检查会验证）。
- 业务规则（价格、权限、预约容量、会员身份）只在云函数里；小程序不做校验替代。
- 密钥：`config.js` 里只有公开的 publishable key；微信 AppSecret 只在服务器环境变量。
- 在开发者工具中把 `project.config.json` 的 `appid` 换成真实 AppID，并在后台加入 request 合法域名。

## 临时测试发布

Actions → **Member Mini Program Publish** 可把本小程序上传 / 预览到 my-baas-helper 日志监控小程序（`wxdba60af414abc8db`）做真机测试（仅手动触发，配置与风险说明见 `docs/member-mini-integration.md`「临时测试发布」）。本地：`npm run package -- --appid <AppID> --out <目录>` 查看将被上传的文件。**上传的开发版本不要提交审核。**
