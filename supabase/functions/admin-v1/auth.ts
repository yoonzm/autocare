import { executeCommand } from './commands.ts';
import { emailOf, passwordProblem, sessionId, username } from './rules.ts';
import { fail, json, rpcError } from './shared.ts';
import type {
  AdminServices,
  Input,
  ReadContext,
  WriteContext,
} from './types.ts';

export const authActions = new Set(['change_password', 'logout']);

export async function handleLogin(
  input: Input,
  services: AdminServices,
): Promise<Response> {
  const name = username(input.username);
  if (!name || typeof input.password !== 'string') {
    return fail('请输入有效用户名和密码');
  }
  const { db } = services;
  // Persist attempts independently of failed authentication; never log passwords.
  const { data: allowed, error: quotaError } = await db.rpc(
    'admin_login_attempt',
    { p_key: name },
  );
  if (quotaError) return fail('登录服务暂不可用', 503);
  if (!allowed) return fail('登录尝试过多，请 15 分钟后重试', 429);
  const auth = services.publicClient();
  const { data, error } = await auth.auth.signInWithPassword({
    email: emailOf(name),
    password: input.password,
  });
  if (error || !data.session) return fail('用户名或密码错误', 401);
  const { data: me, error: identityError } = await db.rpc('admin_identity', {
    p_actor: data.user.id,
    p_session: sessionId(data.session.access_token),
  });
  if (identityError) {
    await db.auth.admin.signOut(data.session.access_token, 'local');
    return fail('该账号无运营权限或已禁用，请联系超级管理员', 403);
  }
  await db.from('admin_audit_logs').insert({
    actor_id: data.user.id,
    action: 'login',
  });
  return json({
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    me,
  });
}

export const currentAccount = (context: ReadContext): Response =>
  json({ me: context.me });

export async function handleAuth(
  action: string,
  input: Input,
  context: WriteContext,
): Promise<Response> {
  if (action !== 'change_password') {
    return executeCommand(action, input, context);
  }
  const problem = passwordProblem(input.password);
  if (problem) return fail(problem);
  const password = input.password as string;
  const { me, sessionId: sid, services, command } = context;
  const { db } = services;
  const same = await db.rpc('admin_password_matches', {
    p_actor: me.id,
    p_session: sid,
    p_password: password,
  });
  if (same.error) return fail('密码校验暂不可用，请稍后重试', 503);
  if (same.data) return fail('新密码不能与当前密码相同');
  const { error } = await db.auth.admin.updateUserById(me.id, { password });
  if (error) return fail('修改密码失败，请稍后重试', 503);
  // GoTrue may revoke the original session on password updates. Authenticate
  // again BEFORE clearing must_change, and return the replacement session.
  const signed = await services.publicClient().auth.signInWithPassword({
    email: emailOf(me.username),
    password,
  });
  const next = signed.data.session;
  if (signed.error || !next || signed.data.user?.id !== me.id) {
    return fail('密码已修改，请使用新密码重新登录完成验证', 503);
  }
  const nextId = sessionId(next.access_token);
  if (!nextId) return fail('密码已修改，请使用新密码重新登录', 503);
  const done = await command('password_changed', {}, nextId);
  if (done.error) {
    await db.auth.admin.signOut(next.access_token, 'local');
    return rpcError(done.error);
  }
  return json({
    ...done.data,
    access_token: next.access_token,
    refresh_token: next.refresh_token,
  });
}
