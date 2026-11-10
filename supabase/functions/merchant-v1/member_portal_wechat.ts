// 微信小程序服务端接口：登录凭证换 openid、手机号授权码换手机号。
// AppID / AppSecret 只放服务器环境变量（WECHAT_MINI_APPID / WECHAT_MINI_SECRET），不进代码、小程序或流水线。
// 缺少配置时返回 501，不模拟登录。
export class WechatError extends Error {
  constructor(message: string, readonly status = 502, readonly reason = 'wechat_error') {
    super(message);
    this.name = 'WechatError';
  }
}
export type EnvReader = (name: string) => string | undefined;
export interface WechatClient {
  /** wx.login 的 code -> openid */
  openid(code: string): Promise<string>;
  /** 手机号授权按钮返回的 code -> 11 位国内手机号 */
  phone(code: string): Promise<string>;
}

const base = 'https://api.weixin.qq.com';
const tokenCache = new Map<string, { token: string; expires: number }>();

type Json = Record<string, unknown>;

export function wechatClient(env: EnvReader, fetcher: typeof fetch = fetch, now: () => number = Date.now): WechatClient {
  const appid = env('WECHAT_MINI_APPID')?.trim();
  const secret = env('WECHAT_MINI_SECRET')?.trim();
  if (!appid || !secret) throw new WechatError('微信登录尚未配置', 501, 'configuration_missing');

  async function call(url: string, init?: RequestInit): Promise<Json> {
    let response: Response;
    try {
      response = await fetcher(url, { ...init, signal: AbortSignal.timeout(8000), redirect: 'error' });
    } catch {
      throw new WechatError('微信服务暂时不可用，请稍后重试', 502, 'transport_error');
    }
    let body: Json;
    try {
      body = await response.json();
    } catch {
      throw new WechatError('微信服务响应异常，请稍后重试', 502, 'invalid_response');
    }
    if (!response.ok) throw new WechatError('微信服务暂时不可用，请稍后重试', 502, 'http_error');
    return body;
  }

  async function accessToken(force = false): Promise<string> {
    const cached = tokenCache.get(appid!);
    if (!force && cached && cached.expires > now() + 60_000) return cached.token;
    const body = await call(`${base}/cgi-bin/token?grant_type=client_credential&appid=${encodeURIComponent(appid!)}&secret=${encodeURIComponent(secret!)}`);
    if (typeof body.access_token !== 'string' || typeof body.expires_in !== 'number') {
      throw new WechatError('微信服务配置无效，请联系管理员', 502, 'token_rejected');
    }
    tokenCache.set(appid!, { token: body.access_token, expires: now() + body.expires_in * 1000 });
    return body.access_token;
  }

  return {
    async openid(code) {
      if (!/^[\w-]{8,128}$/.test(code)) throw new WechatError('登录凭证无效，请重试', 400, 'invalid_code');
      const body = await call(`${base}/sns/jscode2session?appid=${encodeURIComponent(appid)}&secret=${encodeURIComponent(secret)}&js_code=${encodeURIComponent(code)}&grant_type=authorization_code`);
      if (typeof body.openid !== 'string' || !body.openid) {
        // 40029 code 无效 / 40163 code 已使用 / 45011 频率限制
        throw new WechatError(body.errcode === 45011 ? '操作过于频繁，请稍后重试' : '登录凭证无效，请重试',
          body.errcode === 45011 ? 429 : 400, 'login_rejected');
      }
      return body.openid;
    },
    async phone(code) {
      if (!/^[\w-]{8,128}$/.test(code)) throw new WechatError('手机号授权无效，请重试', 400, 'invalid_code');
      for (const attempt of [0, 1]) {
        const token = await accessToken(attempt === 1);
        const body = await call(`${base}/wxa/business/getuserphonenumber?access_token=${encodeURIComponent(token)}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ code }),
        });
        // access_token 失效（40001 / 42001 / 40014）时刷新一次再试
        if (attempt === 0 && [40001, 42001, 40014].includes(body.errcode as number)) continue;
        const info = body.phone_info as Json | undefined;
        if (body.errcode !== 0 || !info || typeof info.purePhoneNumber !== 'string') {
          throw new WechatError('手机号授权无效，请重试', 400, 'phone_rejected');
        }
        if (String(info.countryCode ?? '86') !== '86' || !/^1[3-9]\d{9}$/.test(info.purePhoneNumber)) {
          throw new WechatError('仅支持中国大陆手机号', 400, 'phone_unsupported');
        }
        return info.purePhoneNumber;
      }
      throw new WechatError('微信服务暂时不可用，请稍后重试', 502, 'token_rejected');
    },
  };
}
