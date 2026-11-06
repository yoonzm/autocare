# 车牌识别

商户端“扫码找会员 → 车牌”和“扫描建档 → 车牌”共用真实识别链路。参照 `my-baas/common-cloudcode/ocr/ai.js` 的百炼视觉识别实现，使用 AutoCare 自己的 Supabase 登录态、门店和会员资料。

## 界面与业务边界

- 保留相机页、分段控件、相册、快门、结果弹层及导航。`design_to_flutter.py` 和 `pages/gen/` 均不修改；车牌建档结果通过非生成的 `plate_scan_result_live_sheet.dart` 绑定原设计。
- 拍照和相册都传实际图片；设备端解码处理方向、按比例限制最长边 1280，转为 PNG。源文件限制 30MB，发送图片限制 5MB；不能读取或解码时明确报错。
- 云函数识别车牌、中文品牌车型及车身颜色，再精确查询当前门店的车辆。已有会员显示登记资料，进入开单时优先使用本次扫描的车辆；其他门店同车牌不匹配。
- 未匹配时进入已有的“未找到会员”弹层。“创建会员”带入完整车牌、新能源类型、AI 车型及车身颜色候选值，颜色名称及选中色块同步，用户可修改并通过原保存接口确认；返回已打开的办卡表单时保留客户资料。无法确认车身颜色时不覆盖已有选择，新表单沿用原默认值。“散客结账”带入车牌。识别本身不会建档或覆盖已有车辆资料。
- 车身颜色 `vehicle_color` 与车牌底色 `plate_color` 分开，支持页面现有的黑色、白色、银色、灰色、红色、蓝色、棕色、香槟金、绿色、橙色、紫色。车身不可见、无法确定主色或不在选项范围时返回空字符串，不猜测颜色。
- 牌色来自模型结果，未知显示“—”，不通过车牌长度推断蓝牌或黄牌。现有车辆数据模型仍按 7 / 8 位区分燃油 / 新能源；首版支持普通大陆民用号牌，不支持使领馆、警用、挂车、港澳等特殊格式。
- 未登录引导登录，重复点击不重复请求；失败保留已选图片并恢复取景，可重新拍摄或选择照片。离开页面后丢弃迟到响应。行驶证 OCR 和会员二维码仍为 TODO，点击明确提示未接通，不展示示例成功结果。

## 接口

`POST /functions/v1/merchant-v1`，使用现有用户 JWT：

```json
{
  "kind": "members",
  "action": "recognize_plate",
  "image_base64": "图片的纯 Base64 编码",
  "mime_type": "image/png"
}
```

后端也接受真实 JPEG（`image/jpeg`）。拒绝空图、超限图片、MIME 与文件头不一致的图片。不接受客户端指定门店、模型或远程图片 URL。照片经 Base64 Data URL 发送给百炼，不存 Supabase Storage、不写数据库、不写日志。

```json
{
  "matched": false,
  "plate": "粤BD12345",
  "vehicle_model": "比亚迪 秦PLUS",
  "vehicle_color": "白色",
  "plate_color": "green"
}
```

匹配成功另返回现有字段 `member`、`package_summary`、`last_visit_text`。会员必须属于当前门店且未删除；次卡排除退款及过期记录，最近服务只取已完成订单。查询失败返回错误，不能当作未找到会员。

识别标准化参照 my-baas：全角转半角、移除分隔点、转大写，序号中的 I / O 转 1 / 0，保留 L。结果仍须通过车牌格式校验。未识别到、格式不合法或有多个无法确定目标的车牌返回 422；需重新拍摄，不产生虚构车牌。多车牌判断属于模型输出，仍需用实际样本验证效果。

## 配置与部署

配置示例在 `supabase/deploy/recognition.env.example`：

| 配置 | 用途 |
| --- | --- |
| `BAILIAN_API_KEY` | 必填，目标环境独立配置，绝不下发客户端 |
| `AI_LICENSE_PLATE_MODEL` | 默认 `qwen3.7-flash`，须在目标百炼账号确认可用性 |
| `BAILIAN_BASE_URL` | 默认 `https://dashscope.aliyuncs.com/compatible-mode/v1`，与 Key 所属地域匹配 |

Cloud 项目通过 Supabase Secrets 配置上述变量。私有化实例在 `/opt/supabase/.env.recognition` 配置，权限 `600`；生产部署脚本会创建空配置并注入 functions 容器，不会覆盖已配置的凭据。更新的 `supabase/deploy/production.py` 须先由管理员安装到服务器受信任部署入口，详见 `release.md`。

先应用 `202611060002_plate_recognition.sql`，再部署 `merchant-v1` 和新版 App。新迁移只增加识别限流表及仅 `service_role` 可执行的原子 RPC，不修改会员和车辆表。每店每自然分钟最多 10 次、北京时间每天最多 500 次，多个函数实例共享计数；无效图片、服务未配置不占额度，上游调用失败仍计一次。额度为调用次数保护，不是费用结算。

模型请求 12 秒超时，App 沿用普通请求 15 秒超时，不自动重试付费识别。缺少 Key 返回 503；限流返回 429；模型及会员查询错误返回对应错误。成功日志只包含门店 ID、模型、耗时、Token 用量。随机 mock 逻辑及 `ALLOW_MOCK_RECOGNITION` 已移除。

## 验证

- `deno task check` 与 `deno test`：图片、标准化、模型请求及异常、本店精确匹配、软删除、查询失败和限流失败关闭。
- `node supabase/tests/plate_recognition.mjs <pglite/dist/index.js>`：独立 Postgres 的门店隔离、分钟 / 日额度、跨日重置、RLS 及 RPC 权限；已加入两个后端 CI。
- `flutter analyze --no-pub` 与 `flutter test --no-pub`：拍照 / 相册、结果、建档预填、新能源完整车牌、图片处理、重复点击、未登录、迟到响应及现有流程回归。
- 发布验收另需真实 Android / iOS 相机与相册测试，以及蓝牌、新能源、黄牌、模糊、无车牌、多车牌样本联调。自动测试使用隔离数据库和服务桩，不代表已对真实百炼账号或线上环境完成验收。
