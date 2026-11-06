import {
  emailOf,
  passwordProblem,
  sessionId,
  supportStorageUrl,
  username,
} from './rules.ts';
function equal(a: unknown, b: unknown) {
  if (a !== b) throw new Error(`${a} != ${b}`);
}
Deno.test('support screenshots replace internal origin and port, preserving signature', () => {
  equal(
    supportStorageUrl(
      'http://gateway:8000/storage/v1/object/sign/private/a.png?token=signature',
      'http://gateway:8000',
      'https://autocare.example',
    ),
    'https://autocare.example/storage/v1/object/sign/private/a.png?token=signature',
  );
  equal(
    supportStorageUrl(
      'https://hosted.example/a?token=x',
      'http://gateway:8000',
      'https://autocare.example',
    ),
    'https://hosted.example/a?token=x',
  );
});
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
