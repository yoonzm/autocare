const encoder = new TextEncoder();

function toHex(bytes: ArrayBuffer | Uint8Array): string {
  const arr = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
  return Array.from(arr, (b) => b.toString(16).padStart(2, '0')).join('');
}

async function sha256Hex(text: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', encoder.encode(text));
  return toHex(digest);
}

async function hmacSha256Hex(secret: string, data: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const sig = await crypto.subtle.sign('HMAC', key, encoder.encode(data));
  return toHex(sig);
}

export interface AliyunPushConfig {
  accessKeyId: string;
  accessKeySecret: string;
  iosAppKey: string;
  iosApnsEnv: 'PRODUCT' | 'DEV';
  endpoint: string;
}

export function readAliyunPushConfig(
  env: (name: string) => string | undefined,
): AliyunPushConfig | null {
  const accessKeyId = env('ALIYUN_ACCESS_KEY_ID')?.trim() ?? '';
  const accessKeySecret = env('ALIYUN_ACCESS_KEY_SECRET')?.trim() ?? '';
  const iosAppKey = env('ALIYUN_PUSH_IOS_APP_KEY')?.trim() ?? '';
  if (!accessKeyId || !accessKeySecret || !iosAppKey) return null;
  const rawEnv = (env('ALIYUN_PUSH_IOS_APNS_ENV')?.trim() ?? 'PRODUCT').toUpperCase();
  const iosApnsEnv = rawEnv === 'DEV' ? 'DEV' : 'PRODUCT';
  const endpoint = (env('ALIYUN_PUSH_ENDPOINT')?.trim() || 'https://cloudpush.aliyuncs.com').replace(/\/+$/, '');
  return { accessKeyId, accessKeySecret, iosAppKey, iosApnsEnv, endpoint };
}

export async function signAcs3Post(params: {
  endpoint: string;
  action: string;
  version: string;
  accessKeyId: string;
  accessKeySecret: string;
  body: string;
  date?: string;
  nonce?: string;
}): Promise<Record<string, string>> {
  const host = new URL(params.endpoint).host;
  const date = params.date ?? new Date().toISOString().replace(/\.\d{3}Z$/, 'Z');
  const nonce = params.nonce ?? crypto.randomUUID();
  const payloadHash = await sha256Hex(params.body);

  const signedHeaders = 'host;x-acs-action;x-acs-content-sha256;x-acs-date;x-acs-signature-nonce;x-acs-version';
  const canonicalHeaders =
    `host:${host}\n` +
    `x-acs-action:${params.action}\n` +
    `x-acs-content-sha256:${payloadHash}\n` +
    `x-acs-date:${date}\n` +
    `x-acs-signature-nonce:${nonce}\n` +
    `x-acs-version:${params.version}\n`;

  const canonicalRequest =
    `POST\n/\n\n${canonicalHeaders}\n${signedHeaders}\n${payloadHash}`;
  const hashedCanonical = await sha256Hex(canonicalRequest);
  const stringToSign = `ACS3-HMAC-SHA256\n${hashedCanonical}`;
  const signature = await hmacSha256Hex(params.accessKeySecret, stringToSign);

  return {
    'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
    'x-acs-action': params.action,
    'x-acs-version': params.version,
    'x-acs-date': date,
    'x-acs-signature-nonce': nonce,
    'x-acs-content-sha256': payloadHash,
    Authorization:
      `ACS3-HMAC-SHA256 Credential=${params.accessKeyId},SignedHeaders=${signedHeaders},Signature=${signature}`,
  };
}

export async function pushIosNotice(params: {
  config: AliyunPushConfig;
  deviceTokens: string[];
  title: string;
  body: string;
  messageId: string;
  fetcher?: typeof fetch;
}): Promise<{ ok: boolean; messageId?: string; error?: string }> {
  if (!params.deviceTokens.length) return { ok: true };
  const form = new URLSearchParams({
    AppKey: params.config.iosAppKey,
    PushType: 'NOTICE',
    DeviceType: 'iOS',
    Target: 'DEVICE',
    TargetValue: params.deviceTokens.join(','),
    Title: params.title.slice(0, 100),
    Body: (params.body.trim() || params.title).slice(0, 300),
    iOSApnsEnv: params.config.iosApnsEnv,
    iOSExtParameters: JSON.stringify({ message_id: params.messageId }),
    StoreOffline: 'true',
  });
  const body = form.toString();
  const headers = await signAcs3Post({
    endpoint: params.config.endpoint,
    action: 'Push',
    version: '2016-08-01',
    accessKeyId: params.config.accessKeyId,
    accessKeySecret: params.config.accessKeySecret,
    body,
  });

  const doFetch = params.fetcher ?? fetch;
  const response = await doFetch(params.config.endpoint, {
    method: 'POST',
    headers,
    body,
  });
  const raw = await response.text();
  let parsed: Record<string, unknown> = {};
  try {
    parsed = JSON.parse(raw) as Record<string, unknown>;
  } catch {
    // Non-JSON response is captured in raw.
  }
  if (!response.ok || parsed.Code) {
    const code = parsed.Code ? `${parsed.Code}: ` : '';
    const msg = parsed.Message ?? (raw || `HTTP ${response.status}`);
    return { ok: false, error: `${code}${msg}`.slice(0, 500) };
  }
  return { ok: true, messageId: typeof parsed.MessageId === 'string' ? parsed.MessageId : undefined };
}
