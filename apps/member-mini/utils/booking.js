// 预约流程的纯计算：日期条、已选服务合计、按预计工时估算的施工进度。
const { WEEK, parts, hm, dateTime } = require('./format');

const pad = (n) => (n < 10 ? '0' + n : '' + n);

/** 星期几，周一=1 … 周日=7（与数据库 isodow 一致） */
function isoDow(day) {
  const d = new Date(day + 'T00:00:00Z').getUTCDay();
  return d === 0 ? 7 : d;
}

/** 从今天（北京时间）起 advance_days+1 天；休息日不可选。 */
function dateStrip(now, settings) {
  const s = settings || {};
  const closed = s.closed_days || [];
  const span = Math.min(Math.max(Number(s.advance_days) || 30, 1), 90);
  const t = parts(now);
  const base = Date.UTC(t.y, t.m - 1, t.d);
  const out = [];
  for (let i = 0; i <= span; i++) {
    const d = new Date(base + i * 86400000);
    const day = d.getUTCFullYear() + '-' + pad(d.getUTCMonth() + 1) + '-' + pad(d.getUTCDate());
    out.push({ day, week: i === 0 ? '今天' : WEEK[d.getUTCDay()], date: d.getUTCDate(), disabled: closed.indexOf(isoDow(day)) >= 0 });
  }
  return out;
}

function firstOpenDay(strip) {
  const hit = strip.find((d) => !d.disabled);
  return hit ? hit.day : (strip[0] && strip[0].day) || '';
}

/** 已选服务合计：数量、工时、会员价合计、原价合计。 */
function totals(selected) {
  return selected.reduce(
    (a, s) => ({
      count: a.count + 1,
      minutes: a.minutes + Number(s.duration_minutes || 0),
      member: Math.round((a.member + Number(s.member_price || 0)) * 100) / 100,
      original: Math.round((a.original + Number(s.price || 0)) * 100) / 100,
    }),
    { count: 0, minutes: 0, member: 0, original: 0 }
  );
}

/** 约 8 小时 / 约 90 分钟 */
function hoursText(minutes) {
  if (minutes < 120) return minutes + ' 分钟';
  return Math.round((minutes / 60) * 10) / 10 + ' 小时';
}

/**
 * 施工进度。系统目前没有施工节点数据（需要员工端上报），所以这里只按“到店后已用时 / 预计工时”估算，
 * 页面上明确写“按预计工时估算”，不冒充真实施工进度。TODO：员工端上报施工节点后改为真实进度。
 */
function estimate(appt, now) {
  const start = Date.parse(appt.arrived_at || appt.starts_at);
  const total = Math.max(Number(appt.duration_minutes) || 0, 1) * 60000;
  const elapsed = Math.max(now - start, 0);
  const percent = Math.min(Math.floor((elapsed / total) * 100), 99);
  const finishAt = start + total;
  const left = Math.max(finishAt - now, 0);
  const lh = Math.floor(left / 3600000);
  const lm = Math.ceil((left % 3600000) / 60000);
  return {
    percent,
    finish: hm(finishAt),
    left: left <= 0 ? '已超出预计时间，请联系门店' : ('剩余约 ' + (lh > 0 ? lh + ' 小时 ' : '') + (lm > 0 ? lm + ' 分钟' : '')).trim(),
    ring: Math.round((percent / 100) * 2 * Math.PI * 41.5 * 10) / 10,
  };
}

/** 施工节点：只展示有真实时间戳的（预约 / 到店 / 完工）和预计完工。 */
function timeline(appt, now) {
  const nodes = [{ title: '预约成功', note: dateTime(appt.created_at || appt.starts_at), state: 'done' }];
  if (appt.arrived_at) nodes.push({ title: '到店接车', note: hm(appt.arrived_at), state: 'done' });
  if (appt.status === 'done') {
    nodes.push({ title: '完工交车', note: appt.completed_at ? hm(appt.completed_at) : '', state: 'done' });
  } else if (appt.status === 'arrived') {
    const e = estimate(appt, now);
    nodes.push({ title: '施工中', note: '进行中', state: 'current' });
    nodes.push({ title: '完工交车', note: '预计 ' + e.finish, state: 'todo' });
  }
  return nodes;
}

module.exports = { isoDow, dateStrip, firstOpenDay, totals, hoursText, estimate, timeline };
