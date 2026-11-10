/** SMS failures exposed to the merchant-operation handler, without provider details. */
export class SmsDeliveryError extends Error {
  constructor(message: string, readonly status: number) {
    super(message);
    this.name = 'SmsDeliveryError';
  }
}

/** Reuse the real provider and atomic OTP quotas; no mock channel or returned OTP. */
export function sendLoginCode(
  phone: string,
  requestId: string,
): Promise<Record<string, unknown>> {
  return sendCode(phone, 'login', requestId);
}

/** 「短信记录」重发：按原用途重新生成验证码并经真实渠道发送，同样受冷却与每日额度限制。 */
export async function sendCode(
  phone: string,
  purpose: string,
  requestId: string,
): Promise<Record<string, unknown>> {
  const { isSmsPurpose, sendOtp, SmsError, smsProvider } = await import(
    '../merchant-v1/sms.ts'
  );
  if (!isSmsPurpose(purpose)) {
    throw new SmsDeliveryError('不支持的验证码用途', 400);
  }
  try {
    const { otpHash, otpStore, randomOtp } = await import(
      '../merchant-v1/otp.ts'
    );
    const provider = smsProvider((name) => Deno.env.get(name), purpose);
    const code = randomOtp();
    return await sendOtp(provider, otpStore, {
      phone,
      purpose,
      code,
      hash: await otpHash(phone, purpose, code),
      requestId,
    });
  } catch (error) {
    throw error instanceof SmsError
      ? new SmsDeliveryError(error.message, error.status)
      : new SmsDeliveryError('短信暂不可用，请稍后重试', 503);
  }
}
