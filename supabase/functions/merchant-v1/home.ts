import { settingsCounts } from "./settings_stats.ts";
import { admin, fail, json, storeFor } from "./shared.ts";

export async function handleHomeStats(request: Request): Promise<Response> {
  const storeId = await storeFor(request);
  if (storeId instanceof Response) return storeId;
  const { data, error } = await admin.rpc("merchant_home_stats", {
    p_store: storeId,
  });
  if (error) return fail("读取首页统计失败", 500);
  const [inventory, options] = await Promise.all([
    admin.rpc("inventory_read", { p_store: storeId }),
    admin.rpc("inventory_options", { p_store: storeId }),
  ]);
  if (inventory.error || options.error) return fail("读取库存提醒失败", 500);
  const items = inventory.data.items as { low: boolean; expiring: boolean }[];
  return json({
    item: {
      ...data,
      stock_low: options.data.settings.home_enabled
        ? items.filter((p) => p.low).length
        : 0,
      stock_expiring: options.data.settings.home_enabled
        ? items.filter((p) => p.expiring).length
        : 0,
    },
  });
}

// The authenticated owner determines the store; never accept a supplied store ID.
export async function handleSettingsStats(request: Request): Promise<Response> {
  const storeId = await storeFor(request);
  if (storeId instanceof Response) return storeId;
  try {
    return json({ item: await settingsCounts(admin, storeId) });
  } catch {
    return fail("读取门店数量失败", 500);
  }
}
