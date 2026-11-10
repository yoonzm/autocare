// 会员端小程序接口入口（POST /functions/v1/member-v1）。
// 与商户端 merchant-v1 分开部署：会员是面向车主的公网流量，使用自己的会话令牌（x-member-token），
// 不使用商户的 Supabase JWT；两边只共享同一个数据库。契约见 docs/member-mini-integration.md。
import { cors, fail, isInput } from './shared.ts';
import { handleMemberPortal } from './portal.ts';

Deno.serve(async (request: Request): Promise<Response> => {
  if (request.method === 'OPTIONS') return new Response(null, { headers: cors });
  if (request.method !== 'POST') return fail('Method not allowed', 405);
  let input: unknown;
  try {
    input = await request.json();
  } catch {
    return fail('Invalid JSON');
  }
  if (!isInput(input) || typeof input.action !== 'string') return fail('Invalid JSON');
  if (!input.action.startsWith('mb_')) return fail('不支持的会员端操作');
  return handleMemberPortal(input, request);
});
