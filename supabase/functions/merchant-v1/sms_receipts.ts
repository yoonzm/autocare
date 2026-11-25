import { admin, fail, json } from './shared.ts';
import { SmsError } from './sms_types.ts';
import { zhutongBatchReport } from './sms_zhutong.ts';

const BATCH_SIZE = 400;
const MAX_BATCHES = 5;

export async function pullSmsReceipts(deps: {
  env: (name: string) => string | undefined;
  fetchBatch?: (count: number) => Promise<unknown[]>;
  applyReports: (provider: string, records: unknown[]) => Promise<number>;
}): Promise<{ pulled: number; updated: number; skipped?: string }> {
  if (deps.env('SMS_PROVIDER')?.trim() !== 'zhutong') {
    return { pulled: 0, updated: 0, skipped: 'provider_not_zhutong' };
  }
  const fetchBatch = deps.fetchBatch ?? ((count: number) => zhutongBatchReport(deps.env, count));
  let pulled = 0;
  let updated = 0;
  for (let i = 0; i < MAX_BATCHES; i++) {
    const records = await fetchBatch(BATCH_SIZE);
    if (!records.length) break;
    pulled += records.length;
    updated += await deps.applyReports('zhutong', records);
    if (records.length < BATCH_SIZE) break;
  }
  return { pulled, updated };
}

export async function handleSmsReceipts(request: Request): Promise<Response> {
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!key || request.headers.get('authorization') !== `Bearer ${key}`) return fail('Forbidden', 403);
  try {
    const item = await pullSmsReceipts({
      env: (name) => Deno.env.get(name),
      applyReports: async (provider, records) => {
        const { data, error } = await admin.rpc('apply_sms_delivery_reports', {
          p_provider: provider,
          p_records: records,
        });
        if (error) throw error;
        return typeof data === 'number' ? data : 0;
      },
    });
    return json({ ok: true, item });
  } catch (error) {
    if (error instanceof SmsError) return fail(error.message, error.status);
    return fail('短信回执拉取失败，请检查任务状态', 500);
  }
}
