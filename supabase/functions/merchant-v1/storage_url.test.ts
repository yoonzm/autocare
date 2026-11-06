import { publicStorageUrl } from './storage_url.ts';

Deno.test('self-hosted storage URLs retain their signed path and query', () => {
  const value = publicStorageUrl(
    'http://api-gw:8000/storage/v1/object/sign/expense-vouchers/a.jpg?token=abc%2Fdef',
    'http://api-gw:8000',
    'https://autocare.mymember.ltd',
  );
  if (value !== 'https://autocare.mymember.ltd/storage/v1/object/sign/expense-vouchers/a.jpg?token=abc%2Fdef') {
    throw new Error(value);
  }
});

Deno.test('hosted storage URLs are preserved', () => {
  const value = 'https://project.supabase.co/storage/v1/object/sign/bucket/a.jpg?token=abc';
  if (publicStorageUrl(value, 'https://project.supabase.co', 'https://project.supabase.co') !== value) {
    throw new Error('Hosted URL changed');
  }
});
