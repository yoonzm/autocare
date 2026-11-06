import { sendOtp, smsProvider, SmsError, type OtpSendStore } from './sms.ts';
import { zhutongProvider } from './sms_zhutong.ts';
import type { SmsProvider } from './sms_types.ts';

const eq = (a: unknown, b: unknown) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`Expected ${JSON.stringify(b)}, got ${JSON.stringify(a)}`);
};
const config: Record<string, string> = {
  SMS_PROVIDER: 'zhutong', ZHUTONG_USERNAME: 'test-account', ZHUTONG_PASSWORD: 'test-password',
  ZHUTONG_SIGN_NAME: '测试签名', ZHUTONG_TEMPLATE_REGISTER: '485812',
};
const env = (name: string) => config[name];
const request = { phone: '+8613900000000', purpose: 'register' as const, code: '123456', hash: 'hash', requestId: 'request' };
const fakeStore = (events: unknown[], reservation = {}): OtpSendStore => ({
  reserve: (value) => {
    if ('code' in value) throw new Error('Plain OTP reached storage reservation');
    events.push('reserve'); return Promise.resolve(reservation);
  },
  finish: (_phone, _purpose, _id, sent, provider) => { events.push({ sent, provider }); return Promise.resolve(); },
});
async function rejects(action: () => Promise<unknown>, status: number) {
  try { await action(); } catch (e) {
    if (!(e instanceof SmsError) || e.status !== status) throw e;
    if (e.message.includes('test-password')) throw new Error('Credential leaked');
    return;
  }
  throw new Error('Expected rejection');
}

Deno.test('zhutong v2 template request uses timestamp signing and a national mobile number', async () => {
  let count = 0;
  const fetcher: typeof fetch = (_url, options) => {
    count++;
    eq(_url, 'https://api-shss.zthysms.com/v2/sendSmsTp');
    const body = JSON.parse(String(options?.body));
    eq(body, {
      username: 'test-account', password: 'c6db59d585fe802fdc77e9d1d0e71384', signature: '【测试签名】', tKey: '1700000000',
      tpId: '485812', records: [{ mobile: '13900000000', tpContent: { code: '123456' } }],
    });
    eq(options?.redirect, 'error');
    return Promise.resolve(Response.json({ code: 200 }));
  };
  await zhutongProvider(env, 'register', fetcher, () => 1700000000000).sendCode(request.phone, request.code, 'register');
  eq(count, 1);
});

Deno.test('zhutong rejects HTTP failure, invalid JSON, rejection codes and ambiguous network errors without retry', async () => {
  for (const response of [Response.json({ code: 200 }, { status: 500 }), Response.json({ code: 1000 }), Response.json({ code: '200' }), new Response('not JSON')]) {
    await rejects(() => zhutongProvider(env, 'register', () => Promise.resolve(response)).sendCode(request.phone, request.code, 'register'), 502);
  }
  let calls = 0;
  await rejects(() => zhutongProvider(env, 'register', () => {
    calls++;
    return Promise.reject(new Error('secret test-password'));
  }).sendCode(request.phone, request.code, 'register'), 502);
  eq(calls, 1);
});

Deno.test('channel selection requires a configured real provider and the requested template', () => {
  for (const values of [{}, { SMS_PROVIDER: 'unknown' }, { SMS_PROVIDER: '__proto__' }, { SMS_PROVIDER: 'zhutong' }]) {
    let failed = false;
    try { smsProvider(name => (values as Record<string, string>)[name], 'register'); }
    catch (e) { failed = e instanceof SmsError && e.status === 501; }
    eq(failed, true);
  }
  eq(smsProvider(env, 'register').name, 'zhutong');
});

Deno.test('real sends reserve first, become usable only after provider success, and never return OTPs', async () => {
  const events: unknown[] = [];
  const provider: SmsProvider = { name: 'zhutong', sendCode: () => { events.push('send'); return Promise.resolve(); } };
  const result = await sendOtp(provider, fakeStore(events), request);
  eq(events, ['reserve', 'send', { sent: true, provider: 'zhutong' }]);
  eq(result, { ok: true, retry_after: 60, expires_in: 300 });
});

Deno.test('quota denial prevents paid sends and delivery failure cannot activate a code', async () => {
  const events: unknown[] = [];
  const provider: SmsProvider = { name: 'zhutong', sendCode: () => { events.push('send'); return Promise.reject(new SmsError('拒绝')); } };
  await rejects(() => sendOtp(provider, fakeStore(events, { error: 'cooldown', retry_after: 45 }), request), 429);
  eq(events, ['reserve']);
  events.length = 0;
  await rejects(() => sendOtp(provider, fakeStore(events), request), 502);
  eq(events, ['reserve', 'send', { sent: false, provider: 'zhutong' }]);
});

Deno.test('database finalization failure is not reported as send success', async () => {
  const events: unknown[] = [];
  const provider: SmsProvider = { name: 'zhutong', sendCode: () => Promise.resolve() };
  let failed = false;
  try {
    await sendOtp(provider, { ...fakeStore(events), finish: () => Promise.reject(new Error('database unavailable')) }, request);
  } catch { failed = true; }
  eq(failed, true);
});
