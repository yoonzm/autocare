import { admin } from './shared.ts';
import { type OtpSendStore, type SmsPurpose } from './sms.ts';

export async function otpHash(phone: string, purpose: SmsPurpose, code: string): Promise<string> {
  const secret = Deno.env.get('SMS_OTP_PEPPER') || Deno.env.get('JWT_SECRET');
  if (!secret) throw new Error('OTP signing secret not configured');
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const bytes = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(`${phone}:${purpose}:${code}`));
  return Array.from(new Uint8Array(bytes), b => b.toString(16).padStart(2, '0')).join('');
}

export function randomOtp(): string {
  const value = new Uint32Array(1);
  const limit = 4294967296 - (4294967296 % 1000000);
  do crypto.getRandomValues(value); while (value[0] >= limit);
  return String(value[0] % 1000000).padStart(6, '0');
}

export const otpStore: OtpSendStore = {
  async reserve({ phone, purpose, hash, requestId, code, content, sign }) {
    const { data, error } = await admin.rpc('reserve_phone_otp', {
      p_phone: phone, p_purpose: purpose, p_hash: hash, p_request: requestId,
      p_code: code, p_content: content, p_sign: sign,
    });
    if (error || !data) throw new Error('OTP reservation failed');
    return data;
  },
  async finish(phone, purpose, requestId, sent, provider, failure) {
    const { data, error } = await admin.rpc('finish_phone_otp', {
      p_phone: phone, p_purpose: purpose, p_request: requestId, p_sent: sent, p_provider: provider,
      p_error: failure ?? null,
    });
    if (error || data !== true) throw new Error('OTP delivery persistence failed');
  },
};

const problems: Record<string, string> = {
  missing: '请先获取验证码', expired: '验证码已过期，请重新获取',
  attempts: '验证码错误次数过多，请重新获取', invalid: '验证码错误',
  consumed: '验证码已使用，请重新获取', not_sent: '验证码尚未发送成功，请重新获取',
};
export async function checkOtp(phone: string, code: unknown, purpose: SmsPurpose, consume = false): Promise<string | null> {
  if (typeof code !== 'string' || !/^\d{6}$/.test(code)) return '请输入 6 位数字验证码';
  const { data, error } = await admin.rpc('verify_phone_otp', {
    p_phone: phone, p_purpose: purpose, p_hash: await otpHash(phone, purpose, code), p_consume: consume,
  });
  if (error || typeof data !== 'string') return '验证码校验失败，请稍后重试';
  return data === 'ok' ? null : problems[data] ?? '验证码校验失败，请稍后重试';
}

export async function consumePhoneChangeCodes(oldPhone: string, oldCode: unknown, nextPhone: string, nextCode: unknown): Promise<string | null> {
  if (typeof oldCode !== 'string' || typeof nextCode !== 'string' ||
      !/^\d{6}$/.test(oldCode) || !/^\d{6}$/.test(nextCode)) return '请输入两个 6 位数字验证码';
  const { data, error } = await admin.rpc('consume_phone_change_otps', {
    p_old_phone: oldPhone, p_old_hash: await otpHash(oldPhone, 'change_phone_old', oldCode),
    p_new_phone: nextPhone, p_new_hash: await otpHash(nextPhone, 'change_phone_new', nextCode),
  });
  if (error || typeof data !== 'string') return '验证码校验失败，请稍后重试';
  if (data === 'ok') return null;
  const [which, reason] = data.split(':');
  return `${which === 'old' ? '当前号码' : '新号码'}：${problems[reason] ?? '验证码校验失败'}`;
}
