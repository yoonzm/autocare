import { handleAuth } from './auth.ts';
import { handleCards } from './cards.ts';
import { handleServices } from './services.ts';
import { cors, fail, isInput, storeFor } from './shared.ts';
import { isCatalogKind } from './types.ts';

Deno.serve(async (request: Request): Promise<Response> => {
  if (request.method === 'OPTIONS') return new Response(null, { headers: cors });
  if (request.method !== 'POST') return fail('Method not allowed', 405);
  let input: unknown;
  try {
    input = await request.json();
  } catch {
    return fail('Invalid JSON');
  }
  if (!isInput(input)) return fail('Invalid JSON');
  if (['send_mock_code', 'register', 'login_password', 'login_code'].includes(String(input.action))) {
    return handleAuth(input);
  }
  if (!isCatalogKind(input.kind)) return fail('不支持的业务类型');
  const storeId = await storeFor(request);
  if (storeId instanceof Response) return storeId;
  return input.kind === 'services'
    ? handleServices(input, storeId)
    : handleCards(input, storeId);
});
