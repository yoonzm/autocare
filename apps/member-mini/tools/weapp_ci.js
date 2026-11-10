#!/usr/bin/env node
// 微信小程序自动化发布（miniprogram-ci）。
//   node tools/weapp_ci.js upload|preview        上传开发版 / 生成预览二维码，需要上传密钥
// （miniprogram-ci 连编译都要用密钥向微信换项目属性，所以没有离线的“只编译”模式；编译错误会在 upload/preview 时报出。）
// 环境变量：WEAPP_APPID（必填）、WEAPP_PRIVATE_KEY（上传密钥内容，仅 upload/preview）、WEAPP_ROBOT（1~30，默认 30）、
//          WEAPP_VERSION、WEAPP_DESC、MINIPROGRAM_CI_PATH（miniprogram-ci 的安装位置，默认 require 解析）。
// 安全：密钥只写入临时文件（0600），用完即删，不打印、不进仓库；上传描述里固定带“临时测试，勿提审”。
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { build } = require('./package');

const root = path.join(__dirname, '..');
const mode = process.argv[2];
const MARK = '【临时测试·勿提交审核】';

function env(name, required) {
  const value = (process.env[name] || '').trim();
  if (required && !value) throw new Error(`缺少环境变量 ${name}`);
  return value;
}

function robotOf(value) {
  const n = Number(value || 30);
  // 1 号机器人是 member-client 现有流水线默认使用的，避免互相覆盖开发版本
  if (!Number.isInteger(n) || n < 1 || n > 30) throw new Error('WEAPP_ROBOT 必须是 1~30 的整数');
  return n;
}

// 版本号：未指定时用 0.0.<时间戳到分钟>，保证递增且不占用 member-client 的正式版本号区间（3.x）
function versionOf(value, now = new Date()) {
  if (value) {
    if (!/^[0-9]+(\.[0-9]+){1,2}$/.test(value)) throw new Error('WEAPP_VERSION 格式应为 1.2.3');
    return value;
  }
  const p = (n, w = 2) => String(n).padStart(w, '0');
  return `0.0.${now.getUTCFullYear() % 100}${p(now.getUTCMonth() + 1)}${p(now.getUTCDate())}${p(now.getUTCHours())}${p(now.getUTCMinutes())}`;
}

function descOf(value) {
  const text = (value || '汽美管家会员端').replace(/\s+/g, ' ').trim();
  return (MARK + text).slice(0, 200);
}

const SETTING = { es6: true, minifyJS: true, minifyWXML: true, minifyWXSS: true, minify: true, autoPrefixWXSS: true };

// 把结果写进 GitHub Actions 的运行摘要（不含密钥）
function summary(lines) {
  const file = process.env.GITHUB_STEP_SUMMARY;
  if (file) fs.appendFileSync(file, lines.join('\n') + '\n');
}

async function main() {
  const appid = env('WEAPP_APPID', true);
  const out = path.join(root, 'dist');
  const { files, bytes } = build({ appid, out });
  console.log(`整理完成：${files.length} 个文件，${(bytes / 1024).toFixed(0)} KB`);

  const ci = require(env('MINIPROGRAM_CI_PATH') || 'miniprogram-ci');
  let keyPath = '';
  let keyDir = '';
  // miniprogram-ci 失败时可能直接抛出未捕获异常结束进程，所以用 exit 钩子保证临时密钥文件一定被删除
  const wipe = () => keyDir && fs.rmSync(keyDir, { recursive: true, force: true });
  process.on('exit', wipe);
  for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => process.exit(130));
  try {
    if (mode === 'upload' || mode === 'preview') {
      const key = env('WEAPP_PRIVATE_KEY', true);
      if (!/-----BEGIN RSA PRIVATE KEY-----/.test(key)) throw new Error('WEAPP_PRIVATE_KEY 不是有效的上传密钥（应以 -----BEGIN RSA PRIVATE KEY----- 开头）');
      keyDir = fs.mkdtempSync(path.join(os.tmpdir(), 'weapp-key-'));
      keyPath = path.join(keyDir, 'upload.key');
      fs.writeFileSync(keyPath, key.endsWith('\n') ? key : key + '\n', { mode: 0o600 });
    } else {
      throw new Error('用法：weapp_ci.js upload|preview');
    }

    const project = new ci.Project({ appid, type: 'miniProgram', projectPath: out, privateKeyPath: keyPath, ignores: ['node_modules/**/*'] });
    const robot = robotOf(env('WEAPP_ROBOT'));
    const common = { project, setting: SETTING, robot, onProgressUpdate: (m) => typeof m === 'string' && console.log(m) };

    if (mode === 'upload') {
      const version = versionOf(env('WEAPP_VERSION'));
      const desc = descOf(env('WEAPP_DESC'));
      console.log(`上传开发版：appid=${appid} robot=${robot} version=${version}`);
      const result = await ci.upload({ ...common, version, desc });
      console.log(JSON.stringify({ version, robot, size: result.subPackageInfo, plugins: result.pluginInfo }, null, 2));
      summary([
        '### 会员端小程序已上传（临时测试）',
        `- AppID：\`${appid}\`　机器人：${robot}　版本：\`${version}\``,
        `- 提交：\`${(process.env.GITHUB_SHA || '').slice(0, 7)}\``,
        '- 到微信公众平台 → 版本管理 → 开发版本，可「选为体验版」测试；**不要提交审核 / 发布**。',
      ]);
    } else {
      const qr = path.join(root, 'preview_qrcode.jpg');
      await ci.preview({ ...common, desc: descOf(env('WEAPP_DESC')), qrcodeFormat: 'image', qrcodeOutputDest: qr, pagePath: 'pages/auth/auth' });
      console.log('预览二维码已生成：' + qr);
      summary(['### 预览二维码已生成', '- 在本次运行的 Artifacts 下载 `member-mini-preview-qrcode`，用开发者 / 体验者微信扫码（25 分钟内有效）。']);
    }
  } finally {
    wipe();
  }
}

module.exports = { robotOf, versionOf, descOf, MARK };

if (require.main === module) {
  // miniprogram-ci 的部分错误是异步抛出的，统一成一行中文提示并以非 0 退出
  const die = (e) => {
    console.error('失败：' + (e && e.message ? String(e.message).split('\n')[0] : e));
    process.exit(1);
  };
  process.on('uncaughtException', die);
  process.on('unhandledRejection', die);
  main().catch((e) => {
    // 错误信息不含密钥；miniprogram-ci 的堆栈只在需要排查时由日志查看
    console.error('失败：' + (e && e.message ? e.message : e));
    process.exit(1);
  });
}
