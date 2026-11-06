import { cityProfile, type Region } from './region_rules.ts';
const rows: Region[] = [
  { code: '330000', name: '浙江省', parent_code: null, level: 1 },
  { code: '330100', name: '杭州市', parent_code: '330000', level: 2 },
  { code: '330106', name: '西湖区', parent_code: '330100', level: 3 },
  { code: '320100', name: '南京市', parent_code: '320000', level: 2 },
];
Deno.test('registration saves canonical province/city names and codes', () => {
  const profile = cityProfile(rows, '330000', '330100');
  if (profile?.city !== '浙江省 · 杭州市' || profile.city_code !== '330100') throw Error('bad profile');
});
Deno.test('reject cross-province, district, missing and invalid codes', () => {
  for (const city of ['320100', '330106', 'unknown', null, 330100]) {
    if (cityProfile(rows, '330000', city) !== null) throw Error(`accepted ${city}`);
  }
  if (cityProfile(rows, '330100', '330106') !== null) throw Error('accepted wrong levels');
});
