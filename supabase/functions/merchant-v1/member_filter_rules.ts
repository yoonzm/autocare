// 会员列表“次卡状态 / 车辆与项目”筛选参数。口径见迁移 202611140001_member_filter_extra.sql。
export const PACKAGE_FILTERS = { expiring: 'f_pkg_expiring', low: 'f_pkg_low', used_up: 'f_pkg_used_up' } as const;
export const VEHICLE_FILTERS = {
  ev: 'f_ev',
  coating: 'f_coating',
  wrap_warranty: 'f_wrap_warranty',
  multi: 'f_multi',
} as const;

/** 解析并校验；返回要过滤的视图列名（可能为空），参数不合法时返回错误文案。 */
export function parseMemberExtraFilters(input: Record<string, unknown>): string[] | string {
  const columns: string[] = [];
  if (input.package_status != null) {
    const key = input.package_status as keyof typeof PACKAGE_FILTERS;
    if (typeof key !== 'string' || !Object.hasOwn(PACKAGE_FILTERS, key)) return '次卡状态无效';
    columns.push(PACKAGE_FILTERS[key]);
  }
  if (input.vehicle_project != null) {
    const key = input.vehicle_project as keyof typeof VEHICLE_FILTERS;
    if (typeof key !== 'string' || !Object.hasOwn(VEHICLE_FILTERS, key)) return '车辆与项目筛选无效';
    columns.push(VEHICLE_FILTERS[key]);
  }
  return columns;
}
