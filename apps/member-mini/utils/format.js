// 展示格式：金额、北京时间、倒计时、状态文案。门店在国内，时间一律按北京时间（UTC+8）展示，与设备时区无关。
const WEEK = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
const BJ = 8 * 3600 * 1000;

function parts(iso) {
  const t = typeof iso === 'number' ? iso : Date.parse(iso);
  const d = new Date(t + BJ);
  return { y: d.getUTCFullYear(), m: d.getUTCMonth() + 1, d: d.getUTCDate(), h: d.getUTCHours(), mi: d.getUTCMinutes(), w: d.getUTCDay(), t };
}
const pad = (n) => (n < 10 ? '0' + n : '' + n);
const grouped = (s) => s.replace(/\B(?=(\d{3})+(?!\d))/g, ',');

/** ¥1,422（整数不带小数）/ ¥61.50 */
function yuan(value) {
  const n = Math.round(Number(value || 0) * 100) / 100;
  const text = Number.isInteger(n) ? String(Math.abs(n)) : Math.abs(n).toFixed(2);
  const [i, f] = text.split('.');
  return (n < 0 ? '-' : '') + '¥' + grouped(i) + (f ? '.' + f : '');
}
/** 3,680.00 */
function money2(value) {
  const [i, f] = Math.abs(Number(value || 0)).toFixed(2).split('.');
  return (Number(value) < 0 ? '-' : '') + grouped(i) + '.' + f;
}
const int = (value) => grouped(String(Math.round(Number(value || 0))));

const hm = (iso) => { const p = parts(iso); return pad(p.h) + ':' + pad(p.mi); };
const md = (iso) => { const p = parts(iso); return p.m + '月' + p.d + '日'; };
const dateTime = (iso) => { const p = parts(iso); return p.m + '月' + p.d + '日 ' + WEEK[p.w] + ' ' + pad(p.h) + ':' + pad(p.mi); };
const ymd = (iso) => { const p = parts(iso); return p.y + '.' + pad(p.m) + '.' + pad(p.d); };
const dayKey = (iso) => { const p = parts(iso); return p.y + '-' + pad(p.m) + '-' + pad(p.d); };

/** 预约卡片左侧的“今天 / 明天 / 周二”+ 日期数字 */
function dayBadge(iso, now) {
  const a = parts(iso);
  const diff = Math.round((Date.UTC(a.y, a.m - 1, a.d) - dayStart(now)) / 86400000);
  return { label: diff === 0 ? '今天' : diff === 1 ? '明天' : WEEK[a.w], day: a.d };
}
function dayStart(now) {
  const p = parts(now == null ? Date.now() : now);
  return Date.UTC(p.y, p.m - 1, p.d);
}

/** 距到店还有 2 小时 18 分；已过期返回 ''。 */
function countdown(iso, now) {
  const ms = Date.parse(iso) - (now == null ? Date.now() : now);
  if (ms <= 0) return '';
  const total = Math.floor(ms / 60000);
  const days = Math.floor(total / 1440);
  const hours = Math.floor((total % 1440) / 60);
  const minutes = total % 60;
  if (days > 0) return days + ' 天 ' + hours + ' 小时';
  if (hours > 0) return hours + ' 小时 ' + minutes + ' 分';
  return Math.max(minutes, 1) + ' 分';
}

/** 约 60 分钟 / 约 6 小时 / 约 2.5 小时 */
function duration(minutes) {
  const m = Number(minutes || 0);
  if (m < 120) return '约 ' + m + ' 分钟';
  const h = Math.round((m / 60) * 10) / 10;
  return '约 ' + h + ' 小时';
}

/** 车牌显示：燃油 7 位在第 2 位后加点，新能源 8 位在第 3 位后加点。 */
function plateText(plate) {
  const p = String(plate || '');
  if (p.length === 7) return p.slice(0, 2) + '·' + p.slice(2);
  if (p.length === 8) return p.slice(0, 3) + '·' + p.slice(3);
  return p;
}

const STATUS = {
  waiting: { text: '待到店', tone: 'blue' },
  late: { text: '待到店', tone: 'blue' },
  arrived: { text: '施工中', tone: 'blue' },
  done: { text: '已完成', tone: 'green' },
  cancelled: { text: '已取消', tone: 'grey' },
};
const status = (s) => STATUS[s] || STATUS.waiting;

const maskPhone = (p) => (/^\d{11}$/.test(String(p || '')) ? p.slice(0, 3) + ' **** ' + p.slice(7) : '');
const itemsText = (items) => (items || []).map((i) => i.name).join(' + ');

/** 时间 → 北京时间 ISO（用于把“某天 10:30”转成 starts_at）。 */
function bjIso(day, time) {
  return day + 'T' + time + ':00+08:00';
}

module.exports = { yuan, money2, int, hm, md, dateTime, ymd, dayKey, dayBadge, countdown, duration, plateText, status, maskPhone, itemsText, bjIso, parts, WEEK };
