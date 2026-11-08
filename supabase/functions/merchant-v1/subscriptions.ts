import { admin, fail, json, sessionId, userFor } from "./shared.ts";
import type { Input } from "./types.ts";
export async function handleSubscriptions(
  input: Input,
  request: Request,
): Promise<Response> {
  const auth = await userFor(request);
  if ("response" in auth) return auth.response;
  const purchase = input.action === "subscription_simulate";
  if (!purchase && input.action !== "subscription_catalog") {
    return fail("不支持的操作");
  }
  if (
    purchase &&
    (!["basic", "pro", "flagship"].includes(String(input.plan)) ||
      ![1, 3, 12].includes(Number(input.months)) ||
      !Number.isInteger(input.months) || !Number.isInteger(input.version) ||
      typeof input.revision !== "string" ||
      !/^[a-f0-9]{32}$/.test(input.revision) ||
      !["subscribe", "renew"].includes(String(input.mode)))
  ) return fail("套餐或周期参数无效，请重新选择");
  const args = purchase
    ? {
      p_user: auth.user.id,
      p_session: sessionId(auth.token),
      p_input: {
        plan: input.plan,
        version: input.version,
        months: input.months,
        revision: input.revision,
        mode: input.mode,
      },
      p_request: request.headers.get("x-request-id"),
    }
    : { p_user: auth.user.id, p_session: sessionId(auth.token) };
  const { data, error } = await admin.rpc(
    purchase ? "subscription_simulate" : "subscription_catalog",
    args,
  );
  if (error) {
    return fail(
      error.code === "P0001" ? error.message : "订阅服务暂不可用",
      error.code === "P0001" ? 400 : 500,
    );
  }
  if (data.error) return fail(data.error, data.status ?? 400);
  return json({ item: data });
}
