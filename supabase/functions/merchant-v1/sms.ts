import { SmsError, type EnvReader, type SmsProvider, type SmsPurpose } from './sms_types.ts';
import { zhutongProvider } from './sms_zhutong.ts';
export { SmsError, isSmsPurpose, type SmsPurpose } from './sms_types.ts';

type ProviderFactory = (env: EnvReader, purpose: SmsPurpose) => SmsProvider;
// Add future providers here. Business/OTP logic depends only on SmsProvider.
const providers: Record<string, ProviderFactory> = { zhutong: zhutongProvider };

export function smsProvider(env: EnvReader, purpose: SmsPurpose): SmsProvider {
  const selected = env('SMS_PROVIDER')?.trim();
  if (selected) {
    const factory = Object.hasOwn(providers, selected) ? providers[selected] : undefined;
    if (!factory) throw new SmsError('短信渠道尚未支持', 501, 'unknown_provider');
    return factory(env, purpose);
  }
  throw new SmsError('短信服务尚未启用', 501, 'configuration_missing');
}

export interface OtpSendStore {
  // code / content / sign 仅用于后台「短信记录」（按产品决定明文保存，只有超级管理员能查看）。
  reserve(request: {
    phone: string; purpose: SmsPurpose; hash: string; requestId: string; code: string; content: string; sign: string;
  }): Promise<{ error?: string; retry_after?: number }>;
  finish(phone: string, purpose: SmsPurpose, requestId: string, sent: boolean, provider: string, error?: string): Promise<void>;
}

export async function sendOtp(
  provider: SmsProvider,
  store: OtpSendStore,
  request: { phone: string; purpose: SmsPurpose; code: string; hash: string; requestId: string },
): Promise<{ ok: true; retry_after: number; expires_in: number }> {
  // Reserve atomically before calling a paid provider: concurrent requests lose.
  const { phone, purpose, hash, requestId } = request;
  const sign = provider.signature ?? '';
  const content = `${sign ? `【${sign}】` : ''}验证码 ${request.code}，5 分钟内有效，请勿泄露给他人。`;
  const reservation = await store.reserve({ phone, purpose, hash, requestId, code: request.code, content, sign });
  if (reservation.error) {
    if (reservation.error === 'cooldown') {
      throw new SmsError(`请 ${reservation.retry_after ?? 60} 秒后再获取验证码`, 429, 'cooldown');
    }
    throw new SmsError(reservation.error === 'phone_quota'
      ? '今日发送次数已达上限' : '短信服务今日发送量已达上限，请稍后再试', 429, reservation.error);
  }
  try {
    await provider.sendCode(request.phone, request.code, request.purpose);
  } catch (error) {
    const failure = error instanceof SmsError ? error : new SmsError('短信发送失败，请稍后重试');
    await store.finish(request.phone, request.purpose, request.requestId, false, provider.name, `${failure.message}（${failure.reason}）`);
    throw failure;
  }
  // Pending/failed codes cannot be verified. A DB error fails closed here.
  await store.finish(request.phone, request.purpose, request.requestId, true, provider.name);
  return {
    ok: true, retry_after: 60, expires_in: 300,
  };
}
