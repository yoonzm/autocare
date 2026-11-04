import { handleInventory } from './inventory.ts';
import { handleExpenses } from './expenses.ts';
import { handleOrderCenter } from './orders_center.ts';
import { handleAccount } from './account.ts';
import { handleAuth } from './auth.ts';
import { handleCards } from './cards.ts';
import { handleHomeStats } from './home.ts';
import { handleAppointments } from './appointments.ts';
import { handleMembers, handleVehicles } from './members.ts';
import { handleFollowUps, handleMemberPackages, handleOrders } from './ops.ts';
import { handlePackages } from './packages.ts';
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
  if (['send_mock_code', 'check_code', 'forgot_verify', 'reset_password', 'register', 'login_password', 'login_code'].includes(String(input.action))) {
    return handleAuth(input);
  }
  if (['get_store', 'change_password', 'change_phone', 'delete_account'].includes(String(input.action))) {
    return handleAccount(input, request);
  }
  if (input.action === 'home_stats') return handleHomeStats(request);
  if (String(input.action).startsWith('appointment_')) return handleAppointments(input, request);
  if (String(input.action).startsWith('inventory_')) return handleInventory(input, request);
  if (String(input.action).startsWith('expense_')) return handleExpenses(input, request);
  if (String(input.action).startsWith('order_')) return handleOrderCenter(input, request);
  if (!isCatalogKind(input.kind)) return fail('不支持的业务类型');
  // 幂等标识只取请求头（客户端对同一次点击带同一个 X-Request-Id），不接受放在 body 里的值
  input.__request = request.headers.get('x-request-id');
  const storeId = await storeFor(request);
  if (storeId instanceof Response) return storeId;
  if (input.kind === 'packages') return handlePackages(input, storeId);
  if (input.kind === 'members') return handleMembers(input, storeId);
  if (input.kind === 'vehicles') return handleVehicles(input, storeId);
  if (input.kind === 'member_packages') return handleMemberPackages(input, storeId);
  if (input.kind === 'orders') return handleOrders(input, storeId);
  if (input.kind === 'follow_ups') return handleFollowUps(input, storeId);
  return input.kind === 'services'
    ? handleServices(input, storeId)
    : handleCards(input, storeId);
});
