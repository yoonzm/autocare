const VALID_PLATFORMS = new Set(['ios', 'android']);

export function validatePushDeviceInput(
  input: Record<string, unknown>,
): { platform: 'ios' | 'android'; token: string } | string {
  const platform = String(input.platform ?? '').trim().toLowerCase();
  if (!VALID_PLATFORMS.has(platform)) return '推送平台无效';
  const token = String(input.token ?? '').trim();
  if (token.length < 8 || token.length > 256) return '推送设备标识无效';
  return { platform: platform as 'ios' | 'android', token };
}
