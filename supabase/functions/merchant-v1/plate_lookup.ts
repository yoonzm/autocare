import type { SupabaseClient } from "npm:@supabase/supabase-js@2.118.0";
import { lastVisitText, packageSummary } from "./recognize_rules.ts";
import {
  photoDataUrl,
  type RecognitionConfig,
  RecognitionError,
  recognizePhoto,
} from "./plate_recognition.ts";

export async function recognizeAndFindMember(
  input: Record<string, unknown>,
  storeId: string,
  db: SupabaseClient,
  memberSelect: string,
  getConfig: () => RecognitionConfig,
  send: typeof fetch = fetch,
  log: (event: Record<string, unknown>) => void = (event) =>
    console.info(JSON.stringify(event)),
) {
  const image = photoDataUrl(input.image_base64, input.mime_type);
  const config = getConfig();
  const reservation = await db.rpc("reserve_plate_recognition", {
    p_store: storeId,
  });
  if (reservation.error) {
    throw new RecognitionError("识别服务暂时不可用，请稍后重试", 503);
  }
  if (reservation.data !== "ok") {
    throw new RecognitionError(
      reservation.data === "day"
        ? "今日车牌识别次数已达上限"
        : "识别过于频繁，请稍后重试",
      429,
    );
  }
  const { model, usage, elapsed_ms, ...recognized } = await recognizePhoto(
    image,
    config,
    send,
  );
  log({
    event: "plate_recognition",
    store_id: storeId,
    model,
    usage,
    elapsed_ms,
  });
  const vehicle = await db.from("member_vehicles").select("member_id")
    .eq("store_id", storeId).eq("plate", recognized.plate).maybeSingle();
  if (vehicle.error) throw new RecognitionError("查询车辆失败，请重试", 500);
  if (!vehicle.data) return { ...recognized, matched: false };
  const member = await db.from("members").select(memberSelect).eq(
    "store_id",
    storeId,
  )
    .eq("id", vehicle.data.member_id).is("deleted_at", null)
    .maybeSingle().overrideTypes<Record<string, unknown>, { merge: false }>();
  if (member.error) throw new RecognitionError("查询会员失败，请重试", 500);
  if (!member.data) return { ...recognized, matched: false };
  const packages = await db.from("member_packages")
    .select("name, expires_at, items:member_package_items(total, used)")
    .eq("store_id", storeId).eq("member_id", member.data.id).is(
      "refunded_at",
      null,
    );
  const last = await db.from("orders").select(
    "created_at, items:order_items(name, position)",
  )
    .eq("store_id", storeId).eq("member_id", member.data.id).eq(
      "status",
      "completed",
    )
    .order("created_at", { ascending: false }).limit(1).maybeSingle();
  if (packages.error || last.error) {
    throw new RecognitionError("读取会员到店信息失败，请重试", 500);
  }
  const live = (packages.data ?? []).filter((p) =>
    !p.expires_at || new Date(p.expires_at) > new Date()
  );
  const firstItem =
    [...(last.data?.items ?? [])].sort((a, b) => a.position - b.position)[0]
      ?.name ?? "";
  return {
    ...recognized,
    matched: true,
    member: member.data,
    package_summary: packageSummary(
      live.map((p) => ({
        name: String(p.name),
        left: (p.items as { total: number; used: number }[]).reduce(
          (s, i) => s + i.total - i.used,
          0,
        ),
      })),
    ),
    last_visit_text: lastVisitText(
      member.data.last_visit_at as string | null,
      firstItem,
    ),
  };
}
