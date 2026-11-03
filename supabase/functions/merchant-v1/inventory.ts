import { admin, fail, json, storeFor, uuid } from "./shared.ts";
import type { Input } from "./types.ts";
import { decimal, documentError } from "./inventory_rules.ts";

export async function handleInventory(
  input: Input,
  request: Request,
): Promise<Response> {
  const store = await storeFor(request);
  if (store instanceof Response) return store;
  if (input.action === "inventory_list" || input.action === "inventory_get") {
    if (input.action === "inventory_get" && !uuid(input.id)) {
      return fail("商品 ID 无效");
    }
    const { data, error } = await admin.rpc("inventory_read", {
      p_store: store,
      p_id: input.action === "inventory_get" ? input.id : null,
    });
    if (error) return fail("读取库存失败", 500);
    if (input.action === "inventory_get" && !data.item) {
      return fail("商品不存在", 404);
    }
    return json(data);
  }
  if (input.action === "inventory_quote") {
    if (
      !["in", "out", "check"].includes(String(input.kind)) || !input.payload ||
      typeof input.payload !== "object" || Array.isArray(input.payload)
    ) return fail("单据参数无效");
    const payload = input.payload as Record<string, unknown>;
    const validation = documentError(String(input.kind), payload);
    if (validation) return fail(validation);
    if ((payload.lines as unknown[]).length > 200) {
      return fail("单据最多 200 项商品");
    }
    const { data, error } = await admin.rpc("inventory_quote", {
      p_store: store,
      p_kind: input.kind,
      p_payload: payload,
    });
    return error
      ? fail(
        error.message.includes("insufficient_stock")
          ? "库存不足"
          : "计算库存成本失败",
        400,
      )
      : json({ item: data });
  }
  if (input.action === "inventory_draft") {
    if (!["in", "out", "check"].includes(String(input.kind))) {
      return fail("单据类型无效");
    }
    const { data, error } = await admin.from("inventory_documents").select("*")
      .eq("store_id", store)
      .eq("kind", input.kind).eq("status", "draft").order("created_at", {
        ascending: false,
      }).limit(1).maybeSingle();
    return error ? fail("读取草稿失败", 500) : json({ item: data });
  }
  if (input.action === "inventory_document") {
    if (
      !uuid(input.id) || !["in", "out", "check"].includes(String(input.kind)) ||
      !Number.isInteger(input.revision) || typeof input.post !== "boolean" ||
      !input.payload || typeof input.payload !== "object" ||
      Array.isArray(input.payload)
    ) return fail("单据参数无效");
    const payload = input.payload as Record<string, unknown>;
    const validation = documentError(String(input.kind), payload);
    if (validation) return fail(validation);
    if (
      !Array.isArray(payload.lines) || payload.lines.length > 200 ||
      !payload.lines.every((l) =>
        l && uuid(l.id) && typeof l.quantity === "number" &&
        Number.isFinite(l.quantity) &&
        l.quantity >= 0 && l.quantity <= 999999999 &&
        (input.kind !== "in" ||
          (typeof l.cost === "number" && Number.isFinite(l.cost) &&
            l.cost >= 0))
      )
    ) return fail("请检查商品数量和成本");
    for (
      const key of [
        "supplier",
        "note",
        "date",
        "payment",
        "reason",
        "technician",
        "workorder",
      ]
    ) {
      if (
        payload[key] != null &&
        (typeof payload[key] !== "string" || String(payload[key]).length > 1000)
      ) return fail("单据字段无效");
    }
    // Stock-linked expenses are booked atomically by the database trigger.
    // Never accept a flag that implies those external side effects have happened.
    if (payload.attachments != null) {
      return fail("库存附件上传尚未接通，请在开支详情补充凭证");
    }
    const { data, error } = await admin.rpc("inventory_document_save", {
      p_store: store,
      p_id: input.id,
      p_kind: input.kind,
      p_payload: payload,
      p_revision: input.revision,
      p_post: input.post,
    });
    if (error) {
      const messages: Record<string, string> = {
        budget_exceeded: '同步开支超过分类预算，请先调整预算或取消同步开支',
        insufficient_stock: "库存不足",
        stock_changed: "库存已变化，请重新盘点",
        document_changed: "草稿已被修改，请重新打开",
        document_closed: "单据已提交",
        product_not_found: "商品不存在",
        empty_document: "请添加商品",
        supplier_required: "请填写供应商",
        invalid_quantity: "数量须大于零，盘点可填零，最多三位小数",
        invalid_amount: "请检查成本和运费",
        duplicate_product: "商品不能重复",
        document_not_found: "单据不存在",
      };
      return fail(
        Object.entries(messages).find(([key]) => error.message.includes(key))
          ?.[1] ?? "单据保存失败，请检查输入后重试",
        400,
      );
    }
    return json({ item: data });
  }
  if (
    input.action === "inventory_create" || input.action === "inventory_update"
  ) {
    if (
      typeof input.name !== "string" || !input.name.trim() ||
      input.name.length > 120 ||
      typeof input.unit !== "string" || !input.unit.trim() ||
      input.unit.length > 12 ||
      !["洗护", "镀晶", "贴膜", "配件"].includes(String(input.category)) ||
      !decimal(input.safe, 3) || !decimal(input.cost, 2)
    ) return fail("商品资料无效");
    if (!uuid(input.id)) return fail("商品 ID 无效");
    for (const key of ["sku", "specification", "location", "supplier"]) {
      if (
        input[key] != null &&
        (typeof input[key] !== "string" || String(input[key]).length > 120)
      ) return fail("商品资料过长");
    }
    const fields = {
      name: input.name.trim(),
      unit: input.unit.trim(),
      category: input.category,
      safe: input.safe,
      sku: input.sku ?? "",
      specification: input.specification ?? "",
      location: input.location ?? "",
      supplier: input.supplier ?? "",
    };
    // Editing metadata never changes the weighted stock valuation.
    const query = input.action === "inventory_create"
      ? admin.from("inventory_products").upsert({
        ...fields,
        id: input.id,
        store_id: store,
        cost: input.cost,
      }, { onConflict: "id", ignoreDuplicates: true })
      : admin.from("inventory_products").update(fields).eq("id", input.id).eq(
        "store_id",
        store,
      );
    const { data, error } = await query.select().maybeSingle();
    if (!error && !data && input.action === "inventory_create") {
      const existing = await admin.from("inventory_products").select("*").eq("store_id",store).eq("id",input.id).maybeSingle();
      if (!existing.error && existing.data && Object.entries(fields).every(([k,v])=>existing.data[k]===v)) return json({item:existing.data});
    }
    if (!error && !data) return fail("商品已存在或不存在，请刷新后重试", 409);
    return error
      ? fail(error.code === "23505" ? "商品名称已存在" : "保存商品失败", 400)
      : json({ item: data });
  }
  return fail("不支持的库存操作");
}
