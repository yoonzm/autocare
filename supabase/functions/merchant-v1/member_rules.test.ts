import { normalizePlate, parseBirthday, parseMember, parseVehicle } from './member_rules.ts';

const eq = (a: unknown, b: unknown, msg: string) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) throw new Error(`${msg}: ${JSON.stringify(a)} != ${JSON.stringify(b)}`);
};
const REF = '11111111-1111-1111-1111-111111111111';
const today = new Date('2026-11-02T00:00:00Z');
const ok = { phone: '139 1688 5530', name: '李女士' };

Deno.test('a minimal member gets the design defaults', () => {
  const r = parseMember(ok, today);
  if (typeof r === 'string') throw new Error(r);
  eq(r, {
    phone: '13916885530', name: '李女士', honorific: '', birthday: null, source: '',
    referrer_id: null, note: '',
  }, 'values');
});

Deno.test('phone must be 11 digits starting with 1[3-9]', () => {
  for (const p of ['', '1391688553', '23916885530', '1391688553a', undefined]) {
    eq(typeof parseMember({ ...ok, phone: p }, today), 'string', String(p));
  }
});

Deno.test('name is required and limited to 30 chars', () => {
  eq(typeof parseMember({ ...ok, name: '  ' }, today), 'string', 'blank');
  eq(typeof parseMember({ ...ok, name: '王'.repeat(31) }, today), 'string', 'too long');
  eq(typeof parseMember({ ...ok, name: '王'.repeat(30) }, today), 'object', '30 ok');
});

Deno.test('honorific and source only allow the design choices', () => {
  eq(typeof parseMember({ ...ok, honorific: '先生' }, today), 'object', '先生');
  eq(typeof parseMember({ ...ok, honorific: '大佬' }, today), 'string', 'bad honorific');
  for (const s of ['到店自然客', '老客推荐', '团购平台', '短视频']) {
    eq(typeof parseMember({ ...ok, source: s }, today), 'object', s);
  }
  eq(typeof parseMember({ ...ok, source: '路过' }, today), 'string', 'bad source');
});

Deno.test('a referrer only goes with 老客推荐 and must be an id', () => {
  eq(typeof parseMember({ ...ok, source: '老客推荐', referrer_id: REF }, today), 'object', 'ok');
  eq(typeof parseMember({ ...ok, source: '短视频', referrer_id: REF }, today), 'string', 'wrong source');
  eq(typeof parseMember({ ...ok, source: '老客推荐', referrer_id: 'x' }, today), 'string', 'not an id');
});

Deno.test('birthday: dotted or dashed dates, no future, no impossible days', () => {
  eq(parseBirthday('1985.06.12', today), '1985-06-12', 'dots');
  eq(parseBirthday('1985-6-2', today), '1985-06-02', 'padding');
  eq(parseBirthday('', today), null, 'empty');
  eq(parseBirthday('2026-12-01', today), undefined, 'future');
  eq(parseBirthday('1985-02-30', today), undefined, 'impossible');
  eq(parseBirthday('1899-01-01', today), undefined, 'too old');
  eq(parseBirthday('hello', today), undefined, 'text');
});

Deno.test('note is limited to 200 chars', () => {
  eq(typeof parseMember({ ...ok, note: 'a'.repeat(201) }, today), 'string', '201');
  eq(typeof parseMember({ ...ok, note: 'a'.repeat(200) }, today), 'object', '200');
});

Deno.test('plates: normalising, fuel 7 digits, new energy 8 digits', () => {
  eq(normalizePlate('沪A·8k29m'), '沪A8K29M', 'normalise');
  const fuel = parseVehicle({ plate: '沪A·8K29M', brand_model: '宝马 5系 525Li', color: '黑色' });
  eq(typeof fuel === 'object' && fuel.energy, 'fuel', 'fuel');
  const ev = parseVehicle({ plate: '沪AF09316' });
  eq(typeof ev === 'object' && ev.energy, 'ev', 'ev');
  eq(typeof parseVehicle({ plate: '沪A8K29' }), 'string', 'too short');
  eq(typeof parseVehicle({ plate: 'AA8K29M' }), 'string', 'no province');
  eq(typeof parseVehicle({ plate: '沪AF09316', energy: 'fuel' }), 'string', '8 chars but fuel');
  eq(typeof parseVehicle({ plate: '沪A8K29M', energy: 'ev' }), 'string', '7 chars but ev');
});

Deno.test('vehicle: VIN is 17 chars without I O Q, mileage is a non-negative integer', () => {
  eq(typeof parseVehicle({ plate: '沪A8K29M', vin: 'LSVAB2A12N2123456' }), 'object', 'vin ok');
  eq(typeof parseVehicle({ plate: '沪A8K29M', vin: 'LSVAB2A12N212345' }), 'string', '16');
  eq(typeof parseVehicle({ plate: '沪A8K29M', vin: 'LSVAB2A12N212345O' }), 'string', 'has O');
  const r = parseVehicle({ plate: '沪A8K29M', mileage: '18,600' });
  eq(typeof r === 'object' && r.mileage, 18600, 'commas');
  eq(typeof parseVehicle({ plate: '沪A8K29M', mileage: -1 }), 'string', 'negative');
  eq(typeof parseVehicle({ plate: '沪A8K29M', mileage: 1.5 }), 'string', 'fraction');
});
