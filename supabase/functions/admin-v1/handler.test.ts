import type { SupabaseClient } from './deps.ts';
import { createHandler, handler } from './index.ts';
import { SmsDeliveryError } from './sms.ts';
import type { AdminAccount, AdminServices, Input, RpcError } from './types.ts';

const actor = '00000000-0000-4000-8000-000000000001';
const oldSession = '00000000-0000-4000-8000-000000000002';
const newSession = '00000000-0000-4000-8000-000000000003';
const requestId = '00000000-0000-4000-8000-000000000004';
const target = '00000000-0000-4000-8000-000000000005';
const token = (sid = oldSession) =>
  `e30.${btoa(JSON.stringify({ session_id: sid }))}.signature`;
type Result = { data: unknown; error: RpcError | null };
const ok = (data: unknown): Result => ({ data, error: null });
const failed = (code: string, message = 'Business rejection'): Result => ({
  data: null,
  error: { code, message },
});
const equal = (actual: unknown, expected: unknown) => {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
};
function assert(value: unknown, message = 'Assertion failed'): asserts value {
  if (!value) throw new Error(message);
}

/** Isolated transport fixtures only. No environment credentials, network, or paid SMS. */
function fixture() {
  const me: AdminAccount = {
    id: actor,
    username: 'test_admin',
    name: 'Test administrator',
    role: 'superAdmin',
    enabled: true,
    must_change: false,
  };
  const calls: { name: string; input: Input }[] = [];
  const hooks = new Map<string, (input: Input) => Result | Promise<Result>>();
  function result(
    name: string,
    input: Input,
    fallback: unknown,
  ): Promise<Result> {
    calls.push({ name, input });
    return Promise.resolve(hooks.get(name)?.(input) ?? ok(fallback));
  }
  const auth = {
    getUser: (accessToken: string) =>
      result('auth.getUser', { token: accessToken }, { user: { id: actor } }),
    admin: {
      signOut: (accessToken: string, scope: string) =>
        result('auth.signOut', { token: accessToken, scope }, {}),
      createUser: (input: Input) =>
        result('auth.createUser', input, { user: { id: target } }),
      deleteUser: (id: string) => result('auth.deleteUser', { id }, {}),
      updateUserById: (id: string, input: Input) =>
        result('auth.updateUser', { id, ...input }, {}),
    },
    signInWithPassword: (input: Input) =>
      result('auth.signIn', input, {
        user: { id: actor },
        session: {
          access_token: token(newSession),
          refresh_token: 'fixture-refresh-token',
        },
      }),
  };
  const db = {
    auth,
    rpc: (name: string, input: Input) => {
      const fallback = name === 'admin_identity'
        ? me
        : name === 'admin_login_attempt'
        ? true
        : name === 'admin_password_matches'
        ? false
        : name === 'admin_snapshot'
        ? { me, merchants: [], orders: [], more: false }
        : { ok: true };
      return result(name, input, fallback);
    },
    from: (table: string) => ({
      insert: (input: Input) => result(`insert:${table}`, input, {}),
      select: (columns: string) => ({
        eq: (column: string, value: unknown) => ({
          single: () =>
            result(`select:${table}`, { columns, column, value }, {
              phone: '+8613900000000',
            }),
        }),
      }),
    }),
  } as unknown as SupabaseClient;
  const services: AdminServices = {
    db,
    publicClient: () => db,
    sendLoginCode: async (phone, id) => {
      const response = await result('sms.send', { phone, requestId: id }, {
        ok: true,
        retry_after: 60,
      });
      if (response.error) {
        throw new SmsDeliveryError(response.error.message, 429);
      }
      return response.data as Input;
    },
  };
  const run = createHandler(services);
  const invoke = (
    action: string,
    values: Input = {},
    options: { authenticated?: boolean; requestId?: string | null } = {},
  ) => {
    const headers = new Headers({ 'Content-Type': 'application/json' });
    if (options.authenticated !== false) {
      headers.set('Authorization', `Bearer ${token()}`);
    }
    const id = options.requestId === undefined ? requestId : options.requestId;
    if (id !== null) headers.set('X-Request-Id', id);
    return run(
      new Request('https://fixture.invalid/admin-v1', {
        method: 'POST',
        headers,
        body: JSON.stringify({ ...values, action }),
      }),
    );
  };
  return { me, calls, hooks, run, invoke };
}

Deno.test('HTTP parsing and CORS need no credentials or SDK initialization', async () => {
  const preflight = await handler(
    new Request('https://fixture.invalid', { method: 'OPTIONS' }),
  );
  equal(preflight.status, 200);
  equal(preflight.headers.get('access-control-allow-origin'), '*');
  equal((await handler(new Request('https://fixture.invalid'))).status, 405);
  for (const body of ['{invalid', '[]', 'null', '42']) {
    const response = await handler(
      new Request('https://fixture.invalid', { method: 'POST', body }),
    );
    equal(response.status, 400);
    equal(await response.json(), { error: 'Invalid JSON' });
  }
});

Deno.test('missing/rejected JWT and revoked sessions stop before business handlers', async () => {
  const f = fixture();
  equal((await f.invoke('snapshot', {}, { authenticated: false })).status, 401);
  equal(f.calls.length, 0);
  f.hooks.set('auth.getUser', () => failed('invalid-token'));
  equal((await f.invoke('snapshot')).status, 401);
  assert(!f.calls.some((call) => call.name === 'admin_identity'));
  f.hooks.delete('auth.getUser');
  f.hooks.set('admin_identity', () => failed('28000', '登录已过期'));
  equal((await f.invoke('snapshot')).status, 401);
  assert(!f.calls.some((call) => call.name === 'admin_snapshot'));
});

Deno.test('login quota is consumed before authentication and credentials stay out of audits', async () => {
  const f = fixture();
  const response = await f.invoke('login', {
    username: ' Test_Admin ',
    password: 'FixturePassword9',
  }, { authenticated: false, requestId: null });
  equal(response.status, 200);
  equal(f.calls.slice(0, 3).map((call) => call.name), [
    'admin_login_attempt',
    'auth.signIn',
    'admin_identity',
  ]);
  equal(f.calls[0].input, { p_key: 'test_admin' });
  equal(f.calls[1].input.email, 'test_admin@admin.autocare.internal');
  const body = await response.json();
  equal(body.me.id, actor);
  assert(typeof body.access_token === 'string');
  const audit = f.calls.find((call) =>
    call.name === 'insert:admin_audit_logs'
  )!;
  equal(audit.input, { actor_id: actor, action: 'login' });
  f.calls.length = 0;
  f.hooks.set('admin_login_attempt', () => ok(false));
  equal(
    (await f.invoke('login', {
      username: 'test_admin',
      password: 'FixturePassword9',
    })).status,
    429,
  );
  assert(!f.calls.some((call) => call.name === 'auth.signIn'));
});

Deno.test('rejected operator identity revokes the just-created login session', async () => {
  const f = fixture();
  f.hooks.set('admin_identity', () => failed('42501'));
  equal(
    (await f.invoke('login', {
      username: 'test_admin',
      password: 'FixturePassword9',
    })).status,
    403,
  );
  equal(f.calls.at(-1), {
    name: 'auth.signOut',
    input: { token: token(newSession), scope: 'local' },
  });
});

Deno.test('forced password gate allows own profile/logout but rejects data and other mutations', async () => {
  const f = fixture();
  f.me.must_change = true;
  equal((await f.invoke('me', {}, { requestId: null })).status, 200);
  equal((await f.invoke('snapshot')).status, 403);
  equal((await f.invoke('merchant_extend', { id: target })).status, 403);
  assert(!f.calls.some((call) => call.name === 'admin_snapshot'));
  assert(!f.calls.some((call) => call.name === 'admin_command'));
  equal((await f.invoke('logout')).status, 200);
  equal(f.calls.at(-1)!.input.p_action, 'logout');
});

Deno.test('super-admin authorization runs before account, subscription and refund handlers', async () => {
  const f = fixture();
  f.me.role = 'ops';
  for (
    const action of [
      'account_create',
      'account_role',
      'account_enabled',
      'account_reset',
      'plan_save',
      'refund',
    ]
  ) {
    equal((await f.invoke(action, { id: target })).status, 403);
  }
  equal(
    f.calls.filter((call) => call.name === 'insert:admin_audit_logs').length,
    6,
  );
  assert(
    !f.calls.some((call) =>
      call.name === 'admin_command' || call.name === 'auth.createUser'
    ),
  );
  equal(
    (await f.invoke('ticket_reply', { id: target, text: 'Reply' })).status,
    200,
  );
});

Deno.test('read snapshot keeps pagination validation and needs no write request id', async () => {
  const f = fixture();
  for (const offset of [-1, 1.5, '200']) {
    equal((await f.invoke('snapshot', { offset })).status, 400);
  }
  equal(
    (await f.invoke('snapshot', { offset: 200 }, { requestId: null })).status,
    200,
  );
  equal(f.calls.find((call) => call.name === 'admin_snapshot')!.input, {
    p_actor: actor,
    p_session: oldSession,
    p_offset: 200,
  });
});

Deno.test('every command domain preserves verified actor/session, body and header idempotency key', async () => {
  const f = fixture();
  const actions = [
    'merchant_extend',
    'merchant_pause',
    'merchant_freeze',
    'merchant_revoke',
    'merchant_upgrade',
    'follow_save',
    'account_role',
    'account_enabled',
    'plan_save',
    'refund',
    'ticket_reply',
    'ticket_resolve',
    'logout',
  ];
  for (const action of actions) {
    const values = {
      id: target,
      text: 'Note',
      actor_id: 'untrusted',
      __request: 'untrusted',
    };
    equal((await f.invoke(action, values)).status, 200);
    equal(f.calls.at(-1), {
      name: 'admin_command',
      input: {
        p_actor: actor,
        p_session: oldSession,
        p_action: action,
        p_input: values,
        p_request: requestId,
      },
    });
  }
  const before = f.calls.filter((call) => call.name === 'admin_command').length;
  for (const id of [null, 'invalid']) {
    equal(
      (await f.invoke('ticket_reply', { id: target }, { requestId: id }))
        .status,
      400,
    );
  }
  equal(f.calls.filter((call) => call.name === 'admin_command').length, before);
});

Deno.test('command rejections retain RPC status mapping and safe failure audit', async () => {
  const f = fixture();
  for (
    const [code, status] of [
      ['28000', 401],
      ['42501', 403],
      ['P0002', 404],
      ['23505', 409],
      ['P0001', 400],
      ['42601', 400],
    ] as const
  ) {
    f.hooks.set('admin_command', () => failed(code, 'sensitive SQL detail'));
    const response = await f.invoke('ticket_reply', {
      id: target,
      text: 'Reply',
    });
    equal(response.status, status);
    const audit = f.calls.at(-1)!;
    equal(audit.input, {
      actor_id: actor,
      action: 'ticket_reply_failed',
      target,
      detail: { code, request_id: requestId },
    });
    if (code === '42601' || code === '23505') {
      assert(!(await response.text()).includes('sensitive SQL detail'));
    }
  }
});

Deno.test('password change finalizes using the replacement session and never audits the password', async () => {
  const f = fixture();
  f.me.must_change = true;
  const response = await f.invoke('change_password', {
    password: 'ReplacementPassword9',
  });
  equal(response.status, 200);
  equal(f.calls.map((call) => call.name), [
    'auth.getUser',
    'admin_identity',
    'admin_password_matches',
    'auth.updateUser',
    'auth.signIn',
    'admin_command',
  ]);
  equal(f.calls.at(-1)!.input, {
    p_actor: actor,
    p_session: newSession,
    p_action: 'password_changed',
    p_input: {},
    p_request: requestId,
  });
  equal((await response.json()).refresh_token, 'fixture-refresh-token');
  f.calls.length = 0;
  f.hooks.set('admin_password_matches', () => ok(true));
  equal(
    (await f.invoke('change_password', { password: 'ReplacementPassword9' }))
      .status,
    400,
  );
  assert(!f.calls.some((call) => call.name === 'auth.updateUser'));
});

Deno.test('password finalization failure revokes the replacement session', async () => {
  const f = fixture();
  f.hooks.set('admin_command', () => failed('42501'));
  equal(
    (await f.invoke('change_password', { password: 'ReplacementPassword9' }))
      .status,
    403,
  );
  equal(f.calls.at(-1), {
    name: 'auth.signOut',
    input: { token: token(newSession), scope: 'local' },
  });
});

Deno.test('creating an operator compensates Auth creation when the profile transaction fails', async () => {
  const f = fixture();
  f.hooks.set('admin_command', () => failed('23505'));
  const response = await f.invoke('account_create', {
    username: ' New_Operator ',
    name: ' New operator ',
    role: 'ops',
    password: 'FixturePassword9',
  });
  equal(response.status, 409);
  equal(f.calls.at(-1), { name: 'auth.deleteUser', input: { id: target } });
  const command = f.calls.find((call) => call.name === 'admin_command')!;
  equal(command.input.p_input, {
    id: target,
    username: 'new_operator',
    name: 'New operator',
    role: 'ops',
  });
  assert(!JSON.stringify(command.input).includes('FixturePassword9'));
});

Deno.test('password reset restricts/revokes in SQL before updating Auth and rejects replays', async () => {
  const f = fixture();
  const response = await f.invoke('account_reset', { id: target });
  equal(response.status, 200);
  equal(f.calls.slice(-2).map((call) => call.name), [
    'admin_command',
    'auth.updateUser',
  ]);
  const body = await response.json();
  assert(/^Ac9![a-f0-9]{32}$/.test(body.temporary_password));
  f.calls.length = 0;
  f.hooks.set('admin_command', () => ok({ ok: true, replayed: true }));
  equal((await f.invoke('account_reset', { id: target })).status, 409);
  assert(!f.calls.some((call) => call.name === 'auth.updateUser'));
});

Deno.test('SMS is authorized/idempotent before provider calls, and does not return OTPs', async () => {
  const f = fixture();
  const response = await f.invoke('merchant_send_code', { id: target });
  equal(response.status, 200);
  equal(f.calls.slice(-4).map((call) => call.name), [
    'admin_command',
    'select:stores',
    'sms.send',
    'insert:admin_audit_logs',
  ]);
  equal(f.calls.find((call) => call.name === 'sms.send')!.input, {
    phone: '+8613900000000',
    requestId,
  });
  equal(await response.json(), { ok: true, retry_after: 60 });
  f.calls.length = 0;
  f.hooks.set('admin_command', () => ok({ ok: true, replayed: true }));
  equal((await f.invoke('merchant_send_code', { id: target })).status, 409);
  assert(
    !f.calls.some((call) =>
      call.name === 'sms.send' || call.name === 'select:stores'
    ),
  );
});

Deno.test('SMS quota/provider failures keep their status and failed-delivery audit', async () => {
  const f = fixture();
  f.hooks.set('sms.send', () => failed('quota', '今日发送次数已达上限'));
  const response = await f.invoke('merchant_send_code', { id: target });
  equal(response.status, 429);
  equal(await response.json(), { error: '今日发送次数已达上限' });
  equal(f.calls.at(-1)!.input.action, 'merchant_sms_failed');
});

Deno.test('async handler failures stay behind the HTTP boundary and do not leak secrets', async () => {
  const f = fixture();
  f.hooks.set('admin_command', () => {
    throw new Error('private service key material');
  });
  const response = await f.invoke('ticket_reply', {
    id: target,
    text: 'Reply',
  });
  equal(response.status, 503);
  equal(await response.json(), { error: '后台服务暂不可用，请稍后重试' });
  equal(response.headers.get('access-control-allow-origin'), '*');
});

Deno.test('unknown actions retain the existing SQL validation path', async () => {
  const f = fixture();
  f.hooks.set('admin_command', () => failed('P0001', '不支持的操作'));
  const response = await f.invoke('unknown_action');
  equal(response.status, 400);
  equal(await response.json(), { error: '不支持的操作' });
  equal(
    f.calls.find((call) => call.name === 'admin_command')!.input.p_action,
    'unknown_action',
  );
});
