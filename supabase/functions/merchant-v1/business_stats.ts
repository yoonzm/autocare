import { admin, fail, json, storeFor } from './shared.ts';
import { parseBusinessStats } from './business_stats_rules.ts';
import type { Input } from './types.ts';

export async function handleBusinessStats(input: Input, request: Request): Promise<Response> {
  const parsed = parseBusinessStats(input);
  if ('error' in parsed) return fail(parsed.error);
  const storeId = await storeFor(request);
  if (storeId instanceof Response) return storeId;
  const { data, error } = await admin.rpc('merchant_business_stats', {
    p_store: storeId,
    p_range: parsed.range,
    p_from: parsed.from,
    p_to: parsed.to,
  });
  if (error?.code === '22023') return fail('统计时间范围无效，起止日期不能晚于今天，最长一年');
  return error ? fail('读取营业统计失败', 500) : json({ item: data });
}
