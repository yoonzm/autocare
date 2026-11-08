import { createClient, type User } from 'npm:@supabase/supabase-js@2.118.0';
import type { ApiResponse, Input } from './types.ts';

export const url = Deno.env.get('SUPABASE_URL')!;
export const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
export const admin = createClient(url, serviceKey, { auth: { persistSession: false } });
export const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info, x-request-id, x-store-id',
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
export const isInput = (value: unknown): value is Input =>
  value != null && typeof value === 'object' && !Array.isArray(value);

// Only read session_id AFTER getUser has verified this JWT's signature.
export function sessionId(token: string): string | null {
  try {
    const value=JSON.parse(atob(token.split('.')[1].replace(/-/g,'+').replace(/_/g,'/'))).session_id;
    return typeof value==='string' ? value : null;
  }catch{return null;}
}
export async function merchantSession(user: string,token: string,business: boolean): Promise<string|Response>{
  const {data,error}=await admin.rpc('platform_merchant_session',{p_user:user,p_session:sessionId(token),p_business:business});
  if(error||!data)return fail('服务状态校验失败，请稍后重试',503);
  return data.error?fail(data.error,data.status):data.store_id as string;
}

export async function userFor(request: Request): Promise<
  { response: Response } | { user: User; token: string }
> {
  const token = request.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return { response: fail('请先登录', 401) };
  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) return { response: fail('登录已过期', 401) };
  const state=await merchantSession(data.user.id,token,false);
  if(state instanceof Response)return {response:state};
  return { user: data.user, token };
}

export async function storeFor(request: Request): Promise<string | Response> {
  const auth=await userFor(request);
  if('response' in auth)return auth.response;
  const store = await merchantSession(auth.user.id,auth.token,true);
  if (store instanceof Response) return store;
  const expected = request.headers.get('x-store-id');
  if (expected && expected !== store) return fail('当前门店已变化，请刷新后重试', 409);
  return store;
}
