import {
  maskPhone, newCode, newToken, parseBook, parseCancel, parseCar, parseOrders, parseSlots, parseTab, rpcProblem, sha256,
} from './member_portal_rules.ts';
import { WechatError, wechatClient } from './member_portal_wechat.ts';

const id = 'aaaaaaaa-0000-0000-0000-000000000001';
const assert = (ok: boolean, message = 'assertion failed') => {
  if (!ok) throw new Error(message);
};
const thrown = async (fn: () => Promise<unknown>): Promise<WechatError> => {
  try {
    await fn();
  } catch (e) {
    return e as WechatError;
  }
  throw new Error('expected rejection');
};

Deno.test('booking input: members choose services, time, vehicle and note only', () => {
  const ok = parseBook({
    service_ids: [id, id], starts_at: '2026-11-11T10:00:00+08:00', vehicle_id: id, note: ' 有宠物毛发 ',
    member_id: 'x', bay_id: id, technician_id: id, price: 1, store_id: 'x', estimate: 0,
  }) as unknown as Record<string, unknown>;
  assert(typeof ok === 'object' && (ok.service_ids as string[]).length === 1 && ok.starts_at === '2026-11-11T02:00:00.000Z');
  assert(ok.note === '有宠物毛发' && ok.replace_id === null);
  for (const key of ['member_id', 'bay_id', 'technician_id', 'price', 'store_id', 'estimate']) assert(!(key in ok), key);
  const base = { service_ids: [id], starts_at: '2026-11-11T10:00:00+08:00', vehicle_id: id };
  for (const bad of [
    { ...base, service_ids: [] }, { ...base, service_ids: ['x'] }, { ...base, service_ids: Array(21).fill(id) },
    { ...base, starts_at: '2026-11-11' }, { ...base, starts_at: 'tomorrow' }, { ...base, vehicle_id: 'bad' },
    { ...base, vehicle_id: undefined }, { ...base, note: 'x'.repeat(201) }, { ...base, replace_id: 'bad' },
  ]) assert(typeof parseBook(bad) === 'string', JSON.stringify(bad));
  assert((parseBook({ ...base, replace_id: id }) as { replace_id: string }).replace_id === id);
});

Deno.test('slots, tab, orders and cancel inputs', () => {
  assert(typeof parseSlots({ day: '2026-02-30', service_ids: [id] }) === 'string');
  assert(typeof parseSlots({ day: '2026-11-11', service_ids: [] }) === 'string');
  assert((parseSlots({ day: '2026-11-11', service_ids: [id] }) as { day: string }).day === '2026-11-11');
  assert(parseTab({ tab: 'pending' }) === 'pending' && parseTab({ tab: 'all' }) !== 'all');
  assert(typeof parseOrders({ kind: 'refund' }) === 'string' && typeof parseOrders({ before: 'x' }) === 'string');
  assert((parseOrders({}) as { kind: string }).kind === 'all');
  assert(typeof parseCancel({ id, reason: '随便' }) === 'string' && typeof parseCancel({ id: 'x', reason: '时间有变' }) === 'string');
  assert((parseCancel({ id, reason: '已在别处完成' }) as { reason: string }).reason === '已在别处完成');
});

Deno.test('vehicle input reuses merchant plate rules and requires a model', () => {
  const ok = parseCar({ plate: '沪a·8k29m', brand_model: '宝马 5 系', color: '黑色', is_default: true }) as Record<string, any>;
  assert(ok.values.plate === '沪A8K29M' && ok.values.energy === 'fuel' && ok.is_default === true);
  const ev = parseCar({ plate: '沪AF09316', brand_model: '理想 L7' }) as Record<string, any>;
  assert(ev.values.energy === 'ev' && ev.is_default === false);
  for (const bad of [{ plate: '12345', brand_model: 'x' }, { plate: '沪A8K29M' }, { plate: '沪A8K29M', brand_model: 'x'.repeat(51) },
    { plate: '沪AF09316', energy: 'fuel', brand_model: 'x' }]) assert(typeof parseCar(bad) === 'string', JSON.stringify(bad));
  assert(!('vin' in ok.values) && !('mileage' in ok.values));
});

Deno.test('tokens, codes and hashing', async () => {
  const t = newToken();
  assert(/^[A-Za-z0-9_-]{43}$/.test(t) && t !== newToken());
  assert(/^[A-HJ-NP-Z2-9]{20}$/.test(newCode()));
  assert(await sha256('abc') === 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
  assert(maskPhone('13800006021') === '138 **** 6021' && maskPhone('123') === '');
});

Deno.test('database errors become member-facing messages without leaking details', () => {
  assert(rpcProblem({ message: 'slot_unavailable' }).status === 409);
  assert(rpcProblem({ message: 'cancel_too_late' }).message.includes('2 小时'));
  assert(rpcProblem({ message: 'x', code: '23505' }).status === 409);
  const unknown = rpcProblem({ message: 'relation "members" does not exist: secret' });
  assert(unknown.status === 500 && !unknown.message.includes('secret'));
});

const env = (v: Record<string, string>) => (k: string) => v[k];
const reply = (body: unknown, ok = true) => new Response(JSON.stringify(body), { status: ok ? 200 : 500 });

Deno.test('wechat client: missing configuration is 501, never a fake login', async () => {
  for (const e of [{}, { WECHAT_MINI_APPID: 'wx1' }, { WECHAT_MINI_SECRET: 's' }] as Record<string, string>[]) {
    try {
      wechatClient(env(e));
      throw new Error('should throw');
    } catch (err) {
      assert(err instanceof WechatError && err.status === 501);
    }
  }
});

Deno.test('wechat client: openid and phone exchange, token refresh, rejections', async () => {
  const calls: string[] = [];
  let tokenIssued = 0;
  let stale = true;
  const fetcher = (async (url: string, init?: RequestInit) => {
    calls.push(String(url));
    if (url.includes('/cgi-bin/token')) {
      tokenIssued++;
      return reply({ access_token: `tok${tokenIssued}`, expires_in: 7200 });
    }
    if (url.includes('jscode2session')) return reply(url.includes('badcode0') ? { errcode: 40029 } : { openid: 'oXYZ123456', session_key: 'sk' });
    if (url.includes('getuserphonenumber')) {
      const code = JSON.parse(String(init?.body)).code;
      if (stale && url.includes('tok1')) {
        stale = false;
        return reply({ errcode: 42001 });
      }
      if (code === 'foreign00') return reply({ errcode: 0, phone_info: { purePhoneNumber: '4155550100', countryCode: '1' } });
      if (code === 'denied000') return reply({ errcode: 40029 });
      return reply({ errcode: 0, phone_info: { purePhoneNumber: '13800006021', countryCode: '86' } });
    }
    return reply({}, false);
  }) as unknown as typeof fetch;
  const client = wechatClient(env({ WECHAT_MINI_APPID: 'wxappid', WECHAT_MINI_SECRET: 'topsecret' }), fetcher, () => 1_000_000);
  assert(await client.openid('goodcode1') === 'oXYZ123456');
  const bad = await thrown(() => client.openid('badcode0'));
  assert(bad.status === 400 && !bad.message.includes('topsecret'));
  assert(await client.phone('phonecode') === '13800006021', 'stale token is refreshed once');
  assert(tokenIssued === 2, `token requests ${tokenIssued}`);
  assert((await thrown(() => client.phone('foreign00'))).message.includes('大陆'));
  assert((await thrown(() => client.phone('denied000'))).status === 400);
  assert((await thrown(() => client.phone('x'))).status === 400, 'malformed code rejected before any request');
  assert(await client.phone('phonecode') === '13800006021' && tokenIssued === 2, 'token is cached');
  const down = wechatClient(env({ WECHAT_MINI_APPID: 'wxa', WECHAT_MINI_SECRET: 'sec' }), (() => Promise.reject(new Error('net topsecret'))) as unknown as typeof fetch);
  const e = await thrown(() => down.openid('goodcode1'));
  assert(e.status === 502 && !e.message.includes('topsecret'));
});
