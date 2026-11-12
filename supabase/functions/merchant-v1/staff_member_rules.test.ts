import { maskPhone } from './staff_member_rules.ts';

Deno.test('maskPhone keeps only the first 3 and last 4 digits', () => {
  if (maskPhone('13812346021') !== '138****6021') throw new Error('mask');
  if (maskPhone('bad') !== '—') throw new Error('invalid input must not leak');
  if (maskPhone(null) !== '—') throw new Error('null');
});
