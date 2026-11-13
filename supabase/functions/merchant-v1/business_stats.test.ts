import { parseBusinessStats } from './business_stats_rules.ts';

const assert = (ok: boolean, message = 'assertion failed') => {
  if (!ok) throw new Error(message);
};

Deno.test('fixed ranges ignore any supplied dates', () => {
  for (const range of ['today', 'week', 'month']) {
    const parsed = parseBusinessStats({ range, from: '2026-01-01', to: '2026-01-02' });
    assert(!('error' in parsed) && parsed.from === null && parsed.to === null);
  }
});

Deno.test('custom needs two real calendar days; unknown ranges are refused', () => {
  const ok = parseBusinessStats({ range: 'custom', from: '2026-11-01', to: '2026-11-13' });
  assert(!('error' in ok) && ok.from === '2026-11-01' && ok.to === '2026-11-13');
  for (const bad of [
    { range: 'custom' },
    { range: 'custom', from: '2026-11-01' },
    { range: 'custom', from: '2026-02-30', to: '2026-03-01' },
    { range: 'custom', from: '2026-11-1', to: '2026-11-13' },
    { range: 'custom', from: 20261101, to: '2026-11-13' },
    { range: 'year' },
    {},
  ]) assert('error' in parseBusinessStats(bad));
});
