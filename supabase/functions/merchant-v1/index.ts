import { handleSubscriptions } from './subscriptions.ts';
import { handleStores } from './stores.ts';
import { handleRegions } from './regions.ts';
import { handleSupport } from './support.ts';
import { handleInventory } from './inventory.ts';
import { handleExpenses } from './expenses.ts';
import { handleOrderCenter } from './orders_center.ts';
import { handleAccount } from './account.ts';
import { handleAuth } from './auth.ts';
import { handleCards } from './cards.ts';
import { handleHomeStats, handleSettingsStats } from './home.ts';
import { handleAppointments } from './appointments.ts';
import { handleStaff } from './staff.ts';
import { handleIdentity } from './identity.ts';
import { handleStaffWork } from './staff_work.ts';
import { gateStaff } from './staff_access.ts';
import { handleMembers, handleVehicles } from './members.ts';
import { handleFollowUps, handleMemberPackages, handleOrders } from './ops.ts';
import { handlePackages } from './packages.ts';
import { handlePackageStats } from './package_stats.ts';
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
  if (String(input.action).startsWith('identity_')) return handleIdentity(input, request);
  // 员工身份（店长 / 前台 / 技师）按权限目录逐请求校验；老板直接放行。服务端拒绝才是安全边界。
  if (input.action !== 'regions') {
    const refused = await gateStaff(request, input);
    if (refused) return refused;
  }
  if (input.action === 'staff_home') return handleIdentity(input, request);
  if (String(input.action).startsWith('subscription_')) return handleSubscriptions(input, request);
  if (input.action === 'regions') return handleRegions(input);
  if(String(input.action).startsWith('support_'))return handleSupport(input,request);
  if (['send_code', 'check_code', 'forgot_verify', 'reset_password', 'register', 'login_password', 'login_code'].includes(String(input.action))) {
    return handleAuth(input, request);
  }
  if (['get_store', 'profile_update', 'change_password', 'change_phone', 'delete_account'].includes(String(input.action))) {
    return handleAccount(input, request);
  }
  if (input.action === 'list_stores' || input.action === 'get_subscription' || String(input.action).startsWith('store_')) return handleStores(input, request);
  if (input.action === 'settings_stats') return handleSettingsStats(request);
  if (input.action === 'home_stats') return handleHomeStats(request);
  if (input.action === 'package_stats') return handlePackageStats(request);
  if (String(input.action).startsWith('appointment_')) return handleAppointments(input, request);
  if (/^staff_(task_|perf$|arrivals$|messages)/.test(String(input.action))) return handleStaffWork(input, request);
  if (String(input.action).startsWith('staff_')) return handleStaff(input, request);
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
