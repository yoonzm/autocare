export const smsPurposes = [
  'register', 'login', 'reset_password', 'change_phone_old', 'change_phone_new', 'delete_account', 'redeem',
] as const;
export type SmsPurpose = typeof smsPurposes[number];
export const isSmsPurpose = (value: unknown): value is SmsPurpose =>
  typeof value === 'string' && (smsPurposes as readonly string[]).includes(value);

export interface SmsProvider {
  readonly name: string;
  /** 短信签名（不含【】），只用于后台「短信记录」展示。 */
  readonly signature?: string;
  sendCode(phone: string, code: string, purpose: SmsPurpose): Promise<void>;
}

export class SmsError extends Error {
  constructor(message: string, readonly status = 502, readonly reason = 'provider_error') {
    super(message);
    this.name = 'SmsError';
  }
}
export type EnvReader = (name: string) => string | undefined;
