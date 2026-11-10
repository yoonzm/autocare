import { createClient } from './deps.ts';
import { sendCode, sendLoginCode } from './sms.ts';
import type { AdminServices, Input, RpcError } from './types.ts';

export const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, apikey, content-type, x-client-info, x-request-id',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

export const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
export const fail = (error: string, status = 400) => json({ error }, status);
export const isInput = (value: unknown): value is Input =>
  value !== null && typeof value === 'object' && !Array.isArray(value);

export function rpcError(error: RpcError): Response {
  const status = error.code === '28000'
    ? 401
    : error.code === '42501'
    ? 403
    : error.code === 'P0002'
    ? 404
    : error.code === '23505'
    ? 409
    : 400;
  return fail(
    ['P0001', '28000', '42501', 'P0002'].includes(error.code ?? '')
      ? error.message
      : status === 409
      ? '用户名或请求编号已存在'
      : '输入无效或操作冲突，请检查后重试',
    status,
  );
}

let services: AdminServices | undefined;

/** Lazily initialized: importing handlers in tests needs no credentials or network. */
export function runtimeServices(): AdminServices {
  if (services) return services;
  const url = Deno.env.get('SUPABASE_URL')!;
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
  services = {
    db: createClient(url, serviceKey, { auth: { persistSession: false } }),
    publicClient: () =>
      createClient(url, anonKey, {
        auth: { persistSession: false, autoRefreshToken: false },
      }),
    sendLoginCode,
    sendCode,
  };
  return services;
}
