import { day, decimal, documentError } from "./inventory_rules.ts";
function equal(a: unknown, b: unknown) {
  if (a !== b) throw new Error(`${a} !== ${b}`);
}
Deno.test("inventory quantities and money reject invalid precision and nonfinite values", () => {
  equal(decimal(.125, 3), true);
  equal(decimal(.1251, 3), false);
  equal(decimal(-1, 3), false);
  equal(decimal(Infinity, 2), false);
  equal(decimal(NaN, 2), false);
  equal(decimal("1", 2), false);
  equal(decimal(1.01, 2), true);
  equal(decimal(1.001, 2), false);
});
Deno.test("inventory dates and documents validate all lines", () => {
  equal(day("2026-02-29"), false);
  equal(day("2028-02-29"), true);
  equal(day("2026-13-01"), false);
  equal(documentError("check", { lines: [{ quantity: 0, version: 0 }] }), null);
  equal(documentError("out", { lines: [{ quantity: 0 }] }) !== null, true);
  equal(
    documentError("in", { freight: -1, lines: [{ quantity: 1, cost: 1 }] }) !==
      null,
    true,
  );
  equal(
    documentError("in", {
      lines: [{ quantity: 1, cost: 1, expires_on: "bad" }],
    }) !== null,
    true,
  );
});
Deno.test("inventory drafts may leave the unit cost empty, freight is capped and the cost switch is boolean", () => {
  const lines = [{ quantity: 1, cost: null }];
  equal(documentError("in", { lines }) !== null, true);
  equal(documentError("in", { lines }, true), null);
  equal(documentError("in", { lines: [{ quantity: 1, cost: "x" }] }, true) !== null, true);
  equal(documentError("in", { freight: 99999.99, lines: [{ quantity: 1, cost: 1 }] }), null);
  equal(documentError("in", { freight: 100000, lines: [{ quantity: 1, cost: 1 }] }) !== null, true);
  equal(
    documentError("in", { freight_to_cost: "yes", lines: [{ quantity: 1, cost: 1 }] }) !== null,
    true,
  );
  equal(documentError("in", { freight_to_cost: true, lines: [{ quantity: 1, cost: 1 }] }), null);
});
