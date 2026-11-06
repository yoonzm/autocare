import { assertEquals, assertRejects } from 'jsr:@std/assert@1';
import { createClient } from 'npm:@supabase/supabase-js@2.118.0';
import { settingsCounts } from './settings_stats.ts';

for (const fail of [false, true]) {
  Deno.test(`settings exact counts are store scoped; database failure=${fail}`, async () => {
    const queries: URL[] = [];
    const admin = createClient('https://settings.test', 'test-key', {
      auth: { persistSession: false, autoRefreshToken: false },
      global: { fetch: async (input, init) => {
        const url = new URL(input instanceof Request ? input.url : String(input));
        queries.push(url);
        assertEquals(init?.method, 'HEAD');
        assertEquals(url.searchParams.get('store_id'), 'eq.current-store');
        if (fail) return new Response(null, { status: 500 });
        const count = url.pathname.endsWith('service_items') ? 1201 : 0;
        return new Response(null, { headers: { 'content-range': `*/${count}` } });
      } },
    });
    if (fail) await assertRejects(() => settingsCounts(admin, 'current-store'));
    else assertEquals(await settingsCounts(admin, 'current-store'), { staff: 0, services: 1201, cards: 0 });
    assertEquals(queries.length, 3);
    assertEquals(queries.find(u => u.pathname.endsWith('appointment_resources'))?.searchParams.get('kind'), 'eq.technician');
    assertEquals(queries.find(u => u.pathname.endsWith('card_types'))?.searchParams.get('active'), 'eq.true');
  });
}
