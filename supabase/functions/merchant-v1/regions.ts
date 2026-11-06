import { admin, fail, json } from './shared.ts';
import { cityProfile } from './region_rules.ts';
import type { Input } from './types.ts';

// Public read-only dictionary: also needed before a merchant has registered.
export async function handleRegions(input: Input): Promise<Response> {
  const { data, error } = await admin.rpc('region_dictionary');
  if (error || !data) return fail('地区数据加载失败，请稍后重试', 500);
  if (input.version === data.version) return json({ version: data.version, unchanged: true });
  return json(data);
}

export async function registrationCity(input: Input) {
  if (typeof input.province_code !== 'string' || typeof input.city_code !== 'string' ||
      input.province_code.length > 20 || input.city_code.length > 20) {
    return fail('请选择所在省份和城市');
  }
  const { data, error } = await admin.from('regions').select('code,name,parent_code,level')
    .in('code', [input.province_code, input.city_code]).eq('active', true);
  if (error) return fail('地区校验失败，请稍后重试', 500);
  return cityProfile(data ?? [], input.province_code, input.city_code) ??
    fail('所选省份和城市无效，请重新选择');
}
