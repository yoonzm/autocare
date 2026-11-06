export function username(value: unknown): string | null {
  const name = typeof value === 'string' ? value.trim().toLowerCase() : '';
  return /^[a-z0-9_]{4,20}$/.test(name) ? name : null;
}
export function passwordProblem(value: unknown): string | null {
  return typeof value !== 'string' ||
      new TextEncoder().encode(value).length > 72 ||
      value.length < 8 || !/[a-zA-Z]/.test(value) || !/\d/.test(value)
    ? '密码需为 8–72 位，且包含字母和数字'
    : null;
}
export const emailOf = (name: string) => `${name}@admin.autocare.internal`;

/** Preserve the signed path/query while removing an internal gateway origin/port. */
export function supportStorageUrl(
  signedUrl: string,
  internalUrl: string,
  publicUrl: string,
): string {
  const result = new URL(signedUrl);
  if (result.origin === new URL(internalUrl).origin) {
    const base = new URL(publicUrl);
    result.protocol = base.protocol;
    result.hostname = base.hostname;
    result.port = base.port;
  }
  return result.toString();
}
export function sessionId(token: string): string | null {
  try {
    const body = JSON.parse(
      atob(token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')),
    );
    return typeof body.session_id === 'string' &&
        /^[0-9a-f-]{36}$/i.test(body.session_id)
      ? body.session_id
      : null;
  } catch {
    return null;
  }
}
