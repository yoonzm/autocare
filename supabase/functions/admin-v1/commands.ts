import { fail, json, rpcError } from './shared.ts';
import type {
  CommandResult,
  Input,
  ReadContext,
  WriteContext,
} from './types.ts';

/** Request identity only comes from headers; actor/session only from verified auth. */
export function commandContext(
  context: ReadContext,
  request: Request,
): WriteContext | Response {
  const requestId = request.headers.get('x-request-id');
  if (!requestId || !/^[0-9a-f-]{36}$/i.test(requestId)) {
    return fail('缺少有效请求编号');
  }
  return {
    ...context,
    requestId,
    command: async (action, values, operationSession = context.sessionId) => {
      const { db } = context.services;
      const result = await db.rpc('admin_command', {
        p_actor: context.me.id,
        p_session: operationSession,
        p_action: action,
        p_input: values,
        p_request: requestId,
      });
      if (result.error) {
        await db.from('admin_audit_logs').insert({
          actor_id: context.me.id,
          action: action + '_failed',
          target: typeof values.id === 'string' ? values.id : null,
          detail: { code: result.error.code, request_id: requestId },
        });
      }
      return result as CommandResult;
    },
  };
}

/** Critical state changes and successful audit remain in the same SQL transaction. */
export async function executeCommand(
  action: string,
  input: Input,
  context: WriteContext,
): Promise<Response> {
  const values = { ...input };
  delete values.action;
  const done = await context.command(action, values);
  return done.error ? rpcError(done.error) : json(done.data);
}
