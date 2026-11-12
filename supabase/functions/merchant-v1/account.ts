import { createClient } from 'npm:@supabase/supabase-js@2.118.0';
import { emailOf } from './auth.ts';
import { checkOtp, consumePhoneChangeCodes } from './otp.ts';
import { publicStorageUrl } from './storage_url.ts';
import { screenshot } from './support_rules.ts';
import { admin, anonKey, fail, json, phoneOf, url, userFor, resolveSession } from './shared.ts';
import type { Input, StoreProfileRow } from './types.ts';

const PROFILE_COLUMNS =
  'name, phone, city, address, contact_name, contact_role, bay_range, business_types, plan, trial_ends_at, delete_requested_at';

/** 头像私有存储，读取时签发 1 小时链接；profile 里不暴露存储路径。 */
async function withAvatarUrl(profile: Record<string, unknown> | null) {
  if (!profile) return null;
  const { avatar_path: path, ...rest } = profile as { avatar_path?: string } & Record<string, unknown>;
  if (!path) return { ...rest, avatar_url: '' };
  const { data } = await admin.storage.from('profile-avatars').createSignedUrl(path, 3600);
  return { ...rest, avatar_url: data ? publicStorageUrl(data.signedUrl, url, Deno.env.get('SUPABASE_PUBLIC_URL') || url) : '' };
}

// Actions for a signed-in owner: profile, password, phone number and account deletion.
export async function handleAccount(input: Input, request: Request): Promise<Response> {
  const auth = await userFor(request);
  if ('response' in auth) return auth.response;
  const { user, token } = auth;
  const session = await resolveSession(user.id, token, false);
  if (session instanceof Response) return session;
  const storeId = session.store;
  // 店长等员工身份读取的是老板账号下的门店资料；账号类操作（改密、换手机、注销）网关已限定老板
  const isOwner = session.role === 'owner';
  const { data: ownerRow } = isOwner ? { data: { owner_id: user.id } } : await admin.from('stores').select('owner_id').eq('id', storeId).maybeSingle();
  const ownerId = ownerRow?.owner_id as string | undefined;
  if (!ownerId) return fail('门店不存在', 403);
  const { data: account } = await admin.from('merchant_accounts').select('phone').eq('owner_id', ownerId).single();
  const { data: store } = await admin.from('stores').select(PROFILE_COLUMNS)
    .eq('id', storeId).maybeSingle<StoreProfileRow>();
  if (!store || !account?.phone) return fail('门店不存在', 403);

  if (input.action === 'get_store') {
    const { data: subscription, error } = await admin.from('account_subscriptions').select('*').eq('owner_id', ownerId).single();
    if (error || !subscription) return fail('读取订阅失败', 500);
    const { data: version, error: versionError } = await admin.from('platform_plan_versions').select('snapshot').eq('kind', subscription.plan).eq('version', subscription.plan_version).single();
    const { count, error: quotaError } = await admin.from('stores').select('id', { count: 'exact', head: true }).eq('owner_id', ownerId).is('archived_at', null);
    if (versionError || !version || quotaError || count == null) return fail('读取订阅名额失败', 500);
    const [hours, bays] = await Promise.all([
      admin.from('appointment_settings').select('opens_at,closes_at').eq('store_id', storeId).maybeSingle(),
      admin.from('appointment_resources').select('id', { count: 'exact', head: true }).eq('store_id', storeId).eq('kind', 'bay').eq('active', true),
    ]);
    if (hours.error || bays.error || bays.count == null) return fail('读取营业时间与工位失败', 500);
    const hoursLine = (hours.data ? `${hours.data.opens_at.slice(0, 5)}–${hours.data.closes_at.slice(0, 5)}` : '未设置营业时间') + ` · ${bays.count} 工位 · 统一管理`;
    const plan = { ...subscription, ...version?.snapshot, ends_at: subscription.ends_at };
    // 员工看不到订阅价格与名额，只看套餐名称与到期时间
    const visiblePlan = isOwner ? plan : { plan: plan.plan, name: plan.name, starts_at: plan.starts_at, ends_at: plan.ends_at };
    const { data: profile } = await admin.rpc('merchant_profile_get', { p_user: ownerId, p_store: storeId, p_role: session.role, p_staff: session.staffId });
    return json({ store: { ...store, id: storeId, account_phone: isOwner ? account.phone : '', hours_line: hoursLine,
      subscription: visiblePlan, store_count: isOwner ? count : 1, profile: await withAvatarUrl(profile) } });
  }

  if (input.action === 'profile_update') {
    // 只改当前登录身份自己的姓名与邮箱；身份由会话决定，不接受客户端指定。
    const { data, error } = await admin.rpc('merchant_profile_update', {
      p_user: ownerId, p_store: storeId, p_role: session.role, p_staff: session.staffId,
      p_name: typeof input.name === 'string' ? input.name : '', p_email: typeof input.email === 'string' ? input.email : '',
    });
    if (error) return fail('保存失败，请稍后重试', 500);
    if (data?.error) return fail(data.error, data.status ?? 400);
    return json({ item: await withAvatarUrl(data) });
  }

  if (input.action === 'profile_avatar_upload') {
    // 只换当前登录身份自己的头像：先上传，再原子记录路径，最后清理旧文件。
    const file = screenshot(input.data);
    if (!file) return fail('请选择 5MB 以内的 JPEG 或 PNG 图片');
    const path = `${session.role === 'owner' ? `o-${ownerId}` : `s-${session.staffId}`}/${crypto.randomUUID()}.${file.extension}`;
    const uploaded = await admin.storage.from('profile-avatars').upload(path, file.bytes, { contentType: file.mime, upsert: false });
    if (uploaded.error) return fail('头像上传失败，请重试', 503);
    const { data, error } = await admin.rpc('merchant_profile_set_avatar', {
      p_user: ownerId, p_store: storeId, p_role: session.role, p_staff: session.staffId, p_path: path,
    });
    if (error || data?.error) {
      await admin.storage.from('profile-avatars').remove([path]);
      return error ? fail('头像保存失败，请稍后重试', 500) : fail(data.error, data.status ?? 400);
    }
    if (data.old) await admin.storage.from('profile-avatars').remove([data.old]);
    return json({ item: { avatar_url: (await withAvatarUrl({ avatar_path: path }))?.avatar_url } });
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
    // 立即注销（无冷静期）：只改账号——记录注销、释放手机号、停用登录并让所有设备退出；门店等业务数据不动。
    // 同一手机号之后重新注册是一个全新的账号。
    const problem = await checkOtp(account.phone, input.code, 'delete_account', true);
    if (problem) return fail(problem);
    const { error } = await admin.rpc('account_cancel_self', { p_user: ownerId });
    if (error) return fail('注销失败，请稍后重试', 500);
    return json({ ok: true });
  }

  return fail('不支持的操作');
}
