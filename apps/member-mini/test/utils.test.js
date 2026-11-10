const test = require('node:test');
const assert = require('node:assert/strict');
const f = require('../utils/format');
const b = require('../utils/booking');
const svg = require('../utils/svg');
const icons = require('../utils/icons');

test('金额格式', () => {
  assert.equal(f.yuan(1422), '¥1,422');
  assert.equal(f.yuan(61.5), '¥61.50');
  assert.equal(f.yuan(0), '¥0');
  assert.equal(f.yuan(-196), '-¥196');
  assert.equal(f.yuan(1234567.8), '¥1,234,567.80');
  assert.equal(f.money2(3680), '3,680.00');
  assert.equal(f.int(12450), '12,450');
});

test('时间一律按北京时间，与设备时区无关', () => {
  const iso = '2026-11-01T02:30:00.000Z'; // 北京 10:30，周日
  assert.equal(f.dateTime(iso), '11月1日 周日 10:30');
  assert.equal(f.hm(iso), '10:30');
  assert.equal(f.md('2026-12-31T17:00:00Z'), '1月1日', '跨日换算');
  assert.equal(f.ymd('2023-04-05T00:00:00Z'), '2023.04.05');
  assert.equal(f.bjIso('2026-11-01', '10:30'), '2026-11-01T10:30:00+08:00');
  assert.equal(new Date(f.bjIso('2026-11-01', '10:30')).toISOString(), iso);
  const now = Date.parse('2026-11-01T01:00:00Z'); // 北京 9:00
  assert.deepEqual(f.dayBadge(iso, now), { label: '今天', day: 1 });
  assert.equal(f.dayBadge('2026-11-02T02:00:00Z', now).label, '明天');
  assert.equal(f.dayBadge('2026-11-03T02:00:00Z', now).label, '周二');
});

test('倒计时 / 工时 / 车牌 / 状态', () => {
  const now = Date.parse('2026-11-01T00:12:00Z');
  assert.equal(f.countdown('2026-11-01T02:30:00Z', now), '2 小时 18 分');
  assert.equal(f.countdown('2026-11-01T00:40:00Z', now), '28 分');
  assert.equal(f.countdown('2026-11-03T02:30:00Z', now), '2 天 2 小时');
  assert.equal(f.countdown('2026-11-01T00:00:00Z', now), '');
  assert.equal(f.duration(60), '约 60 分钟');
  assert.equal(f.duration(360), '约 6 小时');
  assert.equal(f.duration(150), '约 2.5 小时');
  assert.equal(f.plateText('沪A8K29M'), '沪A·8K29M');
  assert.equal(f.plateText('沪AF09316'), '沪AF·09316');
  assert.equal(f.status('late').text, '待到店');
  assert.equal(f.status('arrived').text, '施工中');
  assert.equal(f.status('weird').text, '待到店');
  assert.equal(f.maskPhone('13800006021'), '138 **** 6021');
  assert.equal(f.maskPhone('x'), '');
});

test('日期条：从今天起，休息日不可选，按北京时间算', () => {
  const now = Date.parse('2026-10-31T17:00:00Z'); // 北京 11/1 01:00 周日
  const strip = b.dateStrip(now, { advance_days: 7, closed_days: [3] });
  assert.equal(strip.length, 8);
  assert.deepEqual(strip[0], { day: '2026-11-01', week: '今天', date: 1, disabled: false });
  assert.equal(strip[1].week, '周一');
  assert.equal(strip[3].disabled, true, '11/4 周三休息');
  assert.equal(b.firstOpenDay(strip), '2026-11-01');
  assert.equal(b.firstOpenDay(b.dateStrip(now, { advance_days: 1, closed_days: [1, 2, 3, 4, 5, 6, 7] })), '2026-11-01');
  assert.equal(b.isoDow('2026-11-01'), 7);
  assert.equal(b.isoDow('2026-11-02'), 1);
  assert.equal(b.dateStrip(now, { advance_days: 999 }).length, 91, '最多 90 天');
});

test('已选服务合计', () => {
  const t = b.totals([
    { duration_minutes: 360, member_price: 1422, price: 1580 },
    { duration_minutes: 120, member_price: 342, price: 380 },
  ]);
  assert.deepEqual(t, { count: 2, minutes: 480, member: 1764, original: 1960 });
  assert.equal(b.hoursText(480), '8 小时');
  assert.equal(b.hoursText(90), '90 分钟');
  assert.equal(b.totals([{ member_price: 0.1, price: 0.2 }, { member_price: 0.2, price: 0.1 }]).member, 0.3, '浮点误差');
});

test('施工进度只按预计工时估算，不会显示 100%', () => {
  const appt = { arrived_at: '2026-11-01T02:42:00Z', starts_at: '2026-11-01T02:30:00Z', duration_minutes: 360 };
  const at = (min) => Date.parse('2026-11-01T02:42:00Z') + min * 60000;
  assert.equal(b.estimate(appt, at(0)).percent, 0);
  assert.equal(b.estimate(appt, at(180)).percent, 50);
  assert.equal(b.estimate(appt, at(180)).finish, '16:42');
  assert.equal(b.estimate(appt, at(9999)).percent, 99);
  assert.match(b.estimate(appt, at(9999)).left, /联系门店/);
  assert.equal(b.estimate(appt, at(300)).left, '剩余约 1 小时');
  const nodes = b.timeline({ ...appt, status: 'arrived', created_at: '2026-10-30T02:00:00Z' }, at(10));
  assert.deepEqual(nodes.map((n) => n.state), ['done', 'done', 'current', 'todo']);
  assert.equal(b.timeline({ status: 'waiting', starts_at: appt.starts_at }, at(0)).length, 1);
});

test('SVG base64 与图标库', () => {
  assert.equal(svg.base64('Man'), 'TWFu');
  assert.equal(svg.base64('Ma'), 'TWE=');
  assert.equal(svg.base64('M'), 'TQ==');
  assert.throws(() => svg.base64('中'));
  for (const [name, body] of Object.entries(icons)) {
    const uri = svg.iconUri(name, '#0485F7', 24, 1.8);
    const xml = Buffer.from(uri.split(',')[1], 'base64').toString();
    assert.ok(xml.startsWith('<svg') && xml.endsWith('</svg>'), name);
    assert.ok(body.length > 10, name);
  }
  assert.equal(svg.iconUri('shop', '#000', 24, 1.8), svg.iconUri('shop', '#000', 24, 1.8));
  const ring = Buffer.from(svg.ringUri(52, 6, '#E4E4E7', '#0485F7', 0.65).split(',')[1], 'base64').toString();
  assert.match(ring, /stroke-dasharray="93\.\d 5\d\.\d"/);
});

const v = require('../utils/view');
const qrcode = require('../utils/qrcode');
const session = require('../utils/session');

test('服务图标：按分类，未知分类稳定轮换', () => {
  assert.equal(v.serviceStyle('洗车', 'x').cls, 'g-blue');
  assert.equal(v.serviceStyle('镀晶镀膜', 'x').icon, 'star');
  assert.deepEqual(v.serviceStyle('其他', '抛光'), v.serviceStyle('其他', '抛光'));
});

test('折扣文案', () => {
  assert.equal(v.discountText(0.9), '9 折');
  assert.equal(v.discountText(0.85), '8.5 折');
  assert.equal(v.discountText(1), '');
});

test('预约卡片：今天 / 明天、车牌颜色、状态', () => {
  const now = Date.parse('2026-11-01T01:00:00Z');
  const a = v.appointmentView({ status: 'waiting', starts_at: '2026-11-01T02:30:00Z', items: [{ name: '全车镀晶' }, { name: '内饰清洁' }], plate: '沪AF09316', estimate: 1764, vehicle: { brand_model: '理想 L7', color: '灰色', energy: 'ev' } }, now);
  assert.equal(a.text, '全车镀晶 + 内饰清洁');
  assert.equal(a.badge.label, '今天');
  assert.equal(a.ev, true);
  assert.equal(a.edge, '#17C964');
  assert.equal(a.car, '理想 L7 · 灰色');
  assert.equal(a.price, '¥1,764');
});

test('消费记录：按今天 / 本月 / 月份分组，金额与状态', () => {
  const now = Date.parse('2026-11-03T04:00:00Z');
  const rows = [
    { kind: 'order', at: '2026-11-03T02:42:00Z', amount: 1422, title: 'x', status: 'completed', plate: '沪A8K29M', by_package: false },
    { kind: 'order', at: '2026-11-01T02:00:00Z', amount: 0, title: 'y', status: 'completed', by_package: true },
    { kind: 'recharge', at: '2026-10-05T08:40:00Z', amount: 1080 },
    { kind: 'package', at: '2026-10-04T08:40:00Z', amount: 580, status: 'refunded' },
  ].map(v.orderRow);
  const groups = v.groupOrders(rows, now);
  assert.deepEqual(groups.map((g) => g.title), ['今天', '11月1日', '10 月']);
  assert.equal(groups[2].items.length, 2);
  assert.equal(rows[0].amountText, '¥1,422');
  assert.equal(rows[1].amountText, '次卡 1 次');
  assert.equal(rows[2].amountText, '+¥1,080');
  assert.equal(rows[3].pill.text, '已退款');
  assert.equal(rows[0].link, true);
  assert.equal(rows[2].link, false);
});

test('次卡与可购买套餐', () => {
  const now = Date.parse('2026-11-01T00:00:00Z');
  const p = v.myPackage({ id: 'p', name: '年卡', total: 20, used: 8, expires_at: '2026-12-31T15:59:59Z' }, now);
  assert.equal(p.left, 12);
  assert.match(p.exp, /^2026\.12\.31 到期 · 剩余 61 天$/);
  assert.equal(v.myPackage({ id: 'q', name: '永久', total: 2, used: 0, expires_at: null }, now).exp, '长期有效');
  const o = v.offerView({ id: 'k', name: '10 次卡', price: 580, validity_months: 6, items: [{ name: '洗车', count: 10, price: 68 }] });
  assert.equal(o.per, '¥58');
  assert.equal(o.save, '省 ¥100');
  assert.equal(o.valid, '6 个月');
  assert.equal(v.offerView({ id: 'k', name: 'x', price: 100, validity_months: 12, items: [{ count: 1, price: 50 }] }).save, '', '没有优惠不显示“省”');
  assert.equal(v.offerView({ id: 'k', name: 'x', price: 1, validity_months: 0, items: [] }).valid, '长期有效');
});

test('会员等级阶梯与权益只列真实配置', () => {
  const tiers = [
    { id: 'a', name: '普通', discount: 1, upgrade_recharge: null, upgrade_cumulative: null },
    { id: 'b', name: '银卡', discount: 0.95, upgrade_cumulative: 2000, points_multiplier: 1.5 },
    { id: 'c', name: '黑金', discount: 0.9, upgrade_cumulative: 20000, birthday_gift: '洗车 1 次', priority_booking: true, points_multiplier: 2 },
  ];
  const l = v.ladder(tiers, { level: { id: 'b' }, total_spent: 500 });
  assert.deepEqual(l.steps.map((s) => s.state), ['done', 'current', 'todo']);
  assert.equal(l.progress, 3);
  assert.equal(l.hint, '再消费 ¥19,500 升级黑金');
  assert.equal(v.ladder(tiers, { level: { id: 'c' }, total_spent: 99999 }).hint, '已是最高等级');
  assert.equal(v.ladder(tiers, { level: { id: 'unknown' }, total_spent: 0 }).current.id, 'a');
  assert.deepEqual(v.benefits(tiers[2]).map((b) => b.title), ['全部服务 9 折', '积分 2 倍', '生日礼', '预约优先']);
  assert.deepEqual(v.benefits(tiers[0]), []);
});

test('二维码：能为会员码内容生成矩阵，左上角是定位图案', () => {
  const qr = qrcode(0, 'M');
  qr.addData('ACM1:ABCDEFGHJKLMNPQRSTUV');
  qr.make();
  const n = qr.getModuleCount();
  assert.ok(n >= 25 && n <= 41, 'module count ' + n);
  for (let i = 0; i < 7; i++) assert.equal(qr.isDark(0, i), true);
  assert.equal(qr.isDark(1, 1), false);
});

test('扫门店码进入：scene 为 32 位十六进制，query.s 带连字符都能识别', () => {
  const id = '0f1e2d3c-4b5a-4968-8776-655443322110';
  assert.equal(session.storeFromLaunch({ query: { scene: id.replace(/-/g, '') } }), id);
  assert.equal(session.storeFromLaunch({ query: { s: id } }), id);
  assert.equal(session.storeFromLaunch({ query: { scene: encodeURIComponent(id.replace(/-/g, '').toUpperCase()) } }), id);
  assert.equal(session.storeFromLaunch({ query: { scene: 'x=1' } }), null);
  assert.equal(session.storeFromLaunch({}), null);
  assert.equal(session.storeFromLaunch(undefined), null);
});
