import { admin, fail, json, merchantSession, sessionId, userFor } from './shared.ts';
import type { Input } from './types.ts';

export async function handleStores(input: Input, request: Request): Promise<Response> {
  const auth = await userFor(request);
  if ('response' in auth) return auth.response;
  const session = sessionId(auth.token);
  if (input.action === 'list_stores' || input.action === 'get_subscription') {
    const { data, error } = await admin.rpc('merchant_store_directory', { p_user: auth.user.id, p_session: session });
    if (error) return fail('读取门店或订阅失败，请重试', 500);
    if (data.error) return fail(data.error, data.status ?? 400);
    return json({ item: input.action === 'get_subscription' ? data.subscription : data });
  }
  const action = String(input.action).replace('store_', '');
  if (!['create', 'update', 'switch', 'archive', 'restore'].includes(action)) return fail('不支持的操作');
  if (action === 'update') {
    const current = await merchantSession(auth.user.id, auth.token, true);
    if (current instanceof Response) return current;
    if (request.headers.get('x-store-id') && request.headers.get('x-store-id') !== current) return fail('当前门店已变化，请重新打开页面', 409);
  }
  const { data, error } = await admin.rpc('merchant_store_mutate', {
    p_user: auth.user.id, p_session: session, p_action: action,
    p_input: { id: input.id ?? null, name: input.name ?? '', phone: input.phone ?? '', address: input.address ?? '' },
    p_request: request.headers.get('x-request-id'),
  });
  if (error) return fail(error.message, error.code === '42501' ? 403 : 400);
  if (data.error) return fail(data.error, data.status ?? 400);
  return json({ item: data });
}
