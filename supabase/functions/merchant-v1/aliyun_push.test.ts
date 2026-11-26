import { pushIosNotice, readAliyunPushConfig, signAcs3Post } from './aliyun_push.ts';
import { validatePushDeviceInput } from './push_rules.ts';

function assert(cond: unknown, msg: string) {
  if (!cond) throw new Error(msg);
}

Deno.test('readAliyunPushConfig returns null when required env missing', () => {
  assert(readAliyunPushConfig(() => undefined) === null, 'expected null when env empty');
  const cfg = readAliyunPushConfig((k) => ({
    ALIYUN_ACCESS_KEY_ID: 'ak-id',
    ALIYUN_ACCESS_KEY_SECRET: 'ak-sec',
    ALIYUN_PUSH_IOS_APP_KEY: '123456',
    ALIYUN_PUSH_IOS_APNS_ENV: 'dev',
  }[k]));
  assert(cfg !== null, 'expected config');
  assert(cfg!.iosApnsEnv === 'DEV', 'expected DEV env');
  assert(cfg!.endpoint === 'https://cloudpush.aliyuncs.com', 'expected official service endpoint');
});

Deno.test('signAcs3Post builds ACS3-HMAC-SHA256 authorization header', async () => {
  const headers = await signAcs3Post({
    endpoint: 'https://cloudpush.aliyuncs.com',
    action: 'Push',
    version: '2016-08-01',
    accessKeyId: 'test-ak',
    accessKeySecret: 'test-secret',
    body: 'AppKey=123&PushType=NOTICE',
    date: '2026-11-26T00:00:00Z',
    nonce: 'nonce-1',
  });
  assert(headers['x-acs-action'] === 'Push', 'expected action header');
  assert(headers.Authorization.startsWith('ACS3-HMAC-SHA256 Credential=test-ak,'), 'expected ACS3 header');
  assert(/Signature=[0-9a-f]{64}$/.test(headers.Authorization), 'expected 64-char hex signature');
});

Deno.test('pushIosNotice sends message_id only in iOSExtParameters', async () => {
  let capturedBody = '';
  const res = await pushIosNotice({
    config: {
      accessKeyId: 'ak',
      accessKeySecret: 'sec',
      iosAppKey: '99999',
      iosApnsEnv: 'PRODUCT',
      endpoint: 'https://cloudpush.aliyuncs.com',
    },
    deviceTokens: ['dev-token-1'],
    title: '新任务派给你',
    body: '粤A12345 洗车',
    messageId: '11111111-1111-1111-1111-111111111111',
    fetcher: async (_url, init) => {
      capturedBody = String(init?.body ?? '');
      return new Response(JSON.stringify({ MessageId: 'm-1' }), { status: 200 });
    },
  });
  assert(res.ok && res.messageId === 'm-1', 'expected ok response');
  const params = new URLSearchParams(capturedBody);
  assert(params.get('DeviceType') === 'iOS', 'expected iOS');
  assert(params.get('Target') === 'DEVICE', 'expected DEVICE target');
  assert(params.get('iOSExtParameters') === '{"message_id":"11111111-1111-1111-1111-111111111111"}', 'expected message_id ext param');
});

Deno.test('validatePushDeviceInput rejects invalid platform or short token', () => {
  assert(typeof validatePushDeviceInput({ platform: 'web', token: '12345678' }) === 'string', 'reject web');
  assert(typeof validatePushDeviceInput({ platform: 'ios', token: 'short' }) === 'string', 'reject short');
  const ok = validatePushDeviceInput({ platform: 'ios', token: 'device-id-123456' });
  assert(typeof ok === 'object' && ok.platform === 'ios', 'accept valid ios');
});
