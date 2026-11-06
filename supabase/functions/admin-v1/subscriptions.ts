import { executeCommand } from './commands.ts';
import type { Input, WriteContext } from './types.ts';

export const subscriptionActions = new Set(['plan_save', 'refund']);

/** Plan versions and refund limits are validated transactionally by admin_command.
 * Payment/refund channel TODOs continue to fail explicitly in the existing RPC.
 */
export function handleSubscriptions(
  action: string,
  input: Input,
  context: WriteContext,
): Promise<Response> {
  return executeCommand(action, input, context);
}
