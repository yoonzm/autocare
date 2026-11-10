import { accountActions, handleAccounts } from './accounts.ts';
import {
  authActions,
  currentAccount,
  handleAuth,
  handleLogin,
} from './auth.ts';
import { commandContext, executeCommand } from './commands.ts';
import { handleMerchants, merchantActions } from './merchants.ts';
import { adminFor, authorizeAction } from './permissions.ts';
import { cors, fail, isInput, runtimeServices } from './shared.ts';
import { handleSmsRead, handleSmsResend, smsReadActions } from './sms_logs.ts';
import { handleSnapshot } from './snapshot.ts';
import { handleSubscriptions, subscriptionActions } from './subscriptions.ts';
import { handleTickets, ticketActions, ticketAttachment } from './tickets.ts';
import type { AdminServices } from './types.ts';

/** HTTP boundary and routing only; business handlers live beside this entry. */
export function createHandler(services?: AdminServices) {
  return async (request: Request): Promise<Response> => {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: cors });
    }
    if (request.method !== 'POST') return fail('Method not allowed', 405);
    try {
      const input: unknown = await request.json();
      if (!isInput(input)) return fail('Invalid JSON');
      const action = String(input.action ?? '');
      const dependencies = services ?? runtimeServices();
      if (action === 'login') return await handleLogin(input, dependencies);

      const identity = await adminFor(request, dependencies);
      if (identity instanceof Response) return identity;
      if (action === 'me') return currentAccount(identity);
      const denied = await authorizeAction(action, identity);
      if (denied) return denied;
      if (action === 'snapshot') return await handleSnapshot(input, identity);
      if (action === 'ticket_attachment') return await ticketAttachment(input, identity);
      if (smsReadActions.has(action)) return await handleSmsRead(action, input, identity);

      const context = commandContext(identity, request);
      if (context instanceof Response) return context;
      if (action === 'sms_resend') return await handleSmsResend(input, context);
      if (authActions.has(action)) {
        return await handleAuth(action, input, context);
      }
      if (accountActions.has(action)) {
        return await handleAccounts(action, input, context);
      }
      if (merchantActions.has(action)) {
        return await handleMerchants(action, input, context);
      }
      if (subscriptionActions.has(action)) {
        return await handleSubscriptions(action, input, context);
      }
      if (ticketActions.has(action)) {
        return await handleTickets(action, input, context);
      }
      // Keep unknown-action SQL validation/error behavior compatible with V1.
      return await executeCommand(action, input, context);
    } catch (error) {
      if (error instanceof SyntaxError) return fail('Invalid JSON');
      // Never expose Auth credentials, SQL, or service key material to clients.
      return fail('后台服务暂不可用，请稍后重试', 503);
    }
  };
}

export const handler = createHandler();
if (import.meta.main) Deno.serve(handler);
