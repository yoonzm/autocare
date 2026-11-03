import { admin, fail, json, storeFor } from './shared.ts';

export async function handleHomeStats(request: Request): Promise<Response> {
  const storeId = await storeFor(request);
  if (storeId instanceof Response) return storeId;
  const { data, error } = await admin.rpc('merchant_home_stats', { p_store: storeId });
  return error ? fail('读取首页统计失败', 500) : json({ item: data });
}
