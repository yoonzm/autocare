import { createClient, type User } from 'npm:@supabase/supabase-js@2.118.0';
import type { ApiResponse, Input } from './types.ts';

export const url = Deno.env.get('SUPABASE_URL')!;
export const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
export const admin = createClient(url, serviceKey, { auth: { persistSession: false } });
export const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info, x-request-id',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
export const json = (body: ApiResponse, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
export const fail = (message: string, status = 400) => json({ error: message }, status);
export const nameOf = (value: unknown) => typeof value === 'string' ? value.trim() : '';
export const uuid = (value: unknown): value is string =>
  typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i.test(value);
export const phoneOf = (value: unknown) =>
  typeof value === 'string' && /^1[3-9]\d{9}$/.test(value.trim())
    ? `+86${value.trim()}`
    : null;
export const mockSmsEnabled = () => Deno.env.get('ALLOW_MOCK_SMS') === 'true';
export const isInput = (value: unknown): value is Input =>
  value != null && typeof value === 'object' && !Array.isArray(value);

export async function userFor(request: Request): Promise<
  { response: Response } | { user: User; token: string }
> {
  const token = request.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return { response: fail('请先登录', 401) };
  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) return { response: fail('登录已过期', 401) };
  return { user: data.user, token };
}

export async function storeFor(request: Request): Promise<string | Response> {
  const token = request.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return fail('请先登录', 401);
  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) return fail('登录已过期', 401);
  const { data: store, error: storeError } = await admin.from('stores')
    .select('id').eq('owner_id', data.user.id).single();
  if (storeError || !store) return fail('门店不存在', 403);
  return store.id as string;
}
