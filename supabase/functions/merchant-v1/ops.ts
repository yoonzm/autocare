import { admin, fail, json, uuid } from './shared.ts';
import { operatorOf } from './members.ts';
import {
  parseCheckout,
  parseExtend,
  parseFollowUp,
  parseHold,
  parseRefund,
  parseSell,
} from './ops_rules.ts';
import type { Input } from './types.ts';

const PKG_SELECT =
  '*, items:member_package_items(position, service_id, service_name, unit_price, total, used), member:members(id, name, phone)';

const rpcFail = (message: string, code?: string) => {
  if (code === 'P0002') return fail(message.includes('member') ? '会员不存在' : '记录不存在', 404);
  return fail('操作失败', 400);
};

/** 会员的次卡：列表 / 详情 / 购买 / 延期 / 退款。 */
export async function handleMemberPackages(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'list') {
    if (!uuid(input.member_id)) return fail('会员无效');
    const { data, error } = await admin.from('member_packages').select(PKG_SELECT)
      .eq('store_id', storeId).eq('member_id', input.member_id)
      .order('purchased_at', { ascending: false });
    return error ? fail('读取失败', 500) : json({ items: data ?? [] });
  }
  if (input.action === 'get') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    const { data, error } = await admin.from('member_packages').select(PKG_SELECT)
      .eq('id', input.id).eq('store_id', storeId).maybeSingle();
    if (error) return fail('读取失败', 500);
    if (!data) return fail('次卡不存在', 404);
    const { data: events } = await admin.from('member_package_events').select('*')
      .eq('member_package_id', input.id).order('created_at', { ascending: false }).limit(200);
    return json({ item: { ...data, events: events ?? [] } });
  }
  if (input.action === 'sell') {
    const v = parseSell(input);
    if (typeof v === 'string') return fail(v);
    const { data, error } = await admin.rpc('sell_package', {
      p_store: storeId, p_member: v.member_id, p_package: v.package_id, p_method: v.method,
      p_operator: await operatorOf(storeId), p_request: typeof input.__request === 'string' ? input.__request : null,
    });
    if (error) {
      if (error.code === 'P0002') {
        return fail(error.message.includes('member') ? '会员不存在' : '套餐不存在或已下架', 404);
      }
      if (error.code === 'P0001') {
        return fail(error.message.includes('limit') ? '已达到该套餐的每人限购份数' : '储值余额不足', 400);
      }
      return fail('购买失败', 400);
    }
    return json({ item: data });
  }
  if (input.action === 'extend') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    const v = parseExtend(input);
    if (typeof v === 'string') return fail(v);
    const { data, error } = await admin.rpc('extend_package', {
      p_store: storeId, p_mp: input.id, p_days: v.days, p_reason: v.reason, p_operator: await operatorOf(storeId),
    });
    if (error) {
      if (error.code === 'P0001') return fail('这张次卡不能延期（永久有效、已用完或已退款）', 400);
      return rpcFail(error.message, error.code);
    }
    return json({ item: data });
  }
  if (input.action === 'refund') {
    if (!uuid(input.id)) return fail('记录 ID 无效');
    const v = parseRefund(input);
    if (typeof v === 'string') return fail(v);
    const { data, error } = await admin.rpc('refund_package', {
      p_store: storeId, p_mp: input.id, p_to: v.to, p_reason: v.reason, p_operator: await operatorOf(storeId),
    });
    if (error) {
      if (error.code === 'P0001') {
        return fail(error.message.includes('already') ? '这张次卡已经退款' : '没有可退金额', 400);
      }
      return rpcFail(error.message, error.code);
    }
    return json({ item: data });
  }
  return fail('不支持的操作');
}

const HOLD_SELECT =
  '*, items:held_order_items(position, service_id, name, qty, member_package_id), member:members(id, name, phone, balance, card:card_types(name, discount))';

const holdFail = (error: { code?: string; message: string }) => {
  if (error.code === 'P0002') {
    const m = error.message;
    return fail(m.includes('hold') ? '挂单不存在或已处理' : m.includes('member') ? '会员不存在' : '服务项目不存在或已下架', 404);
  }
  if (error.code === 'P0001') {
    return fail(error.message.includes('hold_closed') ? '这张挂单已经处理过了' : '请先选择服务项目', 400);
  }
  return fail('保存失败', 400);
};

/** 开单收银 + 挂单（挂起 / 取单 / 删除）。估价和扣款都在数据库函数里按服务端价格计算。 */
export async function handleOrders(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'holds') {
    const { data, error } = await admin.from('held_orders').select(HOLD_SELECT)
      .eq('store_id', storeId).is('settled_at', null).is('cancelled_at', null)
      .order('created_at', { ascending: false }).limit(200);
    return error ? fail('读取失败', 500) : json({ items: data ?? [] });
  }
  if (input.action === 'hold_get') {
    if (!uuid(input.id)) return fail('挂单无效');
    const { data, error } = await admin.from('held_orders').select(HOLD_SELECT)
      .eq('id', input.id).eq('store_id', storeId).is('settled_at', null).is('cancelled_at', null).maybeSingle();
    if (error) return fail('读取失败', 500);
    return data ? json({ item: data }) : fail('挂单不存在或已处理', 404);
  }
  if (input.action === 'hold') {
    const v = parseHold(input);
    if (typeof v === 'string') return fail(v);
    const { data, error } = await admin.rpc('hold_order', {
      p_store: storeId, p_member: v.member_id, p_lines: v.lines, p_status: v.status,
      p_note: v.note, p_remind: v.remind, p_plate: v.plate, p_hold: v.hold_id,
    });
    if (error) return holdFail(error);
    const { data: item } = await admin.from('held_orders').select(HOLD_SELECT).eq('id', data).single();
    return json({ item });
  }
  if (input.action === 'hold_cancel') {
    if (!uuid(input.id)) return fail('挂单无效');
    const { data, error } = await admin.from('held_orders').update({ cancelled_at: new Date().toISOString() })
      .eq('id', input.id).eq('store_id', storeId).is('settled_at', null).is('cancelled_at', null).select('id');
    if (error) return fail('删除失败', 400);
    return data && data.length > 0 ? json({ ok: true }) : fail('挂单不存在或已处理', 404);
  }
  if (input.action === 'checkout') {
    const v = parseCheckout(input);
    if (typeof v === 'string') return fail(v);
    const request = typeof input.__request === 'string' ? input.__request : null;
    const operator = await operatorOf(storeId);
    // 取单结算：挂单关闭和收款在同一个数据库事务里完成
    const { data, error } = v.hold_id
      ? await admin.rpc('settle_held_order', {
        p_store: storeId, p_hold: v.hold_id, p_lines: v.lines, p_method: v.method,
        p_balance_part: v.balance_part, p_other: v.other, p_plate: v.plate, p_remark: v.remark,
        p_operator: operator, p_request: request,
      })
      : await admin.rpc('checkout_order', {
        p_store: storeId, p_member: v.member_id, p_lines: v.lines, p_method: v.method,
        p_balance_part: v.balance_part, p_other: v.other, p_plate: v.plate, p_remark: v.remark,
        p_operator: operator, p_request: request,
      });
    if (error) {
      if (error.code === 'P0002') {
        const m = error.message;
        return fail(m.includes('hold') ? '挂单不存在或已处理' : m.includes('member') ? '会员不存在' : m.includes('service') ? '服务项目不存在或已下架' : '请先选择服务项目', 404);
      }
      if (error.code === 'P0001') {
        const m = error.message;
        if (m.includes('hold_closed')) return fail('这张挂单已经处理过了', 400);
        if (m.includes('balance')) return fail('储值余额不足', 400);
        if (m.includes('package')) return fail('次卡不可用或次数不够', 400);
        if (m.includes('combo')) return fail('组合支付的余额金额无效', 400);
        return fail('收款方式无效', 400);
      }
      return fail('收款失败', 400);
    }
    return json({ item: data });
  }
  return fail('不支持的操作');
}

const DAY = 86400000;

/** 回访：记录、历史、今日提醒。 */
export async function handleFollowUps(input: Input, storeId: string): Promise<Response> {
  if (input.action === 'list') {
    if (!uuid(input.member_id)) return fail('会员无效');
    const { data, error } = await admin.from('member_follow_ups').select('*')
      .eq('store_id', storeId).eq('member_id', input.member_id)
      .order('created_at', { ascending: false }).limit(50);
    return error ? fail('读取失败', 500) : json({ items: data ?? [] });
  }
  if (input.action === 'save') {
    const v = parseFollowUp(input);
    if (typeof v === 'string') return fail(v);
    const { data: member } = await admin.from('members').select('id')
      .eq('id', v.member_id).eq('store_id', storeId).is('deleted_at', null).maybeSingle();
    if (!member) return fail('会员不存在', 404);
    const { data, error } = await admin.from('member_follow_ups').insert({
      store_id: storeId, member_id: v.member_id, method: v.method, result: v.result,
      content: v.content, next_at: v.next_at, operator: await operatorOf(storeId),
    }).select('*').single();
    return error ? fail('保存失败', 400) : json({ item: data });
  }
  if (input.action === 'mark') {
    // 提醒页上的“标记已回访”：记一条回访，不用填表
    if (!uuid(input.member_id)) return fail('会员无效');
    const { data: member } = await admin.from('members').select('id')
      .eq('id', input.member_id).eq('store_id', storeId).is('deleted_at', null).maybeSingle();
    if (!member) return fail('会员不存在', 404);
    const { error } = await admin.from('member_follow_ups').insert({
      store_id: storeId, member_id: input.member_id, method: '电话', result: '已标记回访',
      content: typeof input.content === 'string' ? input.content.trim().slice(0, 500) : '',
      operator: await operatorOf(storeId),
    });
    return error ? fail('保存失败', 400) : json({ ok: true });
  }
  if (input.action === 'reminders') {
    const now = Date.now();
    const { data: members } = await admin.from('members')
      .select('id, name, phone, birthday, last_visit_at, created_at, balance, card:card_types(name), vehicles:member_vehicles(plate)')
      .eq('store_id', storeId).is('deleted_at', null).limit(5000);
    const byId = new Map((members ?? []).map((m) => [m.id as string, m]));
    // 今天已经回访过的会员不再提醒
    const dayStart = new Date(new Date(now + 8 * 3600000).setUTCHours(0, 0, 0, 0) - 8 * 3600000).toISOString();
    const { data: doneToday } = await admin.from('member_follow_ups').select('member_id')
      .eq('store_id', storeId).gte('created_at', dayStart);
    const done = new Set((doneToday ?? []).map((r) => r.member_id as string));
    const info = (id: string) => {
      const m = byId.get(id)!;
      const plate = ((m.vehicles as { plate: string }[] | null) ?? [])[0]?.plate ?? '';
      return {
        member_id: id, name: m.name, plate, card: (m.card as unknown as { name: string } | null)?.name ?? '',
        phone: m.phone, balance: m.balance,
      };
    };
    const items: Record<string, unknown>[] = [];
    // 次卡 7 天内到期且还有剩余次数
    const { data: expiring } = await admin.from('member_packages')
      .select('id, member_id, name, total_count, used_count, expires_at')
      .eq('store_id', storeId).is('refunded_at', null).not('expires_at', 'is', null)
      .gte('expires_at', new Date(now).toISOString()).lte('expires_at', new Date(now + 7 * DAY).toISOString());
    for (const p of expiring ?? []) {
      if ((p.used_count as number) >= (p.total_count as number) || !byId.has(p.member_id as string)) continue;
      const days = Math.max(0, Math.ceil((new Date(p.expires_at as string).getTime() - now) / DAY));
      items.push({
        kind: '次卡到期', when: days === 0 ? '今天' : `${days} 天后`, sort: days,
        text: `${p.name}剩 ${(p.total_count as number) - (p.used_count as number)} 次，${(p.expires_at as string).slice(5, 10).replace('-', '.')} 到期`,
        ...info(p.member_id as string),
      });
    }
    // 生日：未来 7 天（含今天）
    const cn = new Date(now + 8 * 3600000);
    for (const m of members ?? []) {
      if (!m.birthday) continue;
      const [, mo, d] = String(m.birthday).split('-').map(Number);
      for (let i = 0; i <= 7; i++) {
        const t = new Date(Date.UTC(cn.getUTCFullYear(), cn.getUTCMonth(), cn.getUTCDate() + i));
        if (t.getUTCMonth() + 1 === mo && t.getUTCDate() === d) {
          items.push({
            kind: '生日', when: i === 0 ? '今天' : `${mo}.${String(d).padStart(2, '0')}`, sort: i,
            text: `${(m.card as unknown as { name: string } | null)?.name ?? ''}生日`, ...info(m.id as string),
          });
          break;
        }
      }
    }
    // 沉睡：45 天没到店（没到过店的看开卡时间）
    for (const m of members ?? []) {
      const last = new Date((m.last_visit_at ?? m.created_at) as string).getTime();
      const idle = Math.floor((now - last) / DAY);
      if (idle >= 45) {
        items.push({
          kind: '沉睡客户', when: m.last_visit_at ? `${idle} 天未到店` : `开卡 ${idle} 天未到店`, sort: -idle,
          text: Number(m.balance) > 0 ? `余额 ¥${Number(m.balance)} 未用` : '', ...info(m.id as string),
        });
      }
    }
    const todo = items.filter((i) => !done.has(i.member_id as string));
    todo.sort((a, b) => (a.sort as number) - (b.sort as number));
    const members_todo = new Set(todo.map((i) => i.member_id as string));
    const counts: Record<string, number> = {};
    for (const i of todo) counts[i.kind as string] = (counts[i.kind as string] ?? 0) + 1;
    return json({
      items: todo.map(({ sort: _sort, ...rest }) => rest),
      counts, pending: members_todo.size, done_today: done.size,
    } as never);
  }
  return fail('不支持的操作');
}
