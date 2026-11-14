import { assertEquals } from 'jsr:@std/assert';
import { parseMemberExtraFilters } from './member_filter_rules.ts';

Deno.test('没有额外筛选时返回空列表', () => {
  assertEquals(parseMemberExtraFilters({}), []);
});

Deno.test('次卡状态与车辆项目映射到视图列，可同时使用', () => {
  assertEquals(parseMemberExtraFilters({ package_status: 'expiring' }), ['f_pkg_expiring']);
  assertEquals(parseMemberExtraFilters({ package_status: 'low' }), ['f_pkg_low']);
  assertEquals(parseMemberExtraFilters({ package_status: 'used_up' }), ['f_pkg_used_up']);
  assertEquals(parseMemberExtraFilters({ vehicle_project: 'ev' }), ['f_ev']);
  assertEquals(parseMemberExtraFilters({ vehicle_project: 'coating' }), ['f_coating']);
  assertEquals(parseMemberExtraFilters({ vehicle_project: 'wrap_warranty' }), ['f_wrap_warranty']);
  assertEquals(
    parseMemberExtraFilters({ package_status: 'low', vehicle_project: 'multi' }),
    ['f_pkg_low', 'f_multi'],
  );
});

Deno.test('非法值、原型链键和非字符串都被拒绝', () => {
  assertEquals(parseMemberExtraFilters({ package_status: 'nope' }), '次卡状态无效');
  assertEquals(parseMemberExtraFilters({ package_status: 'toString' }), '次卡状态无效');
  assertEquals(parseMemberExtraFilters({ package_status: 3 }), '次卡状态无效');
  assertEquals(parseMemberExtraFilters({ vehicle_project: '__proto__' }), '车辆与项目筛选无效');
  assertEquals(parseMemberExtraFilters({ vehicle_project: ['ev'] }), '车辆与项目筛选无效');
});
