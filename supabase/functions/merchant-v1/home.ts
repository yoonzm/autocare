import { settingsCounts } from './settings_stats.ts';
import { storeDirectory } from './store_directory.ts';
import { admin, fail, json, storeFor, userFor } from './shared.ts';

export async function handleHomeStats(request: Request): Promise<Response> {
  const storeId = await storeFor(request);
  if (storeId instanceof Response) return storeId;
  const { data, error } = await admin.rpc('merchant_home_stats', { p_store: storeId });
  return error ? fail('读取首页统计失败', 500) : json({ item: data });
}

// The authenticated owner determines the store; never accept a supplied store ID.
export async function handleSettingsStats(request: Request): Promise<Response> {
  const storeId = await storeFor(request);
  if (storeId instanceof Response) return storeId;
  try {
    return json({ item: await settingsCounts(admin, storeId) });
  } catch {
    return fail('读取门店数量失败', 500);
  }
}

export async function handleStoreDirectory(request: Request): Promise<Response> {
  const auth = await userFor(request);
  if ('response' in auth) return auth.response;
  try {
    return json({ item: await storeDirectory(admin, auth.user.id) });
  } catch {
    return fail('读取门店列表或营业额失败，请重试', 500);
  }
}
