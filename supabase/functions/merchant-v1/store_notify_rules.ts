import type { Input } from './types.ts';

export const STORE_NOTIFY_SETTING_KEYS = [
  'notify_confirm_default',
  'remind_default',
  'notify_manager',
  'notify_reschedule',
  'notify_cancel',
  'notify_consume',
  'notify_recharge',
] as const;

export type StoreNotifySettingKey = (typeof STORE_NOTIFY_SETTING_KEYS)[number];

/** 校验并提取门店通知开关的局部更新字段，至少包含一个合法布尔开关。 */
export function parseStoreNotifySettings(
  input: Input,
): Partial<Record<StoreNotifySettingKey, boolean>> | string {
  const patch: Partial<Record<StoreNotifySettingKey, boolean>> = {};
  let count = 0;
  for (const key of STORE_NOTIFY_SETTING_KEYS) {
    if (!Object.hasOwn(input, key) || input[key] === undefined) continue;
    if (typeof input[key] !== 'boolean') return '通知设置无效';
    patch[key] = input[key] as boolean;
    count++;
  }
  if (count === 0) return '请选择要修改的通知开关';
  return patch;
}
