import { lastVisitText, packageSummary, randomPlate, randomPlateNotIn, wantsExisting } from './recognize_rules.ts';

const eq = (a: unknown, b: unknown, msg: string) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${msg}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);
};

Deno.test('random plate: province + letter + 5 alnum, no I / O', () => {
  for (let i = 0; i < 200; i++) {
    const p = randomPlate();
    if (!/^[沪苏浙京粤][A-HJ-NP-Z][A-HJ-NP-Z0-9]{5}$/.test(p)) throw new Error(p);
  }
});

Deno.test('random plate avoids existing plates', () => {
  let n = 0;
  const rng = () => (n++ < 7 ? 0 : 0.5); // 第一个车牌固定为 沪AAAAAA… ，已存在就重来
  const first = randomPlate(() => 0);
  const got = randomPlateNotIn(new Set([first]), rng);
  if (got === first) throw new Error('duplicate');
});

Deno.test('50% split', () => {
  eq([wantsExisting(() => 0.49), wantsExisting(() => 0.5)], [true, false], 'boundary');
});

Deno.test('summaries', () => {
  eq(packageSummary([{ name: '洗车年卡', left: 8 }, { name: '内饰清洁', left: 2 }, { name: '用完', left: 0 }]),
    '洗车年卡 8 次 · 内饰清洁 2 次', 'pkg');
  eq(packageSummary([]), '无次卡', 'none');
  eq(lastVisitText('2026-10-31T10:00:00Z', '精致洗车'), '10.31 · 精致洗车', 'visit');
  eq(lastVisitText('2026-10-31T17:00:00Z', ''), '11.01', 'china time');
  eq(lastVisitText(null, ''), '还没到过店', 'never');
});
