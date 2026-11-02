import { createClient } from 'npm:@supabase/supabase-js@2.118.0';
import { admin, anonKey, fail, json, mockSmsEnabled, nameOf, phoneOf, url } from './shared.ts';
import { DEFAULT_CARDS, defaultPackages, defaultServices } from './defaults.ts';
import type { Input } from './types.ts';

// TODO: Replace the development alias with native phone auth after SMS is configured.
export const emailOf = (phone: string) => `merchant+${phone.slice(3)}@example.com`;

const TRIAL_DAYS = 14;
const OTP_TTL_MS = 5 * 60 * 1000;
const SMS_DAILY_LIMIT = 10;

// Calendar day in China (UTC+8), used for the per-phone daily send limit.
const chinaToday = () => new Date(Date.now() + 8 * 3600_000).toISOString().slice(0, 10);

// Password rules shared by sign-up, change and reset (client mirrors them).
function passwordProblem(password: unknown, phone: string): string | null {
  if (typeof password !== 'string' || password.length < 8 || password.length > 20 ||
      !/[a-zA-Z]/.test(password) || !/\d/.test(password)) {
    return '新密码需 8–20 位，且同时包含字母和数字';
  }
  const digits = phone.replace(/\D/g, '').slice(-11);
  for (let i = 0; i + 6 <= digits.length; i++) {
    if (password.includes(digits.slice(i, i + 6))) return '新密码不能包含手机号中的连续数字';
  }
  return null;
}
const OTP_RESEND_MS = 60 * 1000;
const OTP_MAX_ATTEMPTS = 5;

const sha256 = async (text: string) =>
  Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text))))
    .map((b) => b.toString(16).padStart(2, '0')).join('');
const hashOf = (phone: string, code: string) => sha256(`${phone}:${code}`);

// Uniformly random 6 digits (rejection sampling avoids modulo bias).
function randomCode(): string {
  const buf = new Uint32Array(1);
  const limit = 4294967296 - (4294967296 % 1000000);
  do crypto.getRandomValues(buf); while (buf[0] >= limit);
  return String(buf[0] % 1000000).padStart(6, '0');
}

// Returns an error message, or null when the code is valid. A wrong guess burns an attempt.
export async function checkOtp(phone: string, code: unknown): Promise<string | null> {
  if (typeof code !== 'string' || !/^\d{6}$/.test(code)) return '请输入 6 位数字验证码';
  const { data: row, error } = await admin.from('phone_otps')
    .select('code_hash, expires_at, attempts').eq('phone', phone).maybeSingle();
  if (error) return '验证码校验失败，请稍后重试';
  if (!row) return '请先获取验证码';
  if (new Date(row.expires_at).getTime() < Date.now()) return '验证码已过期，请重新获取';
  if (row.attempts >= OTP_MAX_ATTEMPTS) return '验证码错误次数过多，请重新获取';
  if (row.code_hash !== await hashOf(phone, code)) {
    await admin.from('phone_otps').update({ attempts: row.attempts + 1 }).eq('phone', phone);
    return '验证码错误';
  }
  return null;
}

// Signing in again during the cooling-off period withdraws a deletion request.
const cancelDeletion = (userId: string) =>
  admin.from('stores').update({ delete_requested_at: null }).eq('owner_id', userId);

const CITY_MAX = 60;
const ROLES = ['老板', '店长', '前台'];
const BAYS = ['1-3 个', '4-6 个', '7-10 个', '10 个以上'];
const BUSINESS = ['洗车美容', '镀晶镀膜', '隐形车衣', '改色膜', '保养维修'];

// Validates the sign-up profile; returns the columns to store or an error message.
function profileOf(input: Input) {
  const city = nameOf(input.city);
  const address = nameOf(input.address);
  const contact = nameOf(input.contact_name);
  const role = nameOf(input.contact_role);
  const bays = nameOf(input.bay_range);
  const business = Array.isArray(input.business_types) ? input.business_types : [];
  if (!city || city.length > CITY_MAX) return '请选择所在城市';
  if (address.length > 200) return '详细地址不能超过 200 字';
  if (!contact || contact.length > 30) return '请填写联系人姓名';
  if (!ROLES.includes(role)) return '请选择您的身份';
  if (!BAYS.includes(bays)) return '请选择工位数量';
  if (business.length < 1 || !business.every((b) => typeof b === 'string' && BUSINESS.includes(b))) {
    return '请至少选择一项主营业务';
  }
  return {
    city, address, contact_name: contact, contact_role: role,
    bay_range: bays, business_types: [...new Set(business as string[])],
  };
}

export async function handleAuth(input: Input): Promise<Response> {
  const phone = phoneOf(input.phone);
  if (input.action === 'send_mock_code') {
    // TODO: Replace with a rate-limited SMS provider before production.
    if (!mockSmsEnabled()) return fail('短信服务尚未启用', 501);
    if (!phone) return fail('请输入有效手机号');
    const { data: prev } = await admin.from('phone_otps')
      .select('created_at').eq('phone', phone).maybeSingle();
    if (prev) {
      const wait = OTP_RESEND_MS - (Date.now() - new Date(prev.created_at).getTime());
      if (wait > 0) return fail(`请 ${Math.ceil(wait / 1000)} 秒后再获取验证码`, 429);
    }
    const { data: allowed, error: quotaError } = await admin.rpc('take_sms_quota', {
      p_phone: phone, p_day: chinaToday(), p_limit: SMS_DAILY_LIMIT,
    });
    if (quotaError) return fail('验证码生成失败', 500);
    if (!allowed) return fail('今日发送次数已达上限', 429);
    const code = randomCode();
    const { error } = await admin.from('phone_otps').upsert({
      phone,
      code_hash: await hashOf(phone, code),
      expires_at: new Date(Date.now() + OTP_TTL_MS).toISOString(),
      attempts: 0,
      created_at: new Date().toISOString(),
    }, { onConflict: 'phone' });
    if (error) return fail('验证码生成失败', 500);
    // The mock SMS channel returns the code to the caller; a real provider would text it instead.
    return json({ code, mock: true });
  }
  if (input.action === 'check_code') {
    // Non-consuming check so the sign-up form can reject a wrong code before the last step.
    if (!phone) return fail('请输入有效手机号');
    const problem = await checkOtp(phone, input.code);
    return problem ? fail(problem) : json({ ok: true });
  }
  if (input.action === 'forgot_verify') {
    // Step 1 of "forgot password": the code must be valid and the phone must belong to a store.
    if (!mockSmsEnabled()) return fail('生产级验证码待接入短信服务', 501);
    if (!phone) return fail('请输入有效手机号');
    const problem = await checkOtp(phone, input.code);
    if (problem) return fail(problem);
    const { data: store } = await admin.from('stores').select('id').eq('phone', phone).maybeSingle();
    if (!store) return fail('该手机号尚未开通门店账号', 404);
    return json({ ok: true });
  }
  if (input.action === 'reset_password') {
    // Step 2: verifies the code again (single use), sets the new password and signs out everywhere.
    if (!mockSmsEnabled()) return fail('生产级验证码待接入短信服务', 501);
    if (!phone) return fail('请输入有效手机号');
    const badPassword = passwordProblem(input.new_password, phone);
    if (badPassword) return fail(badPassword);
    const problem = await checkOtp(phone, input.code);
    if (problem) return fail(problem);
    const { data: store } = await admin.from('stores').select('owner_id').eq('phone', phone).maybeSingle();
    if (!store) return fail('该手机号尚未开通门店账号', 404);
    const { error } = await admin.auth.admin.updateUserById(store.owner_id, {
      password: input.new_password as string,
    });
    if (error) return fail('重置失败，请稍后重试', 500);
    // Every device must sign in again with the new password.
    const { error: revokeError } = await admin.rpc('revoke_user_sessions', { p_user: store.owner_id });
    if (revokeError) return fail('重置失败，请稍后重试', 500);
    await admin.from('phone_otps').delete().eq('phone', phone); // single use
    return json({ ok: true });
  }
  if (input.action === 'register') {
    if (!mockSmsEnabled()) return fail('生产级手机注册待接入短信服务', 501);
    if (!phone) return fail('请输入有效手机号');
    const password = input.password;
    const storeName = nameOf(input.store_name);
    if (typeof password !== 'string' || password.length < 8 || password.length > 72 ||
        !/[a-zA-Z]/.test(password) || !/\d/.test(password) ||
        storeName.length < 1 || storeName.length > 100) {
      return fail('请填写门店名称和 8–72 位含字母、数字的密码');
    }
    const profile = profileOf(input);
    if (typeof profile === 'string') return fail(profile);
    const otpProblem = await checkOtp(phone, input.code);
    if (otpProblem) return fail(otpProblem);
    const { data, error } = await admin.auth.admin.createUser({
      phone, email: emailOf(phone), password, phone_confirm: true, email_confirm: true,
    });
    if (error || !data.user) {
      const taken = error?.code === 'phone_exists' || error?.code === 'email_exists' ||
        /already|registered|exists/i.test(error?.message ?? '');
      return fail(taken ? '该手机号已注册，请直接登录' : '注册失败，请稍后重试', taken ? 409 : 500);
    }
    const { data: store, error: storeError } = await admin.from('stores').upsert({
      owner_id: data.user.id, name: storeName, phone, ...profile,
      plan: 'trial',
      trial_ends_at: new Date(Date.now() + TRIAL_DAYS * 86400000).toISOString(),
    }, { onConflict: 'owner_id' }).select('id').single();
    if (storeError || !store) {
      await admin.auth.admin.deleteUser(data.user.id);
      return fail('门店创建失败', 500);
    }
    // Starter data: services for the chosen business types, the four default card tiers and
    // the design's packages (only those whose services were created).
    const services = defaultServices(profile.business_types);
    const { data: createdServices, error: serviceError } = await admin.from('service_items')
      .insert(services.map((s) => ({ ...s, store_id: store.id }))).select('id, name');
    const { error: cardError } = serviceError ? { error: null } : await admin.from('card_types')
      .insert(DEFAULT_CARDS.map((c) => ({ ...c, store_id: store.id })));
    const idByName = new Map((createdServices ?? []).map((s) => [s.name as string, s.id as string]));
    const packages = defaultPackages([...idByName.keys()]);
    let packageFailed = false;
    if (!serviceError && !cardError) {
      for (const p of packages) {
        const { error: packageError } = await admin.rpc('save_card_package', {
          p_store: store.id,
          p_id: null,
          p_values: {
            name: p.name, price: p.price, validity_months: p.validity_months,
            purchase_limit: null, vehicle_scope: '全部车型', show_in_mini: true,
            description: '', active: p.active,
          },
          p_items: p.items.map((i) => ({ service_id: idByName.get(i.service), count: i.count })),
        });
        if (packageError) {
          packageFailed = true;
          break;
        }
      }
    }
    if (serviceError || cardError || packageFailed) {
      // The store and its data cascade from the user, so deleting the user rolls everything back.
      await admin.auth.admin.deleteUser(data.user.id);
      return fail('门店初始化失败，请稍后重试', 500);
    }
    await admin.from('phone_otps').delete().eq('phone', phone); // single use
    return json({ ok: true, services: services.length, cards: DEFAULT_CARDS.length, packages: packages.length });
  }
  if (input.action === 'login_password') {
    if (!phone || typeof input.password !== 'string') return fail('手机号或密码无效');
    const publicAuth = createClient(url, anonKey, { auth: { persistSession: false } });
    const { data, error } = await publicAuth.auth.signInWithPassword({
      email: emailOf(phone), password: input.password,
    });
    if (error || !data.session) return fail('手机号或密码错误', 401);
    await cancelDeletion(data.user.id);
    return json({ access_token: data.session.access_token, refresh_token: data.session.refresh_token });
  }
  if (input.action === 'login_code') {
    // TODO: Real SMS delivery. Verification itself is server-side and single use.
    if (!mockSmsEnabled()) return fail('生产级验证码登录待接入短信服务', 501);
    if (!phone) return fail('请输入有效手机号');
    const problem = await checkOtp(phone, input.code);
    if (problem) return fail(problem);
    // generateLink would silently create a user for an unknown email, so look the store up first.
    const { data: store } = await admin.from('stores').select('id').eq('phone', phone).maybeSingle();
    if (!store) return fail('该手机号尚未注册，请先免费开通', 404);
    const { data: link, error: linkError } = await admin.auth.admin.generateLink({
      type: 'magiclink', email: emailOf(phone),
    });
    const tokenHash = link?.properties?.hashed_token;
    if (linkError || !tokenHash) return fail('登录失败，请稍后重试', 500);
    const publicAuth = createClient(url, anonKey, { auth: { persistSession: false } });
    const { data, error } = await publicAuth.auth.verifyOtp({ token_hash: tokenHash, type: 'magiclink' });
    if (error || !data.session) return fail('登录失败，请稍后重试', 500);
    await admin.from('phone_otps').delete().eq('phone', phone); // single use
    await cancelDeletion(data.session.user.id);
    return json({ access_token: data.session.access_token, refresh_token: data.session.refresh_token });
  }
  return fail('不支持的操作');
}
