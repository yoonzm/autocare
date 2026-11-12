import { createHash } from 'node:crypto';
import { SmsError, type EnvReader, type SmsProvider, type SmsPurpose } from './sms_types.ts';

const endpoint = 'https://api-shss.zthysms.com/v2/sendSmsTp';
const md5 = (value: string) => createHash('md5').update(value, 'utf8').digest('hex');
const templateKeys: Record<SmsPurpose, string> = {
  register: 'ZHUTONG_TEMPLATE_REGISTER',
  login: 'ZHUTONG_TEMPLATE_LOGIN',
  reset_password: 'ZHUTONG_TEMPLATE_RESET_PASSWORD',
  change_phone_old: 'ZHUTONG_TEMPLATE_VERIFY',
  change_phone_new: 'ZHUTONG_TEMPLATE_BIND_PHONE',
  delete_account: 'ZHUTONG_TEMPLATE_DELETE_ACCOUNT',
  redeem: 'ZHUTONG_TEMPLATE_REDEEM',
};

/** Same v2 template protocol as my-baas; credentials and OTPs are never logged. */
export function zhutongProvider(
  env: EnvReader,
  purpose: SmsPurpose,
  fetcher: typeof fetch = fetch,
  now: () => number = Date.now,
): SmsProvider {
  const username = env('ZHUTONG_USERNAME')?.trim();
  const password = env('ZHUTONG_PASSWORD');
  const sign = env('ZHUTONG_SIGN_NAME')?.trim().replace(/^【|】$/g, '');
  // 次卡核销验证码未单独配置模板时，沿用通用的验证模板。
  const template = env(templateKeys[purpose])?.trim() || (purpose === 'redeem' ? env('ZHUTONG_TEMPLATE_VERIFY')?.trim() : undefined);
  if (!username || !password || !sign || !template) {
    throw new SmsError('该用途的短信服务尚未配置', 501, 'configuration_missing');
  }
  return {
    name: 'zhutong',
    signature: sign,
    async sendCode(phone, code) {
      const tKey = String(Math.floor(now() / 1000));
      let response: Response;
      try {
        response = await fetcher(endpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          signal: AbortSignal.timeout(8000),
          redirect: 'error',
          body: JSON.stringify({
            username,
            password: md5(md5(password) + tKey),
            signature: `【${sign}】`,
            tKey,
            tpId: template,
            records: [{ mobile: phone.replace(/^\+86/, ''), tpContent: { code } }],
          }),
        });
      } catch {
        // A timeout can occur after acceptance. Do not retry and risk duplicates.
        throw new SmsError('短信发送结果未确认，请稍后重试', 502, 'transport_error');
      }
      let result: { code?: unknown };
      try {
        result = await response.json();
      } catch {
        throw new SmsError('短信通道响应异常，请稍后重试', 502, 'invalid_response');
      }
      if (!response.ok || !result || result.code !== 200) {
        throw new SmsError('短信发送失败，请稍后重试', 502, 'provider_rejected');
      }
    },
  };
}
