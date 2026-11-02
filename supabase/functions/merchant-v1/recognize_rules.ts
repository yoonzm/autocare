// 车牌识别 mock 的纯函数部分（可单元测试）。
// 仅开发环境使用：真实识别服务接入前，由 mock 随机给出“门店已有会员的车牌”或“一个库里没有的随机车牌”。

const LETTERS = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // 车牌不用 I、O
const ALNUM = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
const PROVINCES = '沪苏浙京粤';

const pick = (chars: string, rng: () => number) => chars[Math.floor(rng() * chars.length)] ?? chars[0];

/** 随机生成一个燃油车牌：省份 + 字母 + 5 位字母数字，如 `沪A8K29M`。 */
export function randomPlate(rng: () => number = Math.random): string {
  let s = pick(PROVINCES, rng) + pick(LETTERS, rng);
  for (let i = 0; i < 5; i++) s += pick(ALNUM, rng);
  return s;
}

/** 在已有车牌里找不到的随机车牌；尝试 [tries] 次仍重复就返回最后一个（概率极低）。 */
export function randomPlateNotIn(existing: Set<string>, rng: () => number = Math.random, tries = 20): string {
  let plate = randomPlate(rng);
  for (let i = 0; i < tries && existing.has(plate); i++) plate = randomPlate(rng);
  return plate;
}

/** 50% 概率找已有会员，否则生成一个没有的车牌。 */
export const wantsExisting = (rng: () => number = Math.random) => rng() < 0.5;

/** `1234.5` 以内的剩余次数摘要：`洗车年卡 8 次 · 内饰清洁 2 次`；没有则 `无次卡`。 */
export function packageSummary(rows: { name: string; left: number }[]): string {
  const parts = rows.filter((r) => r.left > 0).map((r) => `${r.name} ${r.left} 次`);
  return parts.length ? parts.join(' · ') : '无次卡';
}

/** 最近到店：`10.31 · 精致洗车`（东八区）；没到过店返回 `还没到过店`。 */
export function lastVisitText(at: string | null, items: string): string {
  if (!at) return '还没到过店';
  const t = new Date(new Date(at).getTime() + 8 * 3600000);
  const d = `${String(t.getUTCMonth() + 1).padStart(2, '0')}.${String(t.getUTCDate()).padStart(2, '0')}`;
  return items ? `${d} · ${items}` : d;
}
