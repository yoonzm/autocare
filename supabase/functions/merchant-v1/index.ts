import { createClient } from 'npm:@supabase/supabase-js@2';

const url = Deno.env.get('SUPABASE_URL')!;
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const admin = createClient(url, serviceKey, { auth: { persistSession: false } });
const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
const fail = (message: string, status = 400) => json({ error: message }, status);
const phoneOf = (value: unknown) =>
  typeof value === 'string' && /^1[3-9]\d{9}$/.test(value.trim())
    ? `+86${value.trim()}`
    : null;
// TODO: Remove the development-only email alias once an SMS provider enables
// native phone login. example.com is reserved and no mail is sent.
const emailOf = (phone: string) => `merchant+${phone.slice(3)}@example.com`;
const nameOf = (value: unknown) =>
  typeof value === 'string' ? value.trim() : '';
const uuid = (value: unknown) =>
  typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f-]{27,36}$/i.test(value);

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response(null, { headers: cors });
  if (request.method !== 'POST') return fail('Method not allowed', 405);
  let input: Record<string, unknown>;
  try {
    input = await request.json();
    if (!input || typeof input !== 'object' || Array.isArray(input)) throw Error();
  } catch {
    return fail('Invalid JSON');
  }

  const action = input.action;
  const phone = phoneOf(input.phone);
  const mockSms = Deno.env.get('ALLOW_MOCK_SMS') === 'true';

  if (action === 'send_mock_code') {
    // TODO: Replace with a rate-limited SMS provider before production.
    if (!mockSms) return fail('短信服务尚未启用', 501);
    if (!phone) return fail('请输入有效手机号');
    return json({ code: '123456', mock: true });
  }

  if (action === 'register') {
    if (!mockSms) return fail('生产级手机注册待接入短信服务', 501);
    if (!phone || input.code !== '123456') return fail('手机号或验证码无效');
    const password = input.password;
    const storeName = nameOf(input.store_name);
    if (typeof password !== 'string' || password.length < 8 || password.length > 72 ||
        !/[a-zA-Z]/.test(password) || !/\d/.test(password) ||
        storeName.length < 1 || storeName.length > 100) {
      return fail('请填写门店名称和 8–72 位含字母、数字的密码');
    }
    const { data, error } = await admin.auth.admin.createUser({
      phone,
      email: emailOf(phone),
      password,
      phone_confirm: true,
      email_confirm: true,
    });
    if (error || !data.user) return fail(error?.message ?? '注册失败', 409);
    const { error: storeError } = await admin.from('stores').upsert({
      owner_id: data.user.id,
      name: storeName,
      phone,
    }, { onConflict: 'owner_id' });
    if (storeError) {
      await admin.auth.admin.deleteUser(data.user.id);
      return fail('门店创建失败', 500);
    }
    return json({ ok: true });
  }

  if (action === 'login_password') {
    if (!phone || typeof input.password !== 'string') return fail('手机号或密码无效');
    const publicAuth = createClient(url, anonKey, { auth: { persistSession: false } });
    const { data, error } = await publicAuth.auth.signInWithPassword({
      email: emailOf(phone),
      password: input.password,
    });
    if (error || !data.session) return fail('手机号或密码错误', 401);
    return json({
      access_token: data.session.access_token,
      refresh_token: data.session.refresh_token,
    });
  }

  // TODO: Phone-code login needs a real SMS provider and production-grade OTP verification.
  if (action === 'login_code') return fail('验证码登录暂未接通，请使用密码登录', 501);

  const token = request.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return fail('请先登录', 401);
  const { data: userData, error: userError } = await admin.auth.getUser(token);
  if (userError || !userData.user) return fail('登录已过期', 401);
  const { data: store, error: storeError } = await admin.from('stores')
    .select('id').eq('owner_id', userData.user.id).single();
  if (storeError || !store) return fail('门店不存在', 403);

  const table = input.kind === 'services' ? 'service_items'
    : input.kind === 'cards' ? 'card_types' : null;
  if (!table) return fail('不支持的业务类型');
  if (action === 'list') {
    const { data, error } = await admin.from(table).select('*')
      .eq('store_id', store.id).order('created_at', { ascending: false });
    return error ? fail('读取失败', 500) : json({ items: data });
  }
  if (action === 'save') {
    const name = nameOf(input.name);
    if (!name || name.length > 100) return fail('名称长度须为 1–100 字');
    const values: Record<string, unknown> = { name };
    if (table === 'service_items') {
      const price = Number(input.price);
      if (!Number.isFinite(price) || price < 0 || price > 99999999.99)
        return fail('价格无效');
      values.price = price;
      values.category = nameOf(input.category) || '其他';
      values.description = nameOf(input.description);
    } else {
      const discount = Number(input.discount);
      if (!Number.isFinite(discount) || discount <= 0 || discount > 1)
        return fail('折扣系数无效');
      values.discount = discount;
      values.description = nameOf(input.description);
    }
    if (input.id != null && !uuid(input.id)) return fail('记录 ID 无效');
    const query = input.id == null
      ? admin.from(table).insert({ ...values, store_id: store.id })
      : admin.from(table).update(values).eq('id', input.id).eq('store_id', store.id);
    const { data, error } = await query.select('*').single();
    return error ? fail('保存失败', 400) : json({ item: data });
  }
  if (action === 'delete') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    const { data, error } = await admin.from(table).delete()
      .eq('id', input.id).eq('store_id', store.id).select('id').maybeSingle();
    return error ? fail('删除失败', 400) : data ? json({ ok: true }) : fail('记录不存在', 404);
  }
  return fail('不支持的操作');
});
