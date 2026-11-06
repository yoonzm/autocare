import { fail, json, rpcError } from './shared.ts';
import type { Input, ReadContext } from './types.ts';

/** Keep the existing paginated read contract and full-dataset SQL aggregates. */
export async function handleSnapshot(
  input: Input,
  context: ReadContext,
): Promise<Response> {
  const offset = input.offset ?? 0;
  if (typeof offset !== 'number' || !Number.isInteger(offset) || offset < 0) {
    return fail('分页参数无效');
  }
  const { data, error } = await context.services.db.rpc('admin_snapshot', {
    p_actor: context.me.id,
    p_session: context.sessionId,
    p_offset: offset,
  });
  return error ? rpcError(error) : json(data);
}
