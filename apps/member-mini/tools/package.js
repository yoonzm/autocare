#!/usr/bin/env node
// 把小程序整理成可上传的目录（默认 dist/）：只含运行需要的文件，appid 来自参数而不是仓库里的占位值。
//   node tools/package.js --appid wxa9586ff6437c2379 [--out dist]
// 排除：测试、工具、样式源文件（*.px.*，已生成 rpx 版本）、说明文档、npm 清单。
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const arg = (name, fallback) => {
  const i = process.argv.indexOf('--' + name);
  return i > 0 && process.argv[i + 1] ? process.argv[i + 1] : fallback;
};

const EXCLUDE_DIRS = new Set(['test', 'tools', 'styles', 'node_modules', 'dist', '.git']);
const EXCLUDE_FILES = [/\.px\.(wxss|wxml)$/, /\.md$/, /^package(-lock)?\.json$/];

function* walk(dir, rel = '') {
  for (const entry of fs.readdirSync(path.join(dir, rel), { withFileTypes: true })) {
    const next = path.join(rel, entry.name);
    if (entry.isDirectory()) {
      if (!EXCLUDE_DIRS.has(entry.name)) yield* walk(dir, next);
    } else if (!EXCLUDE_FILES.some((re) => re.test(entry.name))) {
      yield next;
    }
  }
}

function build({ appid, out }) {
  if (!/^wx[0-9a-f]{16}$/.test(appid)) throw new Error('appid 格式不正确：' + appid);
  fs.rmSync(out, { recursive: true, force: true });
  let bytes = 0;
  const files = [];
  for (const rel of walk(root)) {
    const to = path.join(out, rel);
    fs.mkdirSync(path.dirname(to), { recursive: true });
    fs.copyFileSync(path.join(root, rel), to);
    bytes += fs.statSync(to).size;
    files.push(rel);
  }
  // 仓库里的 project.config.json 使用占位 appid（touristappid），上传时换成真实 AppID
  const configPath = path.join(out, 'project.config.json');
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  config.appid = appid;
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2) + '\n');
  return { files, bytes };
}

module.exports = { build, walk };

if (require.main === module) {
  const out = path.resolve(root, arg('out', 'dist'));
  const { files, bytes } = build({ appid: arg('appid', ''), out });
  console.log(`已整理 ${files.length} 个文件，${(bytes / 1024).toFixed(0)} KB -> ${path.relative(process.cwd(), out)}`);
}
