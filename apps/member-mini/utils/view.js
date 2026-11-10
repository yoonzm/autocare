// 视图模型：把接口数据整理成页面直接展示的字段（纯函数，便于单测）。
const f = require('./format');

const CAT = {
  洗车: { cls: 'g-blue', icon: 'shop' },
  镀晶镀膜: { cls: 'g-amber', icon: 'star' },
  镀晶: { cls: 'g-amber', icon: 'star' },
  内饰: { cls: 'g-green', icon: 'car' },
  美容: { cls: 'g-green', icon: 'car' },
  轮毂: { cls: 'g-violet', icon: 'gift' },
  贴膜: { cls: 'g-violet', icon: 'gift' },
};
const CYCLE = [CAT.洗车, CAT.镀晶, CAT.内饰, CAT.轮毂];

/** 服务项目的图标底色：按分类，未知分类按名称稳定地轮换。 */
function serviceStyle(category, name) {
  if (CAT[category]) return CAT[category];
  let h = 0;
  for (const ch of String(category || '') + String(name || '')) h = (h * 31 + ch.charCodeAt(0)) >>> 0;
  return CYCLE[h % CYCLE.length];
}

const TIER_TONE = { black: 'gold', champagne: 'gold', silver: 'grey', blue: 'blue', white: 'grey' };

/** 折扣 0.9 -> “9 折”；整数折显示 9，0.85 显示 8.5；无折扣返回 ''。 */
function discountText(d) {
  const n = Number(d);
  if (!(n > 0) || n >= 1) return '';
  return Math.round(n * 100) / 10 + ' 折';
}

function appointmentView(a, now) {
  const ev = a.vehicle ? a.vehicle.energy === 'ev' : String(a.plate).length === 8;
  const st = f.status(a.status);
  const v = a.vehicle || {};
  return Object.assign({}, a, {
    ev,
    st,
    when: f.dateTime(a.starts_at),
    time: f.hm(a.starts_at),
    badge: f.dayBadge(a.starts_at, now),
    text: f.itemsText(a.items) || '服务预约',
    car: [v.brand_model, v.color].filter(Boolean).join(' · '),
    price: f.yuan(a.estimate),
    edge: a.status === 'waiting' || a.status === 'late' ? (ev ? '#17C964' : '#0485F7') : a.status === 'arrived' ? '#0485F7' : '#D4D4D8',
  });
}

/** 今天 / 本月标题分组：同一天（北京时间）或同一月 */
function groupOrders(items, now) {
  const today = f.dayKey(now);
  const thisMonth = today.slice(0, 7);
  const groups = [];
  for (const it of items) {
    const key = f.dayKey(it.at);
    const title = key === today ? '今天' : key.slice(0, 7) === thisMonth ? f.md(it.at) : Number(key.slice(5, 7)) + ' 月';
    let g = groups[groups.length - 1];
    if (!g || g.title !== title) groups.push((g = { title, items: [] }));
    g.items.push(it);
  }
  return groups;
}

function orderRow(o) {
  if (o.kind === 'recharge') {
    return Object.assign({}, o, { icon: 'wallet', tone: 'tone-amber', amountText: '+' + f.yuan(o.amount), sub: f.md(o.at) + ' ' + f.hm(o.at), pill: { text: '已到账', tone: 'green' }, link: false });
  }
  if (o.kind === 'package') {
    return Object.assign({}, o, { icon: 'gift', tone: 'tone-amber', amountText: f.yuan(o.amount), sub: f.md(o.at) + ' ' + f.hm(o.at), pill: o.status === 'refunded' ? { text: '已退款', tone: 'grey' } : { text: '已完成', tone: 'green' }, link: false });
  }
  const refunded = o.status === 'refunded';
  return Object.assign({}, o, {
    icon: 'shop',
    tone: o.by_package ? 'tone-green' : 'tone-blue',
    amountText: o.by_package && !Number(o.amount) ? '次卡 1 次' : f.yuan(o.amount),
    sub: f.md(o.at) + ' ' + f.hm(o.at) + (o.plate ? ' · ' + f.plateText(o.plate) : ''),
    pill: refunded ? { text: '已退款', tone: 'grey' } : { text: '已完成', tone: 'green' },
    link: true,
  });
}

/** 次卡（我的）：剩余、已用、到期。 */
function myPackage(p, now) {
  const left = p.total - p.used;
  let exp = '长期有效';
  if (p.expires_at) {
    const days = Math.ceil((Date.parse(p.expires_at) - now) / 86400000);
    exp = f.ymd(p.expires_at) + ' 到期' + (days <= 90 ? ' · 剩余 ' + days + ' 天' : '');
  }
  return {
    id: p.id, name: p.name, left, used: p.used, total: p.total, exp,
    ring: Math.round(((p.used / p.total) || 0) * 100),
  };
}

/** 可购买次卡：单次均价与相对原价的节省。 */
function offerView(k) {
  const count = k.items.reduce((s, i) => s + Number(i.count), 0) || 1;
  const original = k.items.reduce((s, i) => s + Number(i.count) * Number(i.price), 0);
  const save = Math.round((original - Number(k.price)) * 100) / 100;
  const per = Math.round((Number(k.price) / count) * 100) / 100;
  return {
    id: k.id, name: k.name, price: f.yuan(k.price), per: f.yuan(per),
    valid: k.validity_months ? k.validity_months >= 12 && k.validity_months % 12 === 0 ? k.validity_months / 12 + ' 年' : k.validity_months + ' 个月' : '长期有效',
    save: save > 0 ? '省 ' + f.yuan(save) : '', description: k.description,
  };
}

/** 会员等级阶梯与下一级的差距。 */
function ladder(tiers, member) {
  const rank = (t) => Number(t.upgrade_recharge || 0) * 1e6 + Number(t.upgrade_cumulative || 0);
  const sorted = tiers.slice().sort((a, b) => rank(a) - rank(b));
  const idx = Math.max(sorted.findIndex((t) => t.id === member.level.id), 0);
  const need = (t) => (t.upgrade_cumulative ? '累计 ' + f.yuan(t.upgrade_cumulative) : t.upgrade_recharge ? '单次充值 ' + f.yuan(t.upgrade_recharge) : '0 起');
  const steps = sorted.map((t, i) => ({ id: t.id, name: t.name, need: need(t), state: i < idx ? 'done' : i === idx ? 'current' : 'todo' }));
  const next = sorted[idx + 1];
  let progress = 100;
  let hint = '已是最高等级';
  if (next) {
    if (next.upgrade_cumulative) {
      const target = Number(next.upgrade_cumulative);
      const have = Number(member.total_spent || 0);
      progress = Math.min(Math.round((have / target) * 100), 99);
      hint = '再消费 ' + f.yuan(Math.max(target - have, 0)) + ' 升级' + next.name;
    } else {
      progress = 0;
      hint = '单次充值满 ' + f.yuan(next.upgrade_recharge) + ' 升级' + next.name;
    }
  }
  return { steps, progress, hint, current: sorted[idx] };
}

/** 当前等级的权益：只列出真实配置了的。 */
function benefits(tier) {
  const out = [];
  const d = discountText(tier.discount);
  if (d) out.push({ title: '全部服务 ' + d, desc: '会员价，结算时自动享受', icon: 'tag', bg: 'linear-gradient(150deg,#FFF1CF,#FBE0A0)' });
  if (Number(tier.points_multiplier) > 1) out.push({ title: '积分 ' + tier.points_multiplier + ' 倍', desc: '消费 1 元积 ' + tier.points_multiplier + ' 分', icon: 'star', bg: 'linear-gradient(150deg,#E1F0FE,#C7E3FD)' });
  if (tier.birthday_gift) out.push({ title: '生日礼', desc: tier.birthday_gift, icon: 'gift', bg: 'linear-gradient(150deg,#DDF6E7,#BDEFD1)' });
  if (tier.priority_booking) out.push({ title: '预约优先', desc: '热门时段优先安排', icon: 'calendar', bg: 'linear-gradient(150deg,#EDE7FB,#D9CCF6)' });
  return out;
}

module.exports = { serviceStyle, TIER_TONE, discountText, appointmentView, groupOrders, orderRow, myPackage, offerView, ladder, benefits };
