import { admin, fail, json } from './shared.ts';
import { checkOtp, otpHash, otpStore, randomOtp } from './otp.ts';
import { sendOtp, SmsError, smsProvider } from './sms.ts';
import { maskPhone } from './staff_member_rules.ts';
import { isUuid, parseRedeem, parseStaffLines, parseStaffOrder } from './staff_order_rules.ts';

const messages: Record<string, string> = {
  staff_not_found: '员工不存在或已停用',
  member_not_found: '会员不存在',
  service_not_found: '服务项目不存在或已下架',
  hold_not_found: '这张待收银单不存在或已处理',
  no_items: '请先选择服务项目',
  package_not_enough: '次卡不可用或次数不够',
  bad_qty: '核销次数无效',
};
const rpcError = (e: { message: string; code?: string }) => {
  const key = Object.keys(messages).find((k) => e.message.includes(k));
  if (key) return fail(messages[key], e.code === 'P0002' ? 404 : 400);
  return fail('操作失败，请稍后重试', 500);
};

const QUEUE_SELECT =
  '*, items:held_order_items(position, service_id, name, qty, member_package_id), ' +
  'member:members(id, name, phone, balance, card:card_types(name, discount)), submitter:store_staff(name, role)';

/**
 * 员工端开单 / 待收银队列 / 次卡核销。权限由 staff_gate 先校验；这里只接受已识别的员工身份，
 * 数据范围固定为当前身份所在门店。次卡核销需要会员本人的短信验证码确认。
 */
export async function handleStaffOrders(
  input: Record<string, unknown>,
  store: string,
  staff: string,
): Promise<Response> {
  const action = String(input.action);
  const { data: me } = await admin.from('store_staff').select('name, role').eq('id', staff).eq('store_id', store).maybeSingle();
  const operator = me ? `${me.name}` : '员工';
  try {
    if (action === 'staff_order_quote') {
      if (!isUuid(input.member_id)) return fail('请先选择会员');
      const lines = parseStaffLines(input.lines);
      if (typeof lines === 'string') return fail(lines);
      const { data, error } = await admin.rpc('quote_order', { p_store: store, p_member: input.member_id, p_lines: lines });
      return error ? rpcError(error) : json({ item: data } as never);
    }
    if (action === 'staff_order_submit') {
      const v = parseStaffOrder(input);
      if (typeof v === 'string') return fail(v);
      const { data, error } = await admin.rpc('staff_order_submit', {
        p_store: store, p_staff: staff, p_member: v.member_id, p_lines: v.lines, p_plate: v.plate, p_note: v.note,
      });
      return error ? rpcError(error) : json({ item: { id: data } } as never);
    }
    if (action === 'staff_cash_queue') {
      const { data, error } = await admin.from('held_orders').select(QUEUE_SELECT)
        .eq('store_id', store).not('submitted_by', 'is', null).is('settled_at', null).is('cancelled_at', null)
        .order('created_at', { ascending: false }).limit(50);
      if (error) return fail('读取失败，请稍后重试', 500);
      type Item = { service_id: string | null; name: string; qty: number; member_package_id: string | null };
      const rows = (data ?? []) as unknown as { id: string; member_id: string; items: Item[]; member: { phone?: string } | null }[];
      const ids = [...new Set(rows.flatMap((r) => r.items.map((i) => i.service_id).filter((x): x is string => !!x)))];
      const { data: prices } = ids.length
        ? await admin.from('service_items').select('id, price').eq('store_id', store).in('id', ids)
        : { data: [] as { id: string; price: number }[] };
      const priceOf = new Map((prices ?? []).map((p) => [p.id as string, Number(p.price)]));
      // 价格 / 折扣 / 次卡抵扣由数据库估价（与取单结算同一套算法），客户端只展示。
      const items = await Promise.all(rows.map(async (r) => {
        const lines = r.items.filter((i) => i.service_id).map((i) => ({
          service_id: i.service_id, qty: i.qty, ...(i.member_package_id ? { member_package_id: i.member_package_id } : {}),
        }));
        const { data: quote } = await admin.rpc('quote_order', { p_store: store, p_member: r.member_id, p_lines: lines });
        return {
          ...r,
          // 前台只看到脱敏手机号；取单结算用会员 ID。
          member: r.member ? { ...r.member, phone: maskPhone(r.member.phone) } : r.member,
          lines: r.items.map((i) => ({ name: i.name, qty: i.qty, unit_price: priceOf.get(i.service_id ?? '') ?? 0 })),
          quote: quote ?? null,
        };
      }));
      return json({ item: { items } } as never);
    }
    if (action === 'staff_order_return') {
      if (!isUuid(input.id)) return fail('待收银单无效');
      const reason = typeof input.reason === 'string' ? input.reason.trim().slice(0, 100) : '';
      const { error } = await admin.rpc('staff_order_return', { p_store: store, p_hold: input.id, p_reason: reason });
      return error ? rpcError(error) : json({ item: { ok: true } } as never);
    }
    if (action === 'staff_redeem_send') {
      if (!isUuid(input.member_id)) return fail('请先选择会员');
      const { data: m } = await admin.from('members').select('phone').eq('id', input.member_id)
        .eq('store_id', store).is('deleted_at', null).maybeSingle();
      if (!m) return fail('会员不存在', 404);
      const phone = `+86${m.phone}`;
      try {
        const provider = smsProvider((name) => Deno.env.get(name), 'redeem');
        const code = randomOtp();
        const sent = await sendOtp(provider, otpStore, {
          phone, purpose: 'redeem', code, hash: await otpHash(phone, 'redeem', code), requestId: crypto.randomUUID(),
        });
        return json({ item: sent } as never);
      } catch (e) {
        return e instanceof SmsError ? fail(e.message, e.status) : fail('短信暂时不可用，请稍后重试', 503);
      }
    }
    if (action === 'staff_redeem') {
      const v = parseRedeem(input);
      if (typeof v === 'string') return fail(v);
      const { data: m } = await admin.from('members').select('phone').eq('id', v.member_id)
        .eq('store_id', store).is('deleted_at', null).maybeSingle();
      if (!m) return fail('会员不存在', 404);
      // 会员本人确认：验证码发送到会员登记的手机号，校验通过即原子消费，不能重复使用。
      const problem = await checkOtp(`+86${m.phone}`, v.code, 'redeem', true);
      if (problem) return fail(problem);
      const { data, error } = await admin.rpc('staff_redeem_package', {
        p_store: store, p_member: v.member_id, p_member_package: v.member_package_id, p_service: v.service_id,
        p_qty: v.qty, p_plate: v.plate, p_operator: operator,
      });
      return error ? rpcError(error) : json({ item: data } as never);
    }
    return fail('不支持的员工操作');
  } catch (e) {
    return rpcError(e as { message: string; code?: string });
  }
}
