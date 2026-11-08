import { admin, fail, json, storeFor, uuid } from "./shared.ts";
import type { Input } from "./types.ts";
import { decimal, documentError } from "./inventory_rules.ts";

export async function handleInventory(
  input: Input,
  request: Request,
): Promise<Response> {
  const store = await storeFor(request);
  if (store instanceof Response) return store;
  const errors: Record<string, string> = {
    nonzero_stock: "库存不为零，不能停用商品",
    product_changed: "商品已被修改，请重新打开",
    unit_in_use: "商品尚有库存，不能更改单位或关闭小数",
    product_not_found: "商品不存在",
    product_disabled: "商品已停用，请先启用",
    document_in_use: "该单据涉及的商品已有后续库存变动，不能作废",
    legacy_document: "历史单据缺少批次撤销记录，不能直接作废",
    document_closed: "单据已关闭",
    category_in_use: "分类下还有商品，请先移到其他分类",
    category_changed: "分类已变化，请刷新后重试",
    settings_changed: "预警设置已修改，请刷新后重试",
    request_conflict: "请求内容已变化，请重新提交",
    notifications_unavailable: "消息通知渠道尚未接通，请使用首页或商品列表提醒",
  };
  const rpcError = (error: { message: string; code?: string }) =>
    fail(
      Object.entries(errors).find(([key]) => error.message.includes(key))
        ?.[1] ??
        (error.code === "23505"
          ? "名称或 SKU 已存在，请使用其他值"
          : "操作失败，请检查输入后重试"),
      400,
    );
  if (input.action === "inventory_assignments") {
    const [tech, orders] = await Promise.all([
      admin.from("appointment_resources").select("id,name").eq(
        "store_id",
        store,
      ).eq("kind", "technician").eq("active", true).order("name"),
      admin.from("orders").select("id,vehicle_plate,created_at").eq(
        "store_id",
        store,
      ).order("created_at", { ascending: false }).limit(200),
    ]);
    if (tech.error || orders.error) return fail("读取技师与工单失败", 500);
    return json({
      technicians: tech.data,
      orders: orders.data.map((o) => ({
        ...o,
        label: `${o.vehicle_plate || "工单"} · ${o.id.slice(0, 8)}`,
      })),
    });
  }
  if (input.action === "inventory_options") {
    const { data, error } = await admin.rpc("inventory_options", {
      p_store: store,
    });
    return error ? rpcError(error) : json(data);
  }
  if (
    input.action === "inventory_documents" ||
    input.action === "inventory_document_get"
  ) {
    if (input.action === "inventory_document_get" && !uuid(input.id)) {
      return fail("单据 ID 无效");
    }
    const { data, error } = await admin.rpc("inventory_documents_read", {
      p_store: store,
      p_id: input.action === "inventory_document_get" ? input.id : null,
    });
    if (!error && input.action === "inventory_document_get" && !data.item) {
      return fail("单据不存在", 404);
    }
    if (
      !error && input.action === "inventory_document_get" && data.item &&
      !data.item.payload.snapshots
    ) {
      const ids = (data.item.payload.lines ?? []).map((l: { id: string }) =>
        l.id
      );
      const products = await admin.from("inventory_products").select("*").eq(
        "store_id",
        store,
      ).in("id", ids);
      if (products.error) return fail("读取单据商品失败", 500);
      data.item.payload.snapshots = products.data;
    }
    return error ? rpcError(error) : json(data);
  }
  if (input.action === "inventory_lookup") {
    if (
      typeof input.code !== "string" || !input.code.trim() ||
      input.code.length > 120
    ) return fail("请输入商品编码");
    const { data, error } = await admin.from("inventory_products").select("*")
      .eq("store_id", store).eq("sku", input.code.trim()).maybeSingle();
    return error ? rpcError(error) : json({ item: data });
  }
  if (
    [
      "inventory_supplier_save",
      "inventory_category_save",
      "inventory_category_delete",
      "inventory_settings_save",
      "inventory_void",
      "inventory_disable",
      "inventory_enable",
    ].includes(String(input.action))
  ) {
    const payload = input.payload;
    if (
      !payload || typeof payload !== "object" || Array.isArray(payload) ||
      JSON.stringify(payload).length > 8000
    ) return fail("参数无效");
    const { data, error } = await admin.rpc("inventory_mutate", {
      p_store: store,
      p_request: request.headers.get("x-request-id"),
      p_action: String(input.action).slice(10),
      p_data: payload,
    });
    return error ? rpcError(error) : json({ item: data });
  }
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
    if (
      payload.attachments != null &&
      (!Array.isArray(payload.attachments) || payload.attachments.length > 6)
    ) return fail("最多上传六张附件");
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
        count_scope_changed: "盘点范围已变化，请重新打开盘点单",
        count_locked: "盘点期间已暂停出入库，请先完成或作废盘点",
        technician_not_found: "技师不存在或已停用",
        order_not_found: "工单不存在",
        count_in_progress: "已有正在盘点的单据，请继续或作废后再创建",
        product_disabled: "商品已停用",
        integer_quantity: "该商品不允许小数数量",
        expiry_required: "该商品已启用保质期管理，请填写到期日",
        invalid_attachments: "附件无效，请重新上传",
        budget_exceeded: "同步开支超过分类预算，请先调整预算或取消同步开支",
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
      (typeof input.category !== "string" || !input.category.trim() ||
        input.category.length > 40) ||
      !decimal(input.safe, 3) || !decimal(input.cost, 2)
    ) return fail("商品资料无效");
    if (!uuid(input.id)) return fail("商品 ID 无效");
    for (const key of ["sku", "specification", "location", "supplier"]) {
      if (
        input[key] != null &&
        (typeof input[key] !== "string" || String(input[key]).length > 120)
      ) return fail("商品资料过长");
    }
    const { data, error } = await admin.rpc("inventory_mutate", {
      p_store: store,
      p_request: request.headers.get("x-request-id"),
      p_action: input.action === "inventory_create" ? "create" : "update",
      p_data: { ...input, action: undefined },
    });
    return error ? rpcError(error) : json({ item: data });
  }
  return fail("不支持的库存操作");
}
