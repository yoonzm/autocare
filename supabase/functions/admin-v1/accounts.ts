import { executeCommand } from './commands.ts';
import { emailOf, passwordProblem, username } from './rules.ts';
import { fail, json, rpcError } from './shared.ts';
import type { Input, WriteContext } from './types.ts';

export const accountActions = new Set([
  'account_create',
  'account_reset',
  'account_role',
  'account_enabled',
]);

export async function handleAccounts(
  action: string,
  input: Input,
  context: WriteContext,
): Promise<Response> {
  const { db } = context.services;
  if (action === 'account_create') {
    const name = username(input.username);
    const problem = passwordProblem(input.password);
    const role = input.role;
    if (
      !name || typeof input.name !== 'string' || !input.name.trim() ||
      input.name.trim().length > 50 || (role !== 'ops' && role !== 'superAdmin')
    ) {
      return fail('请填写有效姓名、用户名和角色');
    }
    if (problem) return fail(problem);
    const created = await db.auth.admin.createUser({
      email: emailOf(name),
      password: input.password as string,
      email_confirm: true,
    });
    if (created.error || !created.data.user) {
      return fail('用户名已存在或账号创建失败', 409);
    }
    const done = await context.command(action, {
      id: created.data.user.id,
      username: name,
      name: input.name.trim(),
      role,
    });
    if (done.error) {
      // An Auth user without an admin profile has no privileges. Compensate.
      await db.auth.admin.deleteUser(created.data.user.id);
      return rpcError(done.error);
    }
    return json(done.data);
  }
  if (action === 'account_reset') {
    const temporary = `Ac9!${crypto.randomUUID().replaceAll('-', '')}`;
    // SQL restricts the account and revokes sessions BEFORE changing its password.
    const done = await context.command(action, { id: input.id });
    if (done.error) return rpcError(done.error);
    if (done.data.replayed) {
      return fail('该重置请求已处理，请重新发起重置', 409);
    }
    const { error } = await db.auth.admin.updateUserById(input.id as string, {
      password: temporary,
    });
    if (error) return fail('密码重置未完成，账号已要求改密，请重试', 503);
    return json({ temporary_password: temporary });
  }
  // Role and enabled-state transitions, including last-super protection, stay in SQL.
  return executeCommand(action, input, context);
}
