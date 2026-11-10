import { admin, fail, json, storeFor } from './shared.ts';

export async function handlePackageStats(request: Request): Promise<Response> {
  const storeId = await storeFor(request);
  if (storeId instanceof Response) return storeId;
  const { data, error } = await admin.rpc('merchant_package_stats', { p_store: storeId });
  return error ? fail('读取次卡统计失败', 500) : json({ item: data });
}
