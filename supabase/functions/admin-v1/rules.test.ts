import { emailOf, passwordProblem, sessionId, username } from './rules.ts';
function equal(a: unknown, b: unknown) {
  if (a !== b) throw new Error(`${a} != ${b}`);
}
Deno.test('username normalization and credential validation', () => {
  equal(username(' Superman '), 'superman');
  equal(username('a@b.com'), null);
  equal(username('abc'), null);
  equal(emailOf('superman'), 'superman@admin.autocare.internal');
  equal(passwordProblem('abcdefg1'), null);
  equal(passwordProblem('abcdefgh') === null, false);
  equal(passwordProblem('汉'.repeat(30) + 'Ab1') === null, false);
});
Deno.test('session id is extracted only as metadata, never as authentication', () => {
  const id = '00000000-0000-4000-8000-000000000001';
  equal(sessionId('x.' + btoa(JSON.stringify({ session_id: id })) + '.x'), id);
  equal(sessionId('invalid'), null);
  equal(sessionId('x.' + btoa('{}') + '.x'), null);
});
