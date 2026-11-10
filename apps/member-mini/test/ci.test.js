const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { build } = require('../tools/package');
const { robotOf, versionOf, descOf, MARK } = require('../tools/weapp_ci');

test('机器人编号：默认 30，避开 member-client 流水线默认用的 1 号', () => {
  assert.equal(robotOf(''), 30);
  assert.equal(robotOf('7'), 7);
  for (const bad of ['0', '31', 'x', '1.5']) assert.throws(() => robotOf(bad), /1~30/);
});

test('版本号：默认 0.0.<UTC 时间到分钟>，自定义必须是 x.y(.z)', () => {
  assert.equal(versionOf('', new Date('2026-11-10T08:05:00Z')), '0.0.2611100805');
  assert.equal(versionOf('1.2.3'), '1.2.3');
  assert.throws(() => versionOf('v1'), /格式/);
  assert.throws(() => versionOf('1.2.3.4'), /格式/);
});

test('上传描述固定带“勿提交审核”并限制长度', () => {
  assert.ok(descOf('').startsWith(MARK));
  assert.ok(descOf('abc').includes('abc'));
  assert.ok(descOf('x'.repeat(500)).length <= 200);
  assert.ok(MARK.includes('勿提交审核'));
});

test('打包：只含运行文件，appid 换成真实值，不含测试 / 工具 / 样式源', () => {
  const out = fs.mkdtempSync(path.join(os.tmpdir(), 'member-mini-pkg-'));
  try {
    const { files, bytes } = build({ appid: 'wxa9586ff6437c2379', out });
    assert.ok(files.length > 60 && bytes < 1024 * 1024, `files=${files.length} bytes=${bytes}`);
    for (const f of files) {
      assert.doesNotMatch(f, /^(test|tools|styles|node_modules)[\\/]/, f);
      assert.doesNotMatch(f, /\.px\.(wxss|wxml)$|\.md$|^package/, f);
    }
    for (const must of ['app.js', 'app.json', 'app.wxss', 'project.config.json', 'pages/home/home.wxml', 'pages/home/home.js', 'custom-tab-bar/index.js']) {
      assert.ok(files.includes(must), '缺少 ' + must);
    }
    const cfg = JSON.parse(fs.readFileSync(path.join(out, 'project.config.json'), 'utf8'));
    assert.equal(cfg.appid, 'wxa9586ff6437c2379');
    assert.equal(JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'project.config.json'), 'utf8')).appid, 'touristappid', '仓库里仍是占位 appid');
    assert.throws(() => build({ appid: 'bad', out }), /appid/);
  } finally {
    fs.rmSync(out, { recursive: true, force: true });
  }
});

test('发布工作流：手动触发、使用环境密钥、先跑测试、不打印密钥', () => {
  const wf = fs.readFileSync(path.join(__dirname, '../../../.github/workflows/member-mini-publish.yml'), 'utf8');
  assert.match(wf, /workflow_dispatch:/);
  assert.doesNotMatch(wf, /\n\s+push:/, '不能因为推送自动上传到正式 AppID');
  assert.match(wf, /environment:\s*member-mini-test/);
  assert.match(wf, /secrets\.MEMBER_MINI_UPLOAD_KEY/);
  assert.match(wf, /npm test/);
  assert.doesNotMatch(wf, /echo[^\n]*\$\{\{\s*secrets\./, '不能 echo 密钥');
  assert.doesNotMatch(wf, /BEGIN RSA PRIVATE KEY/);
});
