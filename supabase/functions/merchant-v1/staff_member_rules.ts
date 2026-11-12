/** 员工端会员查询的纯函数（不依赖运行环境，便于单测）。 */
export const maskPhone = (phone: unknown): string => {
  const p = String(phone ?? '');
  return /^\d{11}$/.test(p) ? `${p.slice(0, 3)}****${p.slice(7)}` : '—';
};
