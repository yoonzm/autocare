import { admin, fail, json, storeFor, url, uuid } from "./shared.ts";
import { signVouchers } from "./expense_vouchers.ts";
import { operatorOf } from "./members.ts";
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
    // 出库页「关联工单」「领用技师」选择器的数据：
    // - technicians：启用的技师，带擅长项目和当前状态（有进行中的工单为「施工中」，否则「空闲」）；
    // - workorders：进行中的工单（客户已到店、尚未完成的预约），按到店时间倒序；
    // - orders：旧版选择器用的最近订单，保留给还没升级的客户端。
    const [tech, orders, working] = await Promise.all([
      admin.from("appointment_resources").select("id,name,category").eq(
        "store_id",
        store,
      ).eq("kind", "technician").eq("active", true).order("name"),
      admin.from("orders").select("id,vehicle_plate,created_at").eq(
        "store_id",
        store,
      ).order("created_at", { ascending: false }).limit(200),
      admin.from("appointments").select(
        "id,vehicle_plate,items,technician_id,arrived_at,starts_at",
      ).eq("store_id", store).eq("status", "arrived").order("arrived_at", {
        ascending: false,
      }).limit(100),
    ]);
    if (tech.error || orders.error || working.error) {
      return fail("读取技师与工单失败", 500);
    }
    const names = new Map(tech.data.map((t) => [t.id, t.name]));
    const busy = new Set(working.data.map((w) => w.technician_id));
    return json({
      technicians: tech.data.map((t) => ({
        id: t.id,
        name: t.name,
        skills: t.category ?? "",
        status: busy.has(t.id) ? "busy" : "idle",
      })),
      workorders: working.data.map((w) => ({
        id: w.id,
        plate: w.vehicle_plate || "",
        service: ((w.items ?? []) as { name?: string }[]).map((i) => i.name)
          .filter(Boolean).join(" · "),
        technician_id: w.technician_id ?? null,
        technician: names.get(w.technician_id) ?? "",
        started_at: w.arrived_at ?? w.starts_at,
      })),
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
    // 送货单 / 发票：返回 路径 → 签名链接，客户端直接显示缩略图和大图预览。
    if (!error && input.action === "inventory_document_get" && data.item) {
      try {
        data.item.attachment_urls = await signVouchers(
          (paths, ttl) =>
            admin.storage.from("expense-vouchers").createSignedUrls(paths, ttl),
          data.item.payload.attachments,
          store,
          url,
          Deno.env.get("SUPABASE_PUBLIC_URL") || url,
        );
      } catch {
        return fail("读取凭证失败", 500);
      }
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
    const validation = documentError(String(input.kind), payload, true);
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
  if (input.action === "inventory_last_freight") {
    // 同一供应商最近一次已入库单据的运费，用作运费弹层的快捷项；没有记录返回 null。
    if (typeof input.supplier !== "string" || !input.supplier.trim()) {
      return json({ freight: null });
    }
    const { data, error } = await admin.from("inventory_documents").select(
      "payload",
    ).eq("store_id", store).eq("kind", "in").eq("status", "posted")
      .filter("payload->>supplier", "eq", input.supplier.trim())
      .order("posted_at", { ascending: false }).limit(20);
    if (error) return fail("读取上次运费失败", 500);
    const hit = (data ?? []).map((r) => Number(r.payload?.freight)).find((n) =>
      Number.isFinite(n) && n > 0
    );
    return json({ freight: hit ?? null });
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
    const validation = documentError(String(input.kind), payload, input.post === false);
    if (validation) return fail(validation);
    if (
      input.kind === "out" && input.post === true &&
      payload.reason === "退回供应商"
    ) {
      // 退回供应商：供应商必须是本店已有的供应商。
      const { data: found, error: supplierError } = await admin.from(
        "inventory_suppliers",
      ).select("id").eq("store_id", store).eq(
        "name",
        String(payload.supplier).trim(),
      ).limit(1);
      if (supplierError) return fail("读取供应商失败", 500);
      if (!found?.length) return fail("供应商不存在，请重新选择");
    }
    if (
      !Array.isArray(payload.lines) || payload.lines.length > 200 ||
      !payload.lines.every((l) =>
        l && uuid(l.id) && typeof l.quantity === "number" &&
        Number.isFinite(l.quantity) &&
        l.quantity >= 0 && l.quantity <= 999999999 &&
        (input.kind !== "in" ||
          // 草稿允许入库单价暂时留空（页面显示「请输入」）；提交入库时必须填写。
          (input.post === false && l.cost == null) ||
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
    // 经办人由服务端按当前登录身份写入，不信任客户端传来的值（单据详情显示「经办 陈明」）。
    payload.operator = await operatorOf(store);
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
    if (
      input.shelf_months != null &&
      (!Number.isInteger(input.shelf_months) ||
        Number(input.shelf_months) < 1 ||
        Number(input.shelf_months) > 120)
    ) return fail("保质期月数须为 1–120 整数");
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
