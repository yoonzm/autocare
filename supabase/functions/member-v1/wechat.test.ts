import { WechatError, wechatClient } from './wechat.ts';

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
