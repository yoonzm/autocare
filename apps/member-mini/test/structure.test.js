// 小程序结构检查：没有开发者工具也能发现常见的低级错误（缺文件、漏注册的组件、不存在的事件处理函数、标签不配对、
// 生成文件过期、缺少 placeholder、跳转到不存在的页面、不存在的图标）。
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');

const root = path.join(__dirname, '..');
const read = (p) => fs.readFileSync(path.join(root, p), 'utf8');
const app = JSON.parse(read('app.json'));
const icons = require('../utils/icons');

const wxmlOf = (dir, name) => (fs.existsSync(path.join(root, dir, name + '.px.wxml')) ? name + '.px.wxml' : name + '.wxml');
const units = [
  ...app.pages.map((p) => ({ base: p, dir: path.dirname(p), name: path.basename(p), kind: 'page' })),
  ...['navbar', 'icon', 'plate', 'async-view', 'qr-code'].map((n) => ({ base: `components/${n}/${n}`, dir: `components/${n}`, name: n, kind: 'component' })),
  { base: 'custom-tab-bar/index', dir: 'custom-tab-bar', name: 'index', kind: 'component' },
];

test('每个页面 / 组件都有 js、json、wxml', () => {
  for (const u of units) for (const ext of ['.js', '.json', '.wxml']) assert.ok(fs.existsSync(path.join(root, u.base + ext)), u.base + ext);
});

test('按设计稿像素书写的样式 / 模板与生成的 rpx 文件保持同步', () => {
  execFileSync('python3', [path.join(root, 'tools/px2rpx.py'), '--check'], { stdio: 'pipe' });
});

test('app.json：18 个设计页 + 底部三个标签页，且标签页在 pages 里', () => {
  assert.equal(app.pages.length, 19, '设计稿 20 张画板里“取消预约”是弹层，并入预约详情页');
  for (const t of app.tabBar.list) assert.ok(app.pages.includes(t.pagePath), t.pagePath);
  assert.equal(app.tabBar.custom, true);
  assert.ok(fs.existsSync(path.join(root, 'custom-tab-bar/index.js')));
});

for (const u of units) {
  test(`${u.base}: 标签配对、组件已注册、事件处理函数存在`, () => {
    const wxml = read(path.join(u.dir, wxmlOf(u.dir, u.name)));
    const json = JSON.parse(read(u.base + '.json'));
    const js = read(u.base + '.js');
    const stack = [];
    for (const m of wxml.replace(/<!--[\s\S]*?-->/g, '').matchAll(/<(\/?)([a-zA-Z][\w-]*)([^>]*?)(\/?)>/g)) {
      const [, close, tag, , self] = m;
      if (self) continue;
      if (close) assert.equal(stack.pop(), tag, `${u.base}: </${tag}> 没有对应的开始标签`);
      else stack.push(tag);
    }
    assert.deepEqual(stack, [], `${u.base}: 标签没有闭合`);
    for (const tag of ['navbar', 'icon', 'plate', 'async-view', 'qr-code']) {
      if (new RegExp(`<${tag}[\\s>/]`).test(wxml) && !(u.kind === 'component' && u.name === tag)) {
        assert.ok(json.usingComponents && json.usingComponents[tag], `${u.base}: 用了 <${tag}> 但没有注册`);
      }
    }
    for (const m of wxml.matchAll(/\b(?:bind|catch)(?::)?[a-z]+="([A-Za-z_]\w*)"/g)) {
      assert.match(js, new RegExp(`\\b${m[1]}\\s*[(:]`), `${u.base}: 找不到处理函数 ${m[1]}`);
    }
  });
}

test('跳转目标都存在于 app.json', () => {
  const known = new Set(app.pages.map((p) => '/' + p));
  const seen = [];
  for (const u of units) {
    for (const f of [u.base + '.js', path.join(u.dir, wxmlOf(u.dir, u.name))]) {
      for (const m of read(f).matchAll(/(\/pages\/[a-z-]+\/[a-z-]+)(?:\?|['"`])/g)) seen.push([f, m[1]]);
    }
  }
  assert.ok(seen.length > 20);
  for (const [f, url] of seen) assert.ok(known.has(url), `${f} 跳转到不存在的页面 ${url}`);
});

test('所有表单输入框都有 placeholder（项目规范）', () => {
  for (const u of units) {
    const wxml = read(path.join(u.dir, wxmlOf(u.dir, u.name)));
    for (const m of wxml.matchAll(/<(input|textarea)\b[^>]*>/g)) assert.match(m[0], /placeholder="[^"]+"/, `${u.base}: ${m[0]}`);
  }
});

test('图标名称都在图标库里', () => {
  for (const u of units) {
    const text = read(path.join(u.dir, wxmlOf(u.dir, u.name))) + read(u.base + '.js');
    for (const m of text.matchAll(/<icon\b[^>]*\bname="([a-z]+)"/g)) assert.ok(icons[m[1]], `${u.base}: 图标 ${m[1]}`);
    for (const m of text.matchAll(/\bicon: '([a-z]+)'/g)) assert.ok(icons[m[1]], `${u.base}: 图标 ${m[1]}`);
  }
  for (const m of read('utils/view.js').matchAll(/icon: '([a-z]+)'/g)) assert.ok(icons[m[1]], '图标 ' + m[1]);
});

test('小程序里不出现密钥、手机号明文或示例业务数据', () => {
  const files = [];
  (function walk(d) {
    for (const e of fs.readdirSync(path.join(root, d), { withFileTypes: true })) {
      if (['node_modules', 'test', 'utils/qrcode.js'].includes(e.name)) continue;
      const p = path.join(d, e.name);
      if (e.isDirectory()) walk(p);
      else if (/\.(js|wxml|json)$/.test(e.name) && p !== 'utils/qrcode.js') files.push(p);
    }
  })('.');
  for (const f of files) {
    const text = read(f);
    assert.doesNotMatch(text, /secret\s*[:=]\s*['"][\w-]{8,}/i, f);
    assert.doesNotMatch(text, /1[3-9]\d{9}/, f + ' 含手机号');
    assert.doesNotMatch(text, /王建国|驰光|沪A·8K29M/, f + ' 含设计稿示例数据');
  }
});
