import { assertEquals, assertRejects } from "jsr:@std/assert@1";
import { signVouchers } from "./expense_vouchers.ts";

const store = "11111111-1111-1111-1111-111111111111";
const a = `${store}/aaaa-1.jpg`;
const b = `${store}/bbbb-2.png`;
const internal = "http://api-gw:8000";
const pub = "https://autocare.example";

Deno.test("一次批量签名，返回路径到公网链接的映射，且有效期为 1 小时", async () => {
  const calls: [string[], number][] = [];
  const urls = await signVouchers(
    (paths, ttl) => {
      calls.push([paths, ttl]);
      return Promise.resolve({
        data: paths.map((p) => ({
          path: p,
          signedUrl:
            `${internal}/storage/v1/object/sign/expense-vouchers/${p}?token=t`,
          error: null,
        })),
        error: null,
      });
    },
    [a, b],
    store,
    internal,
    pub,
  );
  assertEquals(calls, [[[a, b], 3600]]);
  assertEquals(
    urls[a],
    `${pub}/storage/v1/object/sign/expense-vouchers/${a}?token=t`,
  );
  assertEquals(Object.keys(urls), [a, b]);
});

Deno.test("没有凭证或路径不属于本店时不请求签名", async () => {
  let called = 0;
  const sign = () => {
    called++;
    return Promise.resolve({ data: [], error: null });
  };
  assertEquals(await signVouchers(sign, [], store, internal, pub), {});
  assertEquals(await signVouchers(sign, undefined, store, internal, pub), {});
  assertEquals(
    await signVouchers(sign, ["other/aaaa.jpg", 1], store, internal, pub),
    {},
  );
  assertEquals(called, 0);
});

Deno.test("单张签名失败只丢这一张；整体失败则报错", async () => {
  const urls = await signVouchers(
    () =>
      Promise.resolve({
        data: [
          { path: a, signedUrl: "", error: "Object not found" },
          {
            path: b,
            signedUrl: `${internal}/x?token=t`,
            error: null,
          },
        ],
        error: null,
      }),
    [a, b],
    store,
    internal,
    pub,
  );
  assertEquals(Object.keys(urls), [b]);
  await assertRejects(() =>
    signVouchers(
      () => Promise.resolve({ data: null, error: new Error("boom") }),
      [a],
      store,
      internal,
      pub,
    )
  );
});
