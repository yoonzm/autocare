import { createHash } from 'node:crypto';
import { SmsError, type EnvReader, type SmsNoticeProvider, type SmsProvider, type SmsPurpose, type SmsSendResult } from './sms_types.ts';

const templateEndpoint = 'https://api-shss.zthysms.com/v2/sendSmsTp';
const customEndpoint = 'https://api-shss.zthysms.com/v2/sendSms';
const batchReportEndpoint = 'https://api-shss.zthysms.com/v2/batchReport';
const md5 = (value: string) => createHash('md5').update(value, 'utf8').digest('hex');

export interface ZhutongReportRecord {
  msg_id?: string;
  msgId?: string;
  mobile?: string;
  report_time?: string;
  reportTime?: string;
  code?: string;
  msg?: string;
  extend?: string;
  pkTotal?: number;
  pkNumber?: number;
  username?: string;
}
const templateKeys: Record<SmsPurpose, string> = {
  register: 'ZHUTONG_TEMPLATE_REGISTER',
  login: 'ZHUTONG_TEMPLATE_LOGIN',
  reset_password: 'ZHUTONG_TEMPLATE_RESET_PASSWORD',
  change_phone_old: 'ZHUTONG_TEMPLATE_VERIFY',
  change_phone_new: 'ZHUTONG_TEMPLATE_BIND_PHONE',
  delete_account: 'ZHUTONG_TEMPLATE_DELETE_ACCOUNT',
  redeem: 'ZHUTONG_TEMPLATE_REDEEM',
};

function readCredentials(env: EnvReader) {
  const username = env('ZHUTONG_USERNAME')?.trim();
  const password = env('ZHUTONG_PASSWORD');
  const sign = env('ZHUTONG_SIGN_NAME')?.trim().replace(/^【|】$/g, '');
  if (!username || !password || !sign) {
    throw new SmsError('短信服务尚未配置', 501, 'configuration_missing');
  }
  return { username, password, sign };
}

async function postZhutong(
  endpoint: string,
  creds: { username: string; password: string; sign?: string },
  payload: Record<string, unknown>,
  fetcher: typeof fetch,
  now: () => number,
  allowNoData = false,
): Promise<{ code: number; msgId?: string; records?: ZhutongReportRecord[] }> {
  const tKey = String(Math.floor(now() / 1000));
  let response: Response;
  try {
    response = await fetcher(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      signal: AbortSignal.timeout(8000),
      redirect: 'error',
      body: JSON.stringify({
        username: creds.username,
        password: md5(md5(creds.password) + tKey),
        ...(creds.sign ? { signature: `【${creds.sign}】` } : {}),
        tKey,
        ...payload,
      }),
    });
  } catch {
    throw new SmsError('短信发送结果未确认，请稍后重试', 502, 'transport_error');
  }
  let result: { code?: unknown; msgId?: unknown; records?: unknown };
  try {
    result = await response.json();
  } catch {
    throw new SmsError('短信通道响应异常，请稍后重试', 502, 'invalid_response');
  }
  if (!response.ok || !result || (result.code !== 200 && !(allowNoData && result.code === 4017))) {
    throw new SmsError('短信发送失败，请稍后重试', 502, 'provider_rejected');
  }
  return {
    code: result.code as number,
    msgId: typeof result.msgId === 'string' ? result.msgId : undefined,
    records: Array.isArray(result.records) ? (result.records as ZhutongReportRecord[]) : undefined,
  };
}

/** Same v2 template protocol as my-baas; credentials and OTPs are never logged. */
export function zhutongProvider(
  env: EnvReader,
  purpose: SmsPurpose,
  fetcher: typeof fetch = fetch,
  now: () => number = Date.now,
): SmsProvider {
  const creds = readCredentials(env);
  // 次卡核销验证码未单独配置模板时，沿用通用的验证模板。
  const template = env(templateKeys[purpose])?.trim() || (purpose === 'redeem' ? env('ZHUTONG_TEMPLATE_VERIFY')?.trim() : undefined);
  if (!template) {
    throw new SmsError('该用途的短信服务尚未配置', 501, 'configuration_missing');
  }
  return {
    name: 'zhutong',
    signature: creds.sign,
    async sendCode(phone, code, _purpose, requestId): Promise<SmsSendResult> {
      const res = await postZhutong(
        templateEndpoint,
        creds,
        {
          tpId: template,
          ...(requestId ? { extend: requestId } : {}),
          records: [{ mobile: phone.replace(/^\+86/, ''), tpContent: { code } }],
        },
        fetcher,
        now,
      );
      return res.msgId ? { msgId: res.msgId } : {};
    },
  };
}

/** 助通自定义短信（/v2/sendSms），用于通知类非验证码短信。 */
export function zhutongNoticeProvider(
  env: EnvReader,
  fetcher: typeof fetch = fetch,
  now: () => number = Date.now,
): SmsNoticeProvider {
  const creds = readCredentials(env);
  return {
    name: 'zhutong',
    signature: creds.sign,
    async sendNotice(phone, content, requestId): Promise<SmsSendResult> {
      const clean = content.trim().replace(/^【[^】]*】/, '');
      const res = await postZhutong(
        customEndpoint,
        creds,
        {
          mobile: phone.replace(/^\+86/, ''),
          content: `【${creds.sign}】${clean}`,
          ...(requestId ? { extend: requestId } : {}),
        },
        fetcher,
        now,
      );
      return res.msgId ? { msgId: res.msgId } : {};
    },
  };
}

/** 助通下行回执抓取（/v2/batchReport）：4017 表示暂无新回执，返回空数组。 */
export async function zhutongBatchReport(
  env: EnvReader,
  count = 400,
  fetcher: typeof fetch = fetch,
  now: () => number = Date.now,
): Promise<ZhutongReportRecord[]> {
  const username = env('ZHUTONG_USERNAME')?.trim();
  const password = env('ZHUTONG_PASSWORD');
  if (!username || !password) {
    throw new SmsError('短信服务尚未配置', 501, 'configuration_missing');
  }
  const res = await postZhutong(
    batchReportEndpoint,
    { username, password },
    { count: Math.min(Math.max(Math.trunc(count), 1), 1000) },
    fetcher,
    now,
    true,
  );
  return res.code === 4017 ? [] : (res.records ?? []);
}
