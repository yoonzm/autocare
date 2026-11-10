// 会员端函数自己的最小共享层：数据库客户端（service_role）、响应与 CORS。
// 与 merchant-v1 完全独立部署，不跨目录 import（部署包按函数目录分别拷贝）。
import { createClient } from 'npm:@supabase/supabase-js@2.118.0';

const url = Deno.env.get('SUPABASE_URL')!;
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
// 会员没有 Supabase 账号；所有数据访问都经本函数在校验会员会话后以 service_role 执行，
// 表对 anon / authenticated 无权限（见迁移 202611100001_member_portal.sql）。
export const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

export const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info, x-request-id, x-member-token',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
export type Body = Record<string, unknown>;
export const json = (body: Body, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
export const fail = (message: string, status = 400) => json({ error: message }, status);
export const uuid = (value: unknown): value is string =>
  typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i.test(value);
export const isInput = (value: unknown): value is Body =>
  value != null && typeof value === 'object' && !Array.isArray(value);
