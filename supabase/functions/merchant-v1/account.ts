import { createClient } from 'npm:@supabase/supabase-js@2.118.0';
import { checkOtp, emailOf } from './auth.ts';
import { admin, anonKey, fail, json, mockSmsEnabled, phoneOf, url, userFor } from './shared.ts';
import type { Input, StoreProfileRow } from './types.ts';

const PROFILE_COLUMNS =
  'name, phone, city, address, contact_name, contact_role, bay_range, business_types, plan, trial_ends_at, delete_requested_at';

// Actions for a signed-in owner: profile, password, phone number and account deletion.
export async function handleAccount(input: Input, request: Request): Promise<Response> {
  const auth = await userFor(request);
  if ('response' in auth) return auth.response;
  const { user, token } = auth;
  const { data: store } = await admin.from('stores').select(PROFILE_COLUMNS)
    .eq('owner_id', user.id).maybeSingle<StoreProfileRow>();
  if (!store || !store.phone) return fail('门店不存在', 403);

  if (input.action === 'get_store') return json({ store });

  if (input.action === 'change_password') {
    const oldPw = input.old_password;
    const newPw = input.new_password;
    if (typeof oldPw !== 'string' || typeof newPw !== 'string' || !oldPw) return fail('请输入当前密码');
    if (newPw.length < 8 || newPw.length > 20 || !/[a-zA-Z]/.test(newPw) || !/\d/.test(newPw)) {
      return fail('新密码需 8–20 位，且同时包含字母和数字');
    }
    if (newPw === oldPw) return fail('新密码不能与当前密码相同');
    const digits = store.phone.replace(/\D/g, '').slice(-11);
    for (let i = 0; i + 6 <= digits.length; i++) {
      if (newPw.includes(digits.slice(i, i + 6))) return fail('新密码不能包含手机号中的连续数字');
    }
    const publicAuth = createClient(url, anonKey, { auth: { persistSession: false } });
    const { error: verifyError } = await publicAuth.auth.signInWithPassword({
      email: user.email ?? emailOf(store.phone), password: oldPw,
    });
    if (verifyError) return fail('当前密码错误', 403);
    const { error } = await admin.auth.admin.updateUserById(user.id, { password: newPw });
    if (error) return fail('修改失败，请稍后重试', 500);
    return json({ ok: true });
  }

  if (input.action === 'change_phone') {
    // TODO: Replace mock SMS with a real provider; both codes are verified server-side.
    if (!mockSmsEnabled()) return fail('生产级手机号更换待接入短信服务', 501);
    const next = phoneOf(input.new_phone);
    if (!next) return fail('请输入正确的新手机号');
    if (next === store.phone) return fail('新手机号不能与当前手机号相同');
    const oldProblem = await checkOtp(store.phone, input.code);
    if (oldProblem) return fail(`当前号码：${oldProblem}`);
    const newProblem = await checkOtp(next, input.new_code);
    if (newProblem) return fail(`新号码：${newProblem}`);
    const { data: taken } = await admin.from('stores').select('id').eq('phone', next).maybeSingle();
    if (taken) return fail('该手机号已注册', 409);
    const { error } = await admin.auth.admin.updateUserById(user.id, {
      phone: next, email: emailOf(next), phone_confirm: true, email_confirm: true,
    });
    if (error) return fail('该手机号已被占用，或更换失败', 409);
    const { error: storeError } = await admin.from('stores').update({ phone: next }).eq('owner_id', user.id);
    if (storeError) {
      await admin.auth.admin.updateUserById(user.id, {
        phone: store.phone, email: emailOf(store.phone), phone_confirm: true, email_confirm: true,
      });
      return fail('更换失败，请稍后重试', 500);
    }
    await admin.from('phone_otps').delete().in('phone', [store.phone, next]);
    return json({ ok: true });
  }

  if (input.action === 'delete_account') {
    // Starts the 15-day cooling-off period; signing in again withdraws it.
    // TODO: purge the account and its data once the period ends (scheduled job).
    if (!mockSmsEnabled()) return fail('生产级账号注销待接入短信服务', 501);
    const problem = await checkOtp(store.phone, input.code);
    if (problem) return fail(problem);
    const { error } = await admin.from('stores')
      .update({ delete_requested_at: new Date().toISOString() }).eq('owner_id', user.id);
    if (error) return fail('提交失败，请稍后重试', 500);
    await admin.from('phone_otps').delete().eq('phone', store.phone);
    await admin.auth.admin.signOut(token, 'global');
    return json({ ok: true });
  }

  return fail('不支持的操作');
}
