/** SMS failures exposed to the merchant-operation handler, without provider details. */
export class SmsDeliveryError extends Error {
  constructor(message: string, readonly status: number) {
    super(message);
    this.name = 'SmsDeliveryError';
  }
}

/** Reuse the real provider and atomic OTP quotas; no mock channel or returned OTP. */
export async function sendLoginCode(
  phone: string,
  requestId: string,
): Promise<Record<string, unknown>> {
  const { sendOtp, SmsError, smsProvider } = await import(
    '../merchant-v1/sms.ts'
  );
  try {
    const { otpHash, otpStore, randomOtp } = await import(
      '../merchant-v1/otp.ts'
    );
    const provider = smsProvider((name) => Deno.env.get(name), 'login');
    const code = randomOtp();
    return await sendOtp(provider, otpStore, {
      phone,
      purpose: 'login',
      code,
      hash: await otpHash(phone, 'login', code),
      requestId,
    });
  } catch (error) {
    throw error instanceof SmsError
      ? new SmsDeliveryError(error.message, error.status)
      : new SmsDeliveryError('短信暂不可用，请稍后重试', 503);
  }
}
