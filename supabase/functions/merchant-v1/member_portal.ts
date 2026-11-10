// 会员端小程序接口（action 前缀 mb_）。
// 身份：微信手机号授权 -> 会员会话令牌（x-member-token，库里只存哈希）。会员 = 门店下以手机号识别的 members 记录；
// 门店、会员身份、价格、工位 / 技师、预约规则全部在服务端决定，客户端只提交选择。所有查询都先校验“该手机号是该门店会员”。
import { admin, fail, json, uuid } from './shared.ts';
import { RECHARGE_PRESETS } from './member_rules.ts';
import {
  CANCEL_LEAD_HOURS, CODE_PREFIX, CODE_SECONDS, isId, maskPhone, needsPayment, newCode, newToken, parseBook, parseCancel,
  parseCar, parseOrders, parseSlots, parseStoreId, parseTab, rpcProblem, sha256,
} from './member_portal_rules.ts';
import { WechatError, wechatClient } from './member_portal_wechat.ts';
import type { Input } from './types.ts';

const TOKEN = /^[A-Za-z0-9_-]{40,64}$/;
type Rpc = { data: unknown; error: { message?: string; code?: string } | null };
const rpcResponse = (r: Rpc, key = 'item') => {
  if (r.error) {
    const p = rpcProblem(r.error);
    return fail(p.message, p.status);
  }
  return json({ [key]: r.data } as never);
};

async function session(request: Request): Promise<{ phone: string; hash: string } | Response> {
  const token = request.headers.get('x-member-token') ?? '';
  if (!TOKEN.test(token)) return fail('请先登录', 401);
  const hash = await sha256(token);
  const { data, error } = await admin.rpc('member_portal_session', { p_hash: hash });
  if (error) return fail('登录状态校验失败，请稍后重试', 503);
  if (!data || typeof data.phone !== 'string') return fail('登录已过期，请重新登录', 401);
  return { phone: data.phone, hash };
}

export async function handleMemberPortal(input: Input, request: Request): Promise<Response> {
  const action = String(input.action);
  if (action === 'mb_login') return login(input);

  const auth = await session(request);
  if (auth instanceof Response) return auth;
  if (action === 'mb_logout') {
    await admin.rpc('member_portal_logout', { p_hash: auth.hash });
    return json({ ok: true });
  }
  if (action === 'mb_stores') {
    return rpcResponse(await admin.rpc('member_portal_stores', { p_phone: auth.phone }), 'items');
  }
  // TODO mb_notices: 会员消息通知依赖微信订阅消息 / 短信通知渠道（见 docs/member-mini-integration.md），目前没有消息数据来源，返回空列表。
  if (action === 'mb_notices') return json({ items: [] });

  const store = parseStoreId(input);
  if (!uuid(store)) return fail(store);
  const { data: member } = await admin.rpc('member_portal_resolve', { p_phone: auth.phone, p_store: store });
  if (typeof member !== 'string') return fail('您还不是该门店会员，请联系门店办理', 403);

  try {
    switch (action) {
      case 'mb_overview':
        return rpcResponse(await admin.rpc('member_portal_overview', { p_store: store, p_member: member }));
      case 'mb_services':
        return await services(store, member);
      case 'mb_slots':
        return await slots(input, store, member);
      case 'mb_book': {
        const v = parseBook(input);
        if (typeof v === 'string') return fail(v);
        const requestId = request.headers.get('x-request-id');
        if (!requestId || requestId.length > 100) return fail('请求标识缺失，请重试');
        return rpcResponse(await admin.rpc('member_portal_book', {
          p_store: store, p_member: member, p_vehicle: v.vehicle_id, p_request: requestId, p_replace: v.replace_id,
          p_input: { starts_at: v.starts_at, service_ids: v.service_ids, note: v.note },
        }));
      }
      case 'mb_appointments': {
        const tab = parseTab(input);
        if (tab !== 'pending' && tab !== 'done' && tab !== 'cancelled') return fail(tab);
        return rpcResponse(await admin.rpc('member_portal_appointments', { p_store: store, p_member: member, p_tab: tab }));
      }
      case 'mb_appointment':
        if (!isId(input.id)) return fail('预约无效');
        return rpcResponse(await admin.rpc('member_portal_appointment', { p_store: store, p_member: member, p_id: input.id }));
      case 'mb_cancel': {
        const v = parseCancel(input);
        if (typeof v === 'string') return fail(v);
        return rpcResponse(await admin.rpc('member_portal_cancel', {
          p_store: store, p_member: member, p_id: v.id, p_reason: v.reason,
        }));
      }
      case 'mb_vehicles':
        return rpcResponse(await admin.rpc('member_portal_vehicles', { p_store: store, p_member: member }), 'items');
      case 'mb_vehicle_save': {
        const v = parseCar(input);
        if (typeof v === 'string') return fail(v);
        return rpcResponse(await admin.rpc('member_portal_save_vehicle', {
          p_store: store, p_member: member, p_values: v.values, p_default: v.is_default,
        }));
      }
      case 'mb_card':
        return await card(store);
      case 'mb_code': {
        const code = newCode();
        const r = await admin.rpc('member_portal_issue_code', {
          p_store: store, p_member: member, p_hash: await sha256(code), p_seconds: CODE_SECONDS,
        });
        if (r.error) return rpcResponse(r);
        return json({ item: { code: CODE_PREFIX + code, ttl: CODE_SECONDS, expires_at: (r.data as { expires_at: string }).expires_at } });
      }
      case 'mb_orders': {
        const v = parseOrders(input);
        if (typeof v === 'string') return fail(v);
        return rpcResponse(await admin.rpc('member_portal_orders', {
          p_store: store, p_member: member, p_kind: v.kind, p_before: v.before,
        }));
      }
      case 'mb_order':
        if (!isId(input.id)) return fail('订单无效');
        return rpcResponse(await admin.rpc('member_portal_order', { p_store: store, p_member: member, p_id: input.id }));
      case 'mb_recharge_detail':
        if (!isId(input.id)) return fail('记录无效');
        return rpcResponse(await admin.rpc('member_portal_recharge', { p_store: store, p_member: member, p_id: input.id }));
      case 'mb_packages':
        return rpcResponse(await admin.rpc('member_portal_packages', { p_store: store, p_member: member }));
      case 'mb_recharge_options':
        // 档位与赠送沿用商户端规则；线上支付未接通（online=false），小程序据此禁用支付并提示。
        return json({ item: { presets: RECHARGE_PRESETS.map((p) => ({ ...p })), online: false } });
      // TODO mb_recharge / mb_package_buy: 储值充值与次卡购买需要微信支付商户号（服务商进件，见 docs/backend-integration.md）与支付回调
      // `payment_create` / `payment_callback`。支付未接通前明确拒绝，不创建订单、不入账、不返回成功。
      case 'mb_recharge':
      case 'mb_package_buy':
        return fail(needsPayment, 501);
      default:
        return fail('不支持的会员端操作');
    }
  } catch (e) {
    const p = rpcProblem(e as { message?: string; code?: string });
    return fail(p.message, p.status);
  }
}

async function login(input: Input): Promise<Response> {
  if (typeof input.login_code !== 'string' || typeof input.phone_code !== 'string') return fail('请完成微信授权');
  try {
    const wechat = wechatClient((name) => Deno.env.get(name));
    // 两个一次性凭证分别换 openid 和手机号；任何一步失败都不签发会话。
    const openid = await wechat.openid(input.login_code);
    const phone = await wechat.phone(input.phone_code);
    const token = newToken();
    const { data, error } = await admin.rpc('member_portal_login', {
      p_phone: phone, p_openid: openid, p_hash: await sha256(token), p_days: 30,
    });
    if (error) return fail('登录失败，请稍后重试', 500);
    return json({ item: { token, phone, masked_phone: maskPhone(phone), expires_at: data.expires_at } });
  } catch (e) {
    if (e instanceof WechatError) return fail(e.message, e.status);
    return fail('登录失败，请稍后重试', 500);
  }
}

async function discountOf(store: string, member: string): Promise<number> {
  const { data } = await admin.from('members').select('card_types(discount)')
    .eq('id', member).eq('store_id', store).maybeSingle();
  const d = Number((data as { card_types?: { discount?: number } } | null)?.card_types?.discount ?? 1);
  return d > 0 && d <= 1 ? d : 1;
}

async function services(store: string, member: string): Promise<Response> {
  const discount = await discountOf(store, member);
  const { data, error } = await admin.from('service_items')
    .select('id,name,category,description,price,duration_minutes')
    .eq('store_id', store).eq('active', true).order('created_at');
  if (error) return fail('读取服务项目失败', 500);
  const items = (data ?? []).map((s) => ({
    ...s, member_price: Math.round(Number(s.price) * discount * 100) / 100,
  }));
  return json({ item: { discount, categories: [...new Set(items.map((s) => s.category))], items } });
}

async function slots(input: Input, store: string, member: string): Promise<Response> {
  const v = parseSlots(input);
  if (typeof v === 'string') return fail(v);
  const { error: seed } = await admin.from('appointment_settings')
    .upsert({ store_id: store }, { onConflict: 'store_id', ignoreDuplicates: true });
  if (seed) return fail('读取可约时段失败', 500);
  const [settings, result, discount, svc] = await Promise.all([
    admin.from('appointment_settings').select('opens_at,closes_at,slot_minutes,advance_days,closed_days,lead_hours').eq('store_id', store).single(),
    admin.rpc('appointment_slots', { p_store: store, p_day: v.day, p_services: v.service_ids }),
    discountOf(store, member),
    admin.from('service_items').select('price').eq('store_id', store).eq('active', true).in('id', v.service_ids),
  ]);
  if (result.error) return rpcResponse(result);
  if (settings.error) return fail('读取可约时段失败', 500);
  const estimate = Math.round((svc.data ?? []).reduce((s, x) => s + Number(x.price), 0) * discount * 100) / 100;
  return json({ item: { ...result.data, estimate, settings: settings.data, cancel_lead_hours: CANCEL_LEAD_HOURS } });
}

async function card(store: string): Promise<Response> {
  const { data, error } = await admin.from('card_types')
    .select('id,name,discount,color,upgrade_recharge,upgrade_cumulative,points_multiplier,birthday_gift,priority_booking')
    .eq('store_id', store).eq('active', true);
  if (error) return fail('读取会员权益失败', 500);
  const rank = (t: { upgrade_recharge: number | null; upgrade_cumulative: number | null }) =>
    Number(t.upgrade_recharge ?? 0) * 1_000_000 + Number(t.upgrade_cumulative ?? 0);
  const tiers = (data ?? []).sort((a, b) => rank(a) - rank(b));
  return json({ item: { tiers } });
}

