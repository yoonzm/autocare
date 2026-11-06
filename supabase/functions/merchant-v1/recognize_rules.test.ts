import { lastVisitText, packageSummary } from './recognize_rules.ts';

const eq = (a: unknown, b: unknown, msg: string) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${msg}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);
};

Deno.test('summaries', () => {
  eq(packageSummary([{ name: '洗车年卡', left: 8 }, { name: '内饰清洁', left: 2 }, { name: '用完', left: 0 }]),
    '洗车年卡 8 次 · 内饰清洁 2 次', 'pkg');
  eq(packageSummary([]), '无次卡', 'none');
  eq(lastVisitText('2026-10-31T10:00:00Z', '精致洗车'), '10.31 · 精致洗车', 'visit');
  eq(lastVisitText('2026-10-31T17:00:00Z', ''), '11.01', 'china time');
  eq(lastVisitText(null, ''), '还没到过店', 'never');
});
