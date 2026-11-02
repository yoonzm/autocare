import { isCardColor, normalizeCardColor } from './color_rules.ts';

const eq = (a: unknown, b: unknown, msg: string) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${msg}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);
};

Deno.test('card color: presets and #RRGGBB are valid, everything else is not', () => {
  for (const ok of ['black', 'champagne', 'silver', 'blue', 'white', '#7A4B2A', '#7a4b2a']) eq(isCardColor(ok), true, ok);
  for (const bad of ['', 'red', '#FFF', '#GGGGGG', '7A4B2A', '#7A4B2A00', 'rgb(1,2,3)', null, 5]) eq(isCardColor(bad), false, String(bad));
  eq(normalizeCardColor('#7a4b2a'), '#7A4B2A', 'upper-case');
  eq(normalizeCardColor('black'), 'black', 'preset untouched');
});
