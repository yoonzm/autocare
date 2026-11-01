import { createClient } from 'npm:@supabase/supabase-js@2.118.0';
import { admin, anonKey, fail, json, mockSmsEnabled, nameOf, phoneOf, url } from './shared.ts';
import type { Input } from './types.ts';

// TODO: Replace the development alias with native phone auth after SMS is configured.
const emailOf = (phone: string) => `merchant+${phone.slice(3)}@example.com`;

export async function handleAuth(input: Input): Promise<Response> {
  const phone = phoneOf(input.phone);
  if (input.action === 'send_mock_code') {
    // TODO: Replace with a rate-limited SMS provider before production.
    if (!mockSmsEnabled()) return fail('短信服务尚未启用', 501);
    if (!phone) return fail('请输入有效手机号');
    return json({ code: '123456', mock: true });
  }
  if (input.action === 'register') {
    if (!mockSmsEnabled()) return fail('生产级手机注册待接入短信服务', 501);
    if (!phone || input.code !== '123456') return fail('手机号或验证码无效');
    const password = input.password;
    const storeName = nameOf(input.store_name);
    if (typeof password !== 'string' || password.length < 8 || password.length > 72 ||
        !/[a-zA-Z]/.test(password) || !/\d/.test(password) ||
        storeName.length < 1 || storeName.length > 100) {
      return fail('请填写门店名称和 8–72 位含字母、数字的密码');
    }
    const { data, error } = await admin.auth.admin.createUser({
      phone, email: emailOf(phone), password, phone_confirm: true, email_confirm: true,
    });
    if (error || !data.user) return fail(error?.message ?? '注册失败', 409);
    const { error: storeError } = await admin.from('stores').upsert({
      owner_id: data.user.id, name: storeName, phone,
    }, { onConflict: 'owner_id' });
    if (storeError) {
      await admin.auth.admin.deleteUser(data.user.id);
      return fail('门店创建失败', 500);
    }
    return json({ ok: true });
  }
  if (input.action === 'login_password') {
    if (!phone || typeof input.password !== 'string') return fail('手机号或密码无效');
    const publicAuth = createClient(url, anonKey, { auth: { persistSession: false } });
    const { data, error } = await publicAuth.auth.signInWithPassword({
      email: emailOf(phone), password: input.password,
    });
    if (error || !data.session) return fail('手机号或密码错误', 401);
    return json({ access_token: data.session.access_token, refresh_token: data.session.refresh_token });
  }
  // TODO: Code login needs real SMS and server-side OTP verification.
  return fail('验证码登录暂未接通，请使用密码登录', 501);
}
