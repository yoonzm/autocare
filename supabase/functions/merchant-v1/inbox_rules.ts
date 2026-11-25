const id = (v: unknown): v is string => typeof v === 'string' && /^[\da-f]{8}(-[\da-f]{4}){3}-[\da-f]{12}$/i.test(v);
const at = (v: unknown): v is string => typeof v === 'string' && /^\d{4}-\d{2}-\d{2}T/.test(v) && Number.isFinite(Date.parse(v));
export function inboxArgs(input: Record<string, unknown>): Record<string, unknown> | string {
  switch (input.action) {
    case 'inbox_unread': return {};
    case 'inbox_list': {
      const kind = input.kind == null || input.kind === 'all' ? null : input.kind;
      if (kind !== null && !['task', 'arrival', 'system'].includes(String(kind))) return '消息分类无效';
      const cursor = input.cursor as Record<string, unknown> | null | undefined;
      if (cursor != null && (typeof cursor !== 'object' || !at(cursor.at) || !id(cursor.id))) return '消息分页位置无效';
      return { p_kind: kind, p_before_at: cursor?.at ?? null, p_before_id: cursor?.id ?? null };
    }
    case 'inbox_read':
      if (id(input.id) && input.before == null) return { p_id: input.id, p_before: null };
      if (input.id == null && at(input.before)) return { p_id: null, p_before: input.before };
      return '请选择消息或已加载的消息范围';
    case 'inbox_target': return id(input.id) ? { p_id: input.id } : '消息无效';
    default: return '不支持的消息操作';
  }
}
