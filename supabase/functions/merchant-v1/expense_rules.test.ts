import { budgetError, expenseError } from "./expense_rules.ts";
const entry = {
  id: "10000000-0000-0000-0000-000000000001",
  revision: 0,
  amount: 20.05,
  category: "水电",
  occurred_on: "2026-11-03",
  account: "微信",
  status: "paid",
  payee: "电力公司",
  note: "电费",
  repeat: false,
};
function check(v: unknown, message: string) {
  if (!v) throw new Error(message);
}
Deno.test("expense validates money, date, category, account and version", () => {
  check(expenseError(entry) === null, "valid");
  for (
    const patch of [
      { amount: 0 },
      { amount: -1 },
      { amount: 1.001 },
      { amount: NaN },
      { occurred_on: "2026-02-29" },
      { category: "unknown" },
      { account: "unknown" },
      { status: "pending" },
      { revision: -1 },
      { repeat: "true" },
      { payee: "x".repeat(121) },
    ]
  ) check(expenseError({ ...entry, ...patch }) !== null, JSON.stringify(patch));
});
Deno.test("budget validation checks allocation and policies", () => {
  const budget = {
    month: "2026-11-01",
    revision: 0,
    total: 100,
    carry: false,
    remind: true,
    categories: {
      "水电": {
        amount: 80,
        threshold: 80,
        policy: "block",
        repeat: false,
        rollover: false,
      },
    },
  };
  check(budgetError(budget) === null, "valid budget");
  check(
    budgetError({ ...budget, total: 79 }) !== null,
    "allocation exceeds total",
  );
  check(
    budgetError({ ...budget, month: "2026-11-02" }) !== null,
    "month boundary",
  );
  check(
    budgetError({
      ...budget,
      categories: {
        "水电": { ...budget.categories["水电"], policy: "ignore" },
      },
    }) !== null,
    "policy",
  );
});
