import { admin, fail, json, storeFor, uuid } from "./shared.ts";
import type { Input } from "./types.ts";
import { decimal, documentError } from "./inventory_rules.ts";

export async function handleInventory(
  input: Input,
  request: Request,
): Promise<Response> {
  const store = await storeFor(request);
  if (store instanceof Response) return store;
  if (String(input.action).startsWith("inventory_count_")) {
    const action = String(input.action).slice("inventory_count_".length);
    if (action === "list") {
      const page = Number(input.page ?? 0);
      if (!Number.isInteger(page) || page < 0 || page > 10000) {
        return fail("页码无效");
      }
      const { data, error } = await admin.rpc("inventory_count_list", {
        p_store: store,
        p_page: page,
      });
      return error ? fail("读取盘点单失败", 500) : json(data);
    }
    if (
      !["start", "get", "save", "review", "post", "rebase", "cancel"].includes(
        action,
      ) || !uuid(input.id)
    ) return fail("盘点参数无效");
    if (
      action !== "start" && action !== "get" &&
      !Number.isInteger(input.revision)
    ) return fail("盘点版本无效");
    const { data, error } = await admin.rpc("inventory_count_action", {
      p_store: store,
      p_action: action,
      p_id: input.id,
      p_input: input,
    });
    if (error) {
      const errors: Record<string, string> = {
        legacy_count_pending: "请先提交或作废旧版盘点草稿，再新建盘点",
        count_id_reused: "盘点单号已使用，请重新新建盘点",
        count_exists: "已有进行中的盘点单，请先继续或结束盘点",
        count_not_found: "盘点单不存在",
        count_changed: "盘点单已被其他设备修改，请重新打开",
        count_closed: "盘点单已结束",
        invalid_scope: "盘点范围没有商品或超过 5000 项",
        invalid_lines: "盘点商品与范围不一致",
        invalid_quantity: "数量无效，请检查单位是否允许小数",
        empty_count: "请至少录入一项实盘数量",
        stock_changed: "库存已变化，请刷新快照后重新盘点变化的商品",
        product_disabled: "盘点商品已停用，请恢复商品或取消本次盘点",
        budget_exceeded: "盘亏开支超过预算，请调整损耗预算后重试",
      };
      return fail(
        Object.entries(errors).find(([k]) => error.message.includes(k))?.[1] ??
          "盘点操作失败，请重试",
        400,
      );
    }
    return json({ item: data });
  }
  if (input.action === "inventory_scan") {
    if (
      typeof input.code !== "string" || !input.code.trim() ||
      input.code.length > 120
    ) return fail("请输入有效商品编码");
    const code = input.code.trim();
    const [sku, barcode] = await Promise.all([
      admin.from("inventory_products").select("*").eq("store_id", store).eq(
        "sku",
        code,
      ),
      admin.from("inventory_products").select("*").eq("store_id", store).eq(
        "barcode",
        code,
      ),
    ]);
    if (sku.error || barcode.error) return fail("查询商品失败", 500);
    const matches = [
      ...new Map([...sku.data, ...barcode.data].map((p) => [p.id, p])).values(),
    ];
    if (matches.length > 1) {
      return fail("编码对应多个商品，请更正 SKU 或条码后重试", 409);
    }
    if (matches.length === 0) {
      return fail("没有找到该编码的商品，请检查 SKU 或商品条码", 404);
    }
    return json({ item: matches[0] });
  }
  if (input.action === "inventory_document_void") {
    if (!uuid(input.id) || !Number.isInteger(input.revision)) {
      return fail("单据参数无效");
    }
    const { data, error } = await admin.from("inventory_documents").update({
      status: "void",
    }).eq("store_id", store).eq("id", input.id).eq("status", "draft").eq(
      "revision",
      input.revision,
    ).select().maybeSingle();
    if (error) return fail("作废失败", 500);
    if (data) return json({ item: data });
    const previous = await admin.from("inventory_documents").select("*").eq(
      "store_id",
      store,
    ).eq("id", input.id).maybeSingle();
    return previous.data?.status === "void"
      ? json({ item: previous.data })
      : fail("单据已变化，只有草稿可以作废", 409);
  }
  if (input.action === "inventory_suppliers") {
    const { data, error } = await admin.from("inventory_suppliers").select("*")
      .eq("store_id", store).order("name");
    return error ? fail("读取供应商失败", 500) : json({ items: data });
  }
  if (input.action === "inventory_supplier_save") {
    if (
      !uuid(input.id) || typeof input.name !== "string" || !input.name.trim() ||
      input.name.length > 120
    ) return fail("请填写供应商名称");
    for (const key of ["contact", "phone", "note"]) {
      if (
        input[key] != null &&
        (typeof input[key] !== "string" || String(input[key]).length > 1000)
      ) return fail("供应商资料无效");
    }
    const fields = {
      name: input.name.trim(),
      contact: input.contact ?? "",
      phone: input.phone ?? "",
      note: input.note ?? "",
    };
    const { data, error } = await admin.from("inventory_suppliers").upsert({
      ...fields,
      id: input.id,
      store_id: store,
    }, { onConflict: "id", ignoreDuplicates: true }).select().maybeSingle();
    if (error) {
      return fail(
        error.code === "23505" ? "供应商名称已存在" : "保存供应商失败",
        400,
      );
    }
    if (data) return json({ item: data });
    const old = await admin.from("inventory_suppliers").select("*").eq(
      "store_id",
      store,
    ).eq("id", input.id).maybeSingle();
    return old.data &&
        Object.entries(fields).every(([k, v]) => old.data[k] === v)
      ? json({ item: old.data })
      : fail("供应商记录冲突", 409);
  }
  if (
    input.action === "inventory_documents" ||
    input.action === "inventory_document_get"
  ) {
    let query = admin.from("inventory_documents").select("*").eq(
      "store_id",
      store,
    );
    if (input.action === "inventory_document_get") {
      if (!uuid(input.id)) return fail("单据 ID 无效");
      const { data, error } = await query.eq("id", input.id).maybeSingle();
      if (error) return fail("读取单据失败", 500);
      if (!data) return fail("单据不存在", 404);
      const products = await admin.from("inventory_products").select(
        "id,name,unit",
      ).eq("store_id", store).in(
        "id",
        data.payload.lines.map((l: Record<string, unknown>) => l.id),
      );
      if (products.error) return fail("读取单据商品失败", 500);
      return json({
        item: {
          ...data,
          payload: {
            ...data.payload,
            lines: data.payload.lines.map((l: Record<string, unknown>) => ({
              ...l,
              ...products.data.find((p) => p.id === l.id),
            })),
          },
        },
      });
    }
    if (!["in", "out", "check"].includes(String(input.kind))) {
      return fail("单据类型无效");
    }
    if (input.status != null) {
      if (!["draft", "posted", "void"].includes(String(input.status))) {
        return fail("单据状态无效");
      }
      query = query.eq("status", input.status);
    }
    if (input.reason != null) {
      if (
        !["施工领用", "损耗报废", "退回供应商", "内部使用"].includes(
          String(input.reason),
        )
      ) return fail("出库类型无效");
      query = query.eq("payload->>reason", input.reason);
    }
    const page = Number(input.page ?? 0);
    if (!Number.isInteger(page) || page < 0 || page > 100000) {
      return fail("页码无效");
    }
    const { data, error } = await query.eq("kind", input.kind).order(
      "created_at",
      { ascending: false },
    ).order("id").range(page * 20, page * 20 + 19);
    return error ? fail("读取单据失败", 500) : json({ items: data });
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
        inventory_frozen: "盘点期间已暂停库存变更，请先结束盘点",
        count_workflow_required: "请从盘点单提交盘点结果",
        budget_exceeded: "同步开支超过分类预算，请先调整预算或取消同步开支",
        product_disabled: "商品已停用",
        integer_required: "该商品不允许小数数量",
        expiry_required: "请填写商品有效期",
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
      !["洗护", "清洁用品", "镀晶", "贴膜", "配件", "工具", "其他"].includes(
        String(input.category),
      ) ||
      !decimal(input.safe, 3) || !decimal(input.cost, 2)
    ) return fail("商品资料无效");
    if (!uuid(input.id)) return fail("商品 ID 无效");
    for (
      const key of ["sku", "barcode", "specification", "location", "supplier"]
    ) {
      if (
        input[key] != null &&
        (typeof input[key] !== "string" || String(input[key]).length > 120)
      ) return fail("商品资料过长");
    }
    for (const key of ["active", "allow_decimal", "manage_expiry"]) {
      if (input[key] != null && typeof input[key] !== "boolean") {
        return fail("商品设置无效");
      }
    }
    const fields = {
      name: input.name.trim(),
      unit: input.unit.trim(),
      category: input.category,
      safe: input.safe,
      sku: String(input.sku ?? "").trim() ||
        `SKU-${String(input.id).replaceAll("-", "")}`,
      barcode: String(input.barcode ?? "").trim(),
      active: input.active ?? true,
      allow_decimal: input.allow_decimal ?? true,
      manage_expiry: input.manage_expiry ?? false,
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
      const existing = await admin.from("inventory_products").select("*").eq(
        "store_id",
        store,
      ).eq("id", input.id).maybeSingle();
      if (
        !existing.error && existing.data &&
        Object.entries(fields).every(([k, v]) => existing.data[k] === v)
      ) return json({ item: existing.data });
    }
    if (!error && !data) return fail("商品已存在或不存在，请刷新后重试", 409);
    return error
      ? fail(
        error.code === "23505" ? "商品名称、SKU 或条码已存在" : "保存商品失败",
        400,
      )
      : json({ item: data });
  }
  return fail("不支持的库存操作");
}
