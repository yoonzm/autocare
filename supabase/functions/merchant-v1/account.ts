import { createClient } from 'npm:@supabase/supabase-js@2.118.0';
import { emailOf } from './auth.ts';
import { checkOtp, consumePhoneChangeCodes } from './otp.ts';
import { admin, anonKey, fail, json, phoneOf, url, userFor, merchantSession } from './shared.ts';
import type { Input, StoreProfileRow } from './types.ts';

const PROFILE_COLUMNS =
  'name, phone, city, address, contact_name, contact_role, bay_range, business_types, plan, trial_ends_at, delete_requested_at';

// Actions for a signed-in owner: profile, password, phone number and account deletion.
export async function handleAccount(input: Input, request: Request): Promise<Response> {
  const auth = await userFor(request);
  if ('response' in auth) return auth.response;
  const { user, token } = auth;
  const storeId = await merchantSession(user.id, token, false);
  if (storeId instanceof Response) return storeId;
  const { data: account } = await admin.from('merchant_accounts').select('phone').eq('owner_id', user.id).single();
  const { data: store } = await admin.from('stores').select(PROFILE_COLUMNS)
    .eq('id', storeId).maybeSingle<StoreProfileRow>();
  if (!store || !account?.phone) return fail('门店不存在', 403);

  if (input.action === 'get_store') {
    const { data: subscription, error } = await admin.from('account_subscriptions').select('*').eq('owner_id', user.id).single();
    if (error || !subscription) return fail('读取订阅失败', 500);
    const { data: version, error: versionError } = await admin.from('platform_plan_versions').select('snapshot').eq('kind', subscription.plan).eq('version', subscription.plan_version).single();
    const { count, error: quotaError } = await admin.from('stores').select('id', { count: 'exact', head: true }).eq('owner_id', user.id).is('archived_at', null);
    if (versionError || !version || quotaError || count == null) return fail('读取订阅名额失败', 500);
    const [hours, bays] = await Promise.all([
      admin.from('appointment_settings').select('opens_at,closes_at').eq('store_id', storeId).maybeSingle(),
      admin.from('appointment_resources').select('id', { count: 'exact', head: true }).eq('store_id', storeId).eq('kind', 'bay').eq('active', true),
    ]);
    if (hours.error || bays.error || bays.count == null) return fail('读取营业时间与工位失败', 500);
    const hoursLine = (hours.data ? `${hours.data.opens_at.slice(0, 5)}–${hours.data.closes_at.slice(0, 5)}` : '未设置营业时间') + ` · ${bays.count} 工位 · 统一管理`;
    return json({ store: { ...store, id: storeId, account_phone: account.phone, hours_line: hoursLine,
      subscription: { ...subscription, ...version?.snapshot, ends_at: subscription.ends_at }, store_count: count } });
  }

  if (input.action === 'change_password') {
    const oldPw = input.old_password;
    const newPw = input.new_password;
    if (typeof oldPw !== 'string' || typeof newPw !== 'string' || !oldPw) return fail('请输入当前密码');
    if (newPw.length < 8 || newPw.length > 20 || !/[a-zA-Z]/.test(newPw) || !/\d/.test(newPw)) {
      return fail('新密码需 8–20 位，且同时包含字母和数字');
    }
    if (newPw === oldPw) return fail('新密码不能与当前密码相同');
    const digits = account.phone.replace(/\D/g, '').slice(-11);
    for (let i = 0; i + 6 <= digits.length; i++) {
      if (newPw.includes(digits.slice(i, i + 6))) return fail('新密码不能包含手机号中的连续数字');
    }
    const publicAuth = createClient(url, anonKey, { auth: { persistSession: false } });
    const { error: verifyError } = await publicAuth.auth.signInWithPassword({
      email: user.email ?? emailOf(account.phone), password: oldPw,
    });
    if (verifyError) return fail('当前密码错误', 403);
    const { error } = await admin.auth.admin.updateUserById(user.id, { password: newPw });
    if (error) return fail('修改失败，请稍后重试', 500);
    return json({ ok: true });
  }

  if (input.action === 'change_phone') {
    const next = phoneOf(input.new_phone);
    if (!next) return fail('请输入正确的新手机号');
    if (next === account.phone) return fail('新手机号不能与当前手机号相同');
    const { data: taken } = await admin.from('merchant_accounts').select('owner_id').eq('phone', next).maybeSingle();
    if (taken) return fail('该手机号已注册', 409);
    const problem = await consumePhoneChangeCodes(account.phone, input.code, next, input.new_code);
    if (problem) return fail(problem);
    const { error } = await admin.auth.admin.updateUserById(user.id, {
      phone: next, email: emailOf(next), phone_confirm: true, email_confirm: true,
    });
    if (error) return fail('该手机号已被占用，或更换失败', 409);
    const { error: storeError } = await admin.from('merchant_accounts').update({ phone: next }).eq('owner_id', user.id);
    if (storeError) {
      await admin.auth.admin.updateUserById(user.id, {
        phone: account.phone, email: emailOf(account.phone), phone_confirm: true, email_confirm: true,
      });
      return fail('更换失败，请稍后重试', 500);
    }
    return json({ ok: true });
  }

  if (input.action === 'delete_account') {
    // Starts the 15-day cooling-off period; signing in again withdraws it.
    // TODO: purge the account and its data once the period ends (scheduled job).
    const problem = await checkOtp(account.phone, input.code, 'delete_account', true);
    if (problem) return fail(problem);
    const { error } = await admin.from('stores')
      .update({ delete_requested_at: new Date().toISOString() }).eq('owner_id', user.id);
    if (error) return fail('提交失败，请稍后重试', 500);
    await admin.auth.admin.signOut(token, 'global');
    return json({ ok: true });
  }

  return fail('不支持的操作');
}
