import { assertEquals } from "jsr:@std/assert@1";
import { recentPayees } from "./expense_payees.ts";

const row = (payee: string, occurred_on: string, amount = 100) => ({
  payee,
  category: "水电",
  amount,
  occurred_on,
});

Deno.test("同名只保留最近一条，忽略大小写和空格，空名称不出现", () => {
  const items = recentPayees([
    row("市供电局", "2026-11-05", 1180),
    row("", "2026-11-04"),
    row(" 市 供电局", "2026-10-05", 900),
    row("ABC Shop", "2026-10-01"),
    row("abcshop", "2026-09-01"),
  ]);
  assertEquals(items.map((i) => i.name), ["市供电局", "ABC Shop"]);
  assertEquals(items[0].amount, 1180);
});

Deno.test("按名称搜索，最多返回 limit 条", () => {
  const rows = ["甲", "乙", "丙", "丁"].map((n, i) =>
    row(`${n}公司`, `2026-11-0${i + 1}`)
  );
  assertEquals(recentPayees(rows, "乙").map((i) => i.name), ["乙公司"]);
  assertEquals(recentPayees(rows, "", 2).length, 2);
  assertEquals(recentPayees(rows, "不存在"), []);
});
