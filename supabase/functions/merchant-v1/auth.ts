import { registrationCity } from './regions.ts';
import { createClient } from 'npm:@supabase/supabase-js@2.118.0';
import { admin, anonKey, fail, failCode, json, merchantSession, nameOf, phoneOf, url, userFor } from './shared.ts';
import { BAY_COUNTS } from './defaults.ts';
import type { Input } from './types.ts';
import { checkOtp, otpHash, otpStore, randomOtp } from './otp.ts';
import { isSmsPurpose, sendOtp, SmsError, smsProvider } from './sms.ts';

// Keep account aliases compatible with existing users; application OTPs use the configured SMS channel.
export const emailOf = (phone: string) => `merchant+${phone.slice(3)}@example.com`;

const TRIAL_DAYS = 14;
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
// Signing in again during the cooling-off period withdraws a deletion request.
const cancelDeletion = (userId: string) =>
  admin.from('stores').update({ delete_requested_at: null }).eq('owner_id', userId);

const ROLES = ['老板', '店长', '前台'];
const BAYS = Object.keys(BAY_COUNTS);
const BUSINESS = ['洗车美容', '镀晶镀膜', '隐形车衣', '改色膜', '保养维修'];

// Validates the sign-up profile; returns the columns to store or an error message.
function profileOf(input: Input) {
  const address = nameOf(input.address);
  const contact = nameOf(input.contact_name);
  const role = nameOf(input.contact_role);
  const bays = nameOf(input.bay_range);
  const business = Array.isArray(input.business_types) ? input.business_types : [];
  if (address.length > 200) return '详细地址不能超过 200 字';
  if (!contact || contact.length > 30) return '请填写联系人姓名';
  if (!ROLES.includes(role)) return '请选择您的身份';
  if (!BAYS.includes(bays)) return '请选择工位数量';
  if (business.length < 1 || !business.every((b) => typeof b === 'string' && BUSINESS.includes(b))) {
    return '请至少选择一项主营业务';
  }
  return {
    address, contact_name: contact, contact_role: role,
    bay_range: bays, business_types: [...new Set(business as string[])],
  };
}

/** 手机号是否登记为某家门店的员工（待加入 / 在职）。验证码登录据此给员工创建账号。 */
async function hasStaffIdentity(phone: string): Promise<boolean> {
  const { data, error } = await admin.rpc('staff_login_exists', { p_phone: phone.slice(-11) });
  return !error && data === true;
}

export async function handleAuth(input: Input, request: Request): Promise<Response> {
  const phone = phoneOf(input.phone);
  if (input.action === 'send_code') {
    if (!phone) return fail('请输入有效手机号');
    const purpose = input.purpose ?? 'register';
    if (!isSmsPurpose(purpose)) return fail('不支持的验证码用途');
    if (['change_phone_old', 'change_phone_new', 'delete_account'].includes(purpose)) {
      const auth = await userFor(request);
      if ('response' in auth) return auth.response;
      const { data: store, error } = await admin.from('merchant_accounts').select('phone').eq('owner_id', auth.user.id).single();
      if (error || !store) return fail('门店不存在', 403);
      if (purpose !== 'change_phone_new' && store.phone !== phone) return fail('只能向当前账号绑定的手机号发送验证码', 403);
      if (purpose === 'change_phone_new' && store.phone === phone) return fail('新手机号不能与当前手机号相同');
    }
    const { data: existing, error: lookupError } = await admin.from('merchant_accounts').select('owner_id').eq('phone', phone).maybeSingle();
    if (lookupError) return fail('短信暂时不可用，请稍后重试', 503);
    if ((purpose === 'register' || purpose === 'change_phone_new') && existing) return fail('该手机号已注册', 409);
    if (purpose === 'login' && !existing && !(await hasStaffIdentity(phone))) return failCode('该手机号尚未开通门店账号', 404, 'phone_unregistered');
    if (purpose === 'reset_password' && !existing) return fail('该手机号尚未开通门店账号', 404);
    try {
      const provider = smsProvider(name => Deno.env.get(name), purpose);
      const code = randomOtp();
      return json(await sendOtp(provider, otpStore, {
        phone, purpose, code, hash: await otpHash(phone, purpose, code), requestId: crypto.randomUUID(),
      }));
    } catch (error) {
      return error instanceof SmsError ? fail(error.message, error.status) : fail('短信暂时不可用，请稍后重试', 503);
    }
  }
  if (input.action === 'check_code') {
    // Non-consuming check so the sign-up form can reject a wrong code before the last step.
    if (!phone) return fail('请输入有效手机号');
    const problem = await checkOtp(phone, input.code, 'register');
    return problem ? fail(problem) : json({ ok: true });
  }
  if (input.action === 'forgot_verify') {
    // Step 1 of "forgot password": the code must be valid and the phone must belong to a store.
    if (!phone) return fail('请输入有效手机号');
    const problem = await checkOtp(phone, input.code, 'reset_password');
    if (problem) return fail(problem);
    const { data: store } = await admin.from('merchant_accounts').select('owner_id').eq('phone', phone).maybeSingle();
    if (!store) return fail('该手机号尚未开通门店账号', 404);
    return json({ ok: true });
  }
  if (input.action === 'reset_password') {
    // Step 2: verifies the code again (single use), sets the new password and signs out everywhere.
    if (!phone) return fail('请输入有效手机号');
    const badPassword = passwordProblem(input.new_password, phone);
    if (badPassword) return fail(badPassword);
    const problem = await checkOtp(phone, input.code, 'reset_password', true);
    if (problem) return fail(problem);
    const { data: store } = await admin.from('merchant_accounts').select('owner_id').eq('phone', phone).maybeSingle();
    if (!store) return fail('该手机号尚未开通门店账号', 404);
    const { error } = await admin.auth.admin.updateUserById(store.owner_id, {
      password: input.new_password as string,
    });
    if (error) return fail('重置失败，请稍后重试', 500);
    // Every device must sign in again with the new password.
    const { error: revokeError } = await admin.rpc('revoke_user_sessions', { p_user: store.owner_id });
    if (revokeError) return fail('重置失败，请稍后重试', 500);
    return json({ ok: true });
  }
  if (input.action === 'register') {
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
    const location = await registrationCity(input);
    if (location instanceof Response) return location;
    const otpProblem = await checkOtp(phone, input.code, 'register', true);
    if (otpProblem) return fail(otpProblem);
    const { data, error } = await admin.auth.admin.createUser({
      phone, email: emailOf(phone), password, phone_confirm: true, email_confirm: true,
    });
    if (error || !data.user) {
      const taken = error?.code === 'phone_exists' || error?.code === 'email_exists' ||
        /already|registered|exists/i.test(error?.message ?? '');
      return fail(taken ? '该手机号已注册，请直接登录' : '注册失败，请稍后重试', taken ? 409 : 500);
    }
    const { data: store, error: storeError } = await admin.from('stores').insert({
      owner_id: data.user.id, name: storeName, phone, ...profile, ...location,
      plan: 'trial',
      trial_ends_at: new Date(Date.now() + TRIAL_DAYS * 86400000).toISOString(),
    }).select('id').single();
    if (storeError || !store) {
      await admin.auth.admin.deleteUser(data.user.id);
      return fail('门店创建失败', 500);
    }
    // Registration and subsequent stores use exactly the same DB template.
    const { data: initialized, error: initializationError } = await admin.rpc('initialize_store_catalog', { p_store: store.id });
    if (initializationError || !initialized) {
      await admin.auth.admin.deleteUser(data.user.id);
      return fail('门店初始化失败，请稍后重试', 500);
    }
    return json({ ok: true, ...initialized });
  }
  if (input.action === 'login_password') {
    if (!phone || typeof input.password !== 'string') return fail('手机号或密码无效');
    const publicAuth = createClient(url, anonKey, { auth: { persistSession: false } });
    const { data, error } = await publicAuth.auth.signInWithPassword({
      email: emailOf(phone), password: input.password,
    });
    if (error || !data.session) return fail('手机号或密码错误', 401);
    const state=await merchantSession(data.session.user.id,data.session.access_token,false);
    if(state instanceof Response){await admin.auth.admin.signOut(data.session.access_token,'local');return state;}
    await cancelDeletion(data.user.id);
    return json({ access_token: data.session.access_token, refresh_token: data.session.refresh_token, staff: await hasStaffIdentity(phone) });
  }
  if (input.action === 'login_code') {
    if (!phone) return fail('请输入有效手机号');
    const problem = await checkOtp(phone, input.code, 'login', true);
    if (problem) return fail(problem);
    // generateLink would silently create a user for an unknown email, so look the store up first.
    const { data: store } = await admin.from('merchant_accounts').select('owner_id').eq('phone', phone).maybeSingle();
    const staff = !store && await hasStaffIdentity(phone);
    if (!store && !staff) return failCode('该手机号尚未注册，请先免费开通', 404, 'phone_unregistered');
    if (staff) {
      // 员工首次验证码登录：为该手机号创建登录账号（已存在则忽略）。账号无密码，只能验证码登录。
      const created = await admin.auth.admin.createUser({ phone, email: emailOf(phone), phone_confirm: true, email_confirm: true });
      const exists = created.error?.code === 'phone_exists' || created.error?.code === 'email_exists' ||
        /already|registered|exists/i.test(created.error?.message ?? '');
      if (created.error && !exists) return fail('登录失败，请稍后重试', 500);
    }
    const { data: link, error: linkError } = await admin.auth.admin.generateLink({
      type: 'magiclink', email: emailOf(phone),
    });
    const tokenHash = link?.properties?.hashed_token;
    if (linkError || !tokenHash) return fail('登录失败，请稍后重试', 500);
    const publicAuth = createClient(url, anonKey, { auth: { persistSession: false } });
    const { data, error } = await publicAuth.auth.verifyOtp({ token_hash: tokenHash, type: 'magiclink' });
    if (error || !data.session) return fail('登录失败，请稍后重试', 500);
    // 老板需有可用门店；纯员工账号此时还没选身份，交给登录后的身份选择
    const state=await merchantSession(data.session.user.id,data.session.access_token,false);
    if(state instanceof Response&&!staff){await admin.auth.admin.signOut(data.session.access_token,'local');return state;}
    if(!staff)await cancelDeletion(data.session.user.id);
    return json({ access_token: data.session.access_token, refresh_token: data.session.refresh_token, staff: !!staff || await hasStaffIdentity(phone) });
  }
  return fail('不支持的操作');
}
