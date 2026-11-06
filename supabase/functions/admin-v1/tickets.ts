import { executeCommand } from './commands.ts';
import type { Input, WriteContext } from './types.ts';
import type { ReadContext } from './types.ts';
import { fail, json } from './shared.ts';
import { supportStorageUrl } from './rules.ts';

export const ticketActions = new Set(['ticket_reply', 'ticket_resolve']);

/** Only authenticated operators may obtain short-lived private screenshot URLs. */
export async function ticketAttachment(
  input: Input,
  context: ReadContext,
): Promise<Response> {
  if (typeof input.id !== 'string' || !/^[0-9a-f-]{36}$/i.test(input.id)) {
    return fail('截图不存在', 404);
  }
  const { db } = context.services;
  const { data, error } = await db.from('support_uploads').select(
    'path,message_id',
  ).eq('id', input.id).not('message_id', 'is', null).maybeSingle();
  if (error) return fail('读取截图失败', 503);
  if (!data) return fail('截图不存在', 404);
  const signed = await db.storage.from('support-attachments').createSignedUrl(
    data.path,
    300,
  );
  if (signed.error) return fail('读取截图失败', 503);
  // Storage can run behind a reverse proxy; never hand its internal hostname to clients.
  const internalUrl = Deno.env.get('SUPABASE_URL')!;
  const publicUrl = Deno.env.get('SUPABASE_PUBLIC_URL') || internalUrl;
  return json({
    url: supportStorageUrl(signed.data.signedUrl, internalUrl, publicUrl),
  });
}

/** Reply/resolve state transitions and audit commit together in the existing RPC. */
export function handleTickets(
  action: string,
  input: Input,
  context: WriteContext,
): Promise<Response> {
  return executeCommand(action, input, context);
}
