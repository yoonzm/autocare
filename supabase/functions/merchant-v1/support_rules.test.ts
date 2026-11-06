import { screenshot } from "./support_rules.ts";
const assert = (value: unknown) => {
  if (!value) throw new Error("Assertion failed");
};
Deno.test("screenshots reject forged MIME, malformed base64 and oversized files", () => {
  for (
    const value of [
      null,
      "?",
      btoa('<svg onload="alert(1)">'),
      btoa("GIF89a"),
      "a".repeat(6990510),
    ]
  ) assert(screenshot(value) === null);
  assert(
    screenshot(btoa(String.fromCharCode(255, 216, 255, 224)))?.mime ===
      "image/jpeg",
  );
  const png = new Uint8Array(24);
  png.set([137, 80, 78, 71, 13, 10, 26, 10]);
  png.set([73, 72, 68, 82], 12);
  assert(screenshot(btoa(String.fromCharCode(...png)))?.extension === "png");
});
