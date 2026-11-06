import { admin, fail, json, storeFor, url, uuid } from "./shared.ts";
import { publicStorageUrl } from "./storage_url.ts";
import { day, decimal } from "./inventory_rules.ts";
import type { Input } from "./types.ts";

import {
  budgetError,
  expenseCategories,
  expenseError,
} from "./expense_rules.ts";
const messages: Record<string, string> = {
  expense_not_found: "开支记录不存在",
  expense_changed: "记录已变化，请重新打开",
  source_locked: "库存生成的金额、分类、日期不可修改或删除，请调整库存来源",
  budget_exceeded: "该分类禁止超支，请先调整预算",
  budget_changed: "预算已变化，请重新打开",
  budget_insufficient: "可调剂金额不足",
  allocation_exceeded: "分类分配不能超过总预算",
  request_reused: "请求已用于其他内容，请重新提交",
  invalid_amount: "金额无效",
  budget_not_found: "请先设置本月预算",
};
export async function handleExpenses(
  input: Input,
  request: Request,
): Promise<Response> {
  const store = await storeFor(request);
  if (store instanceof Response) return store;
  const action = String(input.action).replace(/^expense_/, "");
  const month = String(
    input.month ??
      new Date(Date.now() + 8 * 3600000).toISOString().slice(0, 7) + "-01",
  );
  if (action === "source") {
    if (!uuid(input.id)) return fail("记录无效");
    const entry = await admin.from("expense_entries").select("source_document")
      .eq("store_id", store).eq("id", input.id).eq("deleted", false)
      .maybeSingle();
    if (entry.error) return fail("读取来源失败", 500);
    if (!entry.data?.source_document) return fail("该记录为手工记账", 404);
    const result = await admin.from("inventory_documents").select("*").eq(
      "store_id",
      store,
    ).eq("id", entry.data.source_document).maybeSingle();
    return result.error
      ? fail("读取来源失败", 500)
      : json({ item: result.data });
  }
  if (action === "upload") {
    if (typeof input.data !== "string" || input.data.length > 7000000) {
      return fail("图片不能超过 5MB");
    }
    let bytes: Uint8Array;
    try {
      bytes = Uint8Array.from(atob(input.data), (c) => c.charCodeAt(0));
    } catch {
      return fail("图片无效");
    }
    const png = bytes[0] === 137 && bytes[1] === 80 && bytes[2] === 78 &&
      bytes[3] === 71;
    const jpg = bytes[0] === 255 && bytes[1] === 216 && bytes[2] === 255;
    if ((!png && !jpg) || bytes.length > 5 * 1024 * 1024) {
      return fail("请选择 5MB 以内的 JPEG 或 PNG 图片");
    }
    const path = `${store}/${crypto.randomUUID()}.${png ? "png" : "jpg"}`;
    const { error } = await admin.storage.from("expense-vouchers").upload(
      path,
      bytes,
      { contentType: png ? "image/png" : "image/jpeg", upsert: false },
    );
    if (error) return fail("凭证上传失败", 500);
    return json({ item: { path } });
  }
  if (action === "voucher") {
    if (
      typeof input.path !== "string" ||
      !new RegExp(`^${store}/[0-9a-f-]+\\.(png|jpg)$`).test(input.path)
    ) return fail("凭证不存在", 404);
    const { data, error } = await admin.storage.from("expense-vouchers")
      .createSignedUrl(input.path, 300);
    if (error) return fail("读取凭证失败", 500);
    return json({ item: {
      ...data,
      signedUrl: publicStorageUrl(data.signedUrl, url, Deno.env.get('SUPABASE_PUBLIC_URL') || url),
    } });
  }
  if (action === "board" || action === "get" || action === "suggest") {
    if (
      !day(month) || !month.endsWith("-01") ||
      (action === "get" && !uuid(input.id))
    ) return fail("查询参数无效");
    const { data, error } = await admin.rpc("expense_read", {
      p_store: store,
      p_month: month,
      p_id: action === "get" ? input.id : null,
    });
    if (error) return fail("读取开支失败", 500);
    if (action === "get" && !data.item) return fail("开支不存在", 404);
    if (action !== "suggest") return json(data);
    const board = data.item;
    const last = new Date(`${month}T00:00:00Z`);
    last.setUTCMonth(last.getUTCMonth() - 1);
    const previous = last.toISOString().slice(0, 10);
    const cats: Record<string, Input> = {};
    const total = Number(input.total);
    if (!decimal(total, 2)) return fail("总预算无效");
    const weights = expenseCategories.map((k) =>
      input.method === "previous"
        ? Number(board.previous_budget?.categories?.[k]?.amount ?? 0)
        : (board.history as Input[]).filter((h) =>
          h.month === previous && h.category === k
        ).reduce((n, h) => n + Number(h.amount), 0)
    );
    const weight = weights.reduce((a, b) => a + b, 0);
    if (weight === 0) return fail("上月没有可用于分配的数据");
    let remaining = Math.round(total * 100);
    expenseCategories.forEach((k, i) => {
      const cents = i === expenseCategories.length - 1
        ? remaining
        : Math.floor(total * 100 * weights[i] / weight);
      remaining -= cents;
      cats[k] = {
        amount: cents / 100,
        threshold: 80,
        policy: "warn",
        repeat: false,
        rollover: false,
      };
    });
    return json({ item: { categories: cats, total } });
  }
  let data: Input = { ...input };
  delete data.action;
  if (action === "save") {
    const error = expenseError(data);
    if (error) return fail(error);
    if (
      !Array.isArray(data.attachments) || data.attachments.length > 5 ||
      !data.attachments.every((p) =>
        typeof p === "string" &&
        new RegExp(`^${store}/[0-9a-f-]+\\.(png|jpg)$`).test(p)
      )
    ) return fail("凭证无效");
  } else if (action === "delete") {
    if (!uuid(data.id) || !Number.isInteger(data.revision)) {
      return fail("记录标识无效");
    }
  } else if (action === "budget_save") {
    const error = budgetError(data);
    if (error) return fail(error);
  } else if (action === "budget_adjust") {
    if (
      !day(data.month) || !String(data.month).endsWith("-01") ||
      !Number.isInteger(data.revision) || !decimal(data.amount, 2) ||
      data.amount === 0 || !expenseCategories.includes(String(data.category)) ||
      !["total", "remaining", ...expenseCategories].includes(
        String(data.source),
      ) || typeof data.reason !== "string" || !data.reason.trim() ||
      data.reason.length > 500
    ) return fail("请检查追加金额、来源和原因");
  } else return fail("不支持的开支操作");
  const { data: result, error } = await admin.rpc("expense_mutate", {
    p_store: store,
    p_request: request.headers.get("x-request-id"),
    p_action: action,
    p_data: data,
  });
  if (error) {
    return fail(
      Object.entries(messages).find(([k]) => error.message.includes(k))?.[1] ??
        "保存失败，请检查输入后重试",
      400,
    );
  }
  return json({ item: result });
}
