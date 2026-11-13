import type { Input } from './types.ts';

const ranges = ['today', 'week', 'month', 'custom'] as const;
type Range = typeof ranges[number];

const isDay = (value: unknown): value is string => {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const date = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(date.getTime()) && date.toISOString().slice(0, 10) === value;
};

/** 只接受时段名和自定义起止日；门店与“今天”由服务端决定，不信任客户端。 */
export function parseBusinessStats(input: Input):
  | { range: Range; from: string | null; to: string | null }
  | { error: string } {
  const range = ranges.find((r) => r === input.range);
  if (!range) return { error: '统计时段无效' };
  if (range !== 'custom') return { range, from: null, to: null };
  if (!isDay(input.from) || !isDay(input.to)) return { error: '请选择有效的起止日期' };
  return { range, from: input.from, to: input.to };
}
