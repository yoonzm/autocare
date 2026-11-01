import { admin, fail, json, nameOf, uuid } from './shared.ts';
import type { CardColor, CardRules, CardTypeRow, CardValidity, Input } from './types.ts';

const COLORS: CardColor[] = ['black', 'champagne', 'silver', 'blue', 'white'];
const VALIDITIES: CardValidity[] = ['forever', '1y', '2y'];
const MAX_MONEY = 99_999_999;

// Optional money amount: null / '' = not set. Returns undefined when invalid.
function money(value: unknown): number | null | undefined {
  if (value == null || value === '') return null;
  const n = Number(value);
  return Number.isFinite(n) && n >= 0 && n <= MAX_MONEY ? Math.round(n * 100) / 100 : undefined;
}

// Validates the optional configuration fields; returns the columns to write
// (only the ones the client sent) or an error message.
function configOf(input: Input): Record<string, unknown> | string {
  const out: Record<string, unknown> = {};
  if (input.color !== undefined) {
    if (!COLORS.includes(input.color as CardColor)) return '卡面颜色无效';
    out.color = input.color;
  }
  for (const [key, label] of [['upgrade_recharge', '单次充值满'], ['upgrade_cumulative', '累计消费满']] as const) {
    if (input[key] === undefined) continue;
    const v = money(input[key]);
    if (v === undefined) return `${label}金额无效`;
    out[key] = v;
  }
  if (input.points_multiplier !== undefined) {
    const m = Number(input.points_multiplier);
    if (!Number.isFinite(m) || m < 0 || m > 10) return '积分倍率无效';
    out.points_multiplier = Math.round(m * 10) / 10;
  }
  if (input.birthday_gift !== undefined) {
    const gift = nameOf(input.birthday_gift);
    if (gift.length > 100) return '生日礼不能超过 100 字';
    out.birthday_gift = gift;
  }
  if (input.priority_booking !== undefined) {
    if (typeof input.priority_booking !== 'boolean') return '预约优先设置无效';
    out.priority_booking = input.priority_booking;
  }
  if (input.validity !== undefined) {
    if (!VALIDITIES.includes(input.validity as CardValidity)) return '有效期无效';
    out.validity = input.validity;
  }
  return out;
}

export async function handleCards(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'list') {
    const { data, error } = await admin.from('card_types').select('*')
      .eq('store_id', storeId).eq('active', true)
      .order('created_at', { ascending: false });
    return error ? fail('读取失败', 500) : json({ items: data as CardTypeRow[] });
  }
  if (input.action === 'rules') {
    const { data, error } = await admin.from('stores')
      .select('card_auto_upgrade, card_balance_refundable').eq('id', storeId).single();
    if (error || !data) return fail('读取失败', 500);
    const rules: CardRules = {
      auto_upgrade: data.card_auto_upgrade,
      balance_refundable: data.card_balance_refundable,
    };
    return json({ rules });
  }
  if (input.action === 'save_rules') {
    if (typeof input.auto_upgrade !== 'boolean' || typeof input.balance_refundable !== 'boolean') {
      return fail('规则设置无效');
    }
    const { error } = await admin.from('stores').update({
      card_auto_upgrade: input.auto_upgrade,
      card_balance_refundable: input.balance_refundable,
    }).eq('id', storeId);
    return error ? fail('保存失败', 400) : json({
      rules: { auto_upgrade: input.auto_upgrade, balance_refundable: input.balance_refundable },
    });
  }
  if (input.action === 'save') {
    const name = nameOf(input.name);
    const discount = Number(input.discount);
    if (!name || name.length > 100) return fail('名称长度须为 1–100 字');
    if (!Number.isFinite(discount) || discount <= 0 || discount > 1) return fail('折扣系数无效');
    if (input.id != null && !uuid(input.id)) return fail('记录 ID 无效');
    const config = configOf(input);
    if (typeof config === 'string') return fail(config);
    const values: Record<string, unknown> = { name, discount, ...config };
    if (input.description !== undefined) values.description = nameOf(input.description);
    const query = input.id == null
      ? admin.from('card_types').insert({ ...values, store_id: storeId })
      : admin.from('card_types').update(values).eq('id', input.id).eq('store_id', storeId);
    const { data, error } = await query.select('*').single();
    return error ? fail('保存失败', 400) : json({ item: data as CardTypeRow });
  }
  if (input.action === 'delete') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    // Existing UI says "停用此卡种"; soft-delete to preserve future member history.
    const { data, error } = await admin.from('card_types').update({ active: false })
      .eq('id', input.id).eq('store_id', storeId).eq('active', true)
      .select('id').maybeSingle();
    return error ? fail('删除失败', 400) : data ? json({ ok: true }) : fail('记录不存在', 404);
  }
  return fail('不支持的操作');
}
