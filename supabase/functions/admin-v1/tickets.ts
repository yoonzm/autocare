import { executeCommand } from './commands.ts';
import type { Input, WriteContext } from './types.ts';

export const ticketActions = new Set(['ticket_reply', 'ticket_resolve']);

/** Reply/resolve state transitions and audit commit together in the existing RPC. */
export function handleTickets(
  action: string,
  input: Input,
  context: WriteContext,
): Promise<Response> {
  return executeCommand(action, input, context);
}
