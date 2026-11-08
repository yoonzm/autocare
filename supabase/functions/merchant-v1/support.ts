import {
  admin,
  fail,
  json,
  merchantSession,
  sessionId,
  userFor,
} from "./shared.ts";
import type { Input } from "./types.ts";
import { screenshot } from "./support_rules.ts";
export async function handleSupport(
  input: Input,
  request: Request,
): Promise<Response> {
  if (
    ![
      "support_list",
      "support_get",
      "support_create",
      "support_reply",
      "support_upload",
    ].includes(String(input.action))
  ) return fail("不支持的操作");
  try {
    const auth = await userFor(request);
    if ("response" in auth) return auth.response;
    const current = await merchantSession(auth.user.id, auth.token, false);
    if (current instanceof Response) return current;
    if (request.headers.get('x-store-id') && request.headers.get('x-store-id') !== current) return fail('当前门店已变化，请重新操作', 409);
    if (input.action === "support_upload") {
      const store = await merchantSession(auth.user.id, auth.token, false);
      if (store instanceof Response) return store;
      const file = screenshot(input.data);
      if (!file) return fail("请选择 5MB 以内的 JPEG 或 PNG 图片");
      const id = crypto.randomUUID(), path = `${store}/${id}.${file.extension}`;
      // TODO support_cleanup_uploads: abandoned drafts/lost upload responses may
      // leave private unclaimed objects. Retention cleanup must never delete a
      // screenshot already linked to a submitted message.
      const uploaded = await admin.storage.from("support-attachments").upload(
        path,
        file.bytes,
        { contentType: file.mime, upsert: false },
      );
      if (uploaded.error) return fail("截图上传失败，请重试", 503);
      const saved = await admin.from("support_uploads").insert({
        id,
        store_id: store,
        actor_id: auth.user.id,
        path,
      });
      if (saved.error) {
        await admin.storage.from("support-attachments").remove([path]);
        return fail("截图保存失败，请重试", 503);
      }
      return json({ id });
    }
    const values = { ...input };
    delete values.action;
    const { data, error } = await admin.rpc("merchant_support", {
      p_actor: auth.user.id,
      p_session: sessionId(auth.token),
      p_action: input.action,
      p_input: values,
      p_request: request.headers.get("x-request-id"),
    });
    if (!error) return json(data);
    if (error.code === "P0002") return fail("工单不存在", 404);
    if (error.code === "42501") return fail("暂无权限提交反馈", 403);
    if (error.code === "P0001") return fail(error.message);
    if (["22P02", "22023", "23514"].includes(error.code)) {
      return fail("反馈参数无效，请检查后重试");
    }
    return fail("工单操作失败，请稍后重试", 503);
  } catch {
    return fail("反馈服务暂不可用，请稍后重试", 503);
  }
}
