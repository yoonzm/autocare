import { publicStorageUrl } from "./storage_url.ts";

/** 凭证签名链接有效期：一次读取内的链接保持不变，足够页面停留与预览使用。 */
export const VOUCHER_URL_TTL = 3600;

type Signed = {
  path: string | null;
  signedUrl: string | null;
  error: string | null;
};
export type VoucherSigner = (
  paths: string[],
  ttl: number,
) => Promise<{ data: Signed[] | null; error: unknown }>;

/** 批量签名；返回 路径 → 可直接访问的链接，签名失败的路径不出现在结果里。 */
export async function signVouchers(
  sign: VoucherSigner,
  paths: unknown,
  store: string,
  internalUrl: string,
  publicUrl: string,
): Promise<Record<string, string>> {
  const valid = (Array.isArray(paths) ? paths : []).filter((p): p is string =>
    typeof p === "string" &&
    new RegExp(`^${store}/[0-9a-f-]+\\.(png|jpg)$`).test(p)
  );
  if (!valid.length) return {};
  const { data, error } = await sign(valid, VOUCHER_URL_TTL);
  if (error || !data) throw new Error("voucher_sign_failed");
  const urls: Record<string, string> = {};
  for (const row of data) {
    if (row.path && row.signedUrl && !row.error) {
      urls[row.path] = publicStorageUrl(row.signedUrl, internalUrl, publicUrl);
    }
  }
  return urls;
}
