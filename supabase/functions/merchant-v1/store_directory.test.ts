import { assertEquals, assertRejects } from 'jsr:@std/assert@1';
import { createClient } from 'npm:@supabase/supabase-js@2.118.0';
import { storeDirectory } from './store_directory.ts';

function fixture(paused = false, failure = '') {
  const calls: string[] = [];
  const client = createClient('https://stores.test', 'test-key', {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { fetch: async (input, init) => {
      const url = new URL(input instanceof Request ? input.url : String(input));
      calls.push(url.pathname);
      if (url.pathname.endsWith('/stores')) {
        assertEquals(url.searchParams.get('owner_id'), 'eq.owner-a');
        if (failure === 'store') return Response.json({ message: 'unavailable' }, { status: 400 });
        return Response.json(failure === 'missing' ? null : { id: 'store-a', name: '真实门店', service_paused: paused });
      }
      assertEquals(url.pathname, '/rest/v1/rpc/merchant_home_stats');
      assertEquals(JSON.parse(String(init?.body)), { p_store: 'store-a' });
      if (failure === 'stats') return Response.json({ message: 'unavailable' }, { status: 400 });
      return Response.json({ revenue: 372.4 });
    } },
  });
  return { client, calls };
}

Deno.test('directory only reads authenticated owner store, real aggregate and backend capabilities', async () => {
  const { client } = fixture();
  assertEquals(await storeDirectory(client, 'owner-a'), {
    current_store_id: 'store-a',
    items: [{ id: 'store-a', name: '真实门店', status_label: '当前门店', revenue: 372.4 }],
    can_add: false, add_hint: '当前账号仅支持一家门店',
  });
});
Deno.test('directory reflects paused service rather than invented business hours', async () => {
  const { client } = fixture(true);
  assertEquals((await storeDirectory(client, 'owner-a')).items[0].status_label, '服务已暂停');
});
for (const failure of ['store', 'missing', 'stats']) {
  Deno.test(`directory failure=${failure} never falls back to sample stores or zero revenue`, async () => {
    const { client, calls } = fixture(false, failure);
    await assertRejects(() => storeDirectory(client, 'owner-a'));
    if (failure !== 'stats') assertEquals(calls.length, 1);
  });
}
