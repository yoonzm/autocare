import { createClient } from "npm:@supabase/supabase-js@2.118.0";
import {
  parseRecognition,
  photoDataUrl,
  recognitionConfig,
  RecognitionError,
  recognizePhoto,
  VEHICLE_COLORS,
} from "./plate_recognition.ts";
import { recognizeAndFindMember } from "./plate_lookup.ts";

const eq = (a: unknown, b: unknown) => {
  if (JSON.stringify(a) !== JSON.stringify(b)) {
    throw new Error(`${JSON.stringify(a)} != ${JSON.stringify(b)}`);
  }
};
const rejected = async (action: () => unknown, status: number) => {
  try {
    await action();
  } catch (e) {
    if (e instanceof RecognitionError && e.status === status) return;
    throw e;
  }
  throw new Error("Expected recognition failure");
};
const png =
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a/p0AAAAASUVORK5CYII=";
const input = { image_base64: png, mime_type: "image/png" };
const config = {
  apiKey: "test-key",
  model: "test-vision",
  baseUrl: "https://bailian.example/v1",
};
const answer = {
  plateNumber: "苏K5F218",
  vehicleModel: "比亚迪 秦PLUS",
  vehicleColor: "白色",
  plateColor: "blue",
};
const completion = (value = answer) =>
  Response.json({
    choices: [{ message: { content: JSON.stringify(value) } }],
    usage: { prompt_tokens: 100, completion_tokens: 20 },
  });

Deno.test("recognition validates photos, signature, MIME and size before contacting provider", async () => {
  eq(photoDataUrl(png, "image/png"), `data:image/png;base64,${png}`);
  for (
    const [data, mime] of [
      [null, "image/png"],
      ["", "image/png"],
      ["AAAA", "image/png"],
      [png, "image/jpeg"],
      ["a".repeat(7_000_000), "image/png"],
      ["file:///tmp/car.jpg", "image/png"],
      ["https://example.com/car.jpg", "image/png"],
      ["A===", "image/png"],
    ]
  ) {
    await rejected(() => photoDataUrl(data, mime), 400);
  }
});

Deno.test("recognition normalizes fullwidth, separators and serial I/O, preserves L and checks ordinary/new-energy plates", async () => {
  eq(
    parseRecognition('{"plateNumber":"京Ａ·io5L2","vehicleModel":" 宝马 X5 "}'),
    {
      plate: "京A105L2",
      vehicle_model: "宝马 X5",
      vehicle_color: "",
      plate_color: "",
    },
  );
  eq(
    parseRecognition('{"plateNumber":"粤BD12345","plateColor":"green"}').plate,
    "粤BD12345",
  );
  for (const plate of ["", "不存在", "京I12345", "京A1234567", "XX12345"]) {
    await rejected(
      () => parseRecognition(JSON.stringify({ plateNumber: plate })),
      422,
    );
  }
  await rejected(() => parseRecognition("[]"), 502);
  await rejected(() => parseRecognition("invalid-json"), 502);
  await rejected(
    () => parseRecognition(JSON.stringify({ ...answer, ambiguous: true })),
    422,
  );
});

Deno.test("recognition uses server configuration, structured vision JSON and records only usage", async () => {
  await rejected(() => recognitionConfig(() => undefined), 503);
  eq(
    recognitionConfig((name) =>
      name === "BAILIAN_API_KEY" ? " key " : undefined
    ).model,
    "qwen3.7-flash",
  );
  let calls = 0;
  const send: typeof fetch = async (url, init) => {
    calls++;
    eq(url, "https://bailian.example/v1/chat/completions");
    eq(new Headers(init?.headers).get("Authorization"), "Bearer test-key");
    const body = JSON.parse(String(init?.body));
    eq(body.model, "test-vision");
    eq(body.enable_thinking, false);
    eq(body.response_format, { type: "json_object" });
    eq(
      body.messages[1].content[0].image_url.url,
      `data:image/png;base64,${png}`,
    );
    return completion();
  };
  const result = await recognizePhoto(
    photoDataUrl(png, "image/png"),
    config,
    send,
  );
  eq(result.plate, "苏K5F218");
  eq(result.vehicle_model, "比亚迪 秦PLUS");
  eq(result.vehicle_color, "白色");
  eq(result.plate_color, "blue");
  eq(result.usage, {
    prompt_tokens: 100,
    completion_tokens: 20,
    total_tokens: 120,
  });
  eq(calls, 1);
});

Deno.test("vehicle body color uses the form palette, remains separate from plate color, and is optional", () => {
  for (const color of VEHICLE_COLORS) {
    const result = parseRecognition(
      JSON.stringify({ ...answer, vehicleColor: ` ${color} ` }),
    );
    eq(result.vehicle_color, color);
    eq(result.plate_color, "blue");
  }
  for (
    const color of [
      undefined,
      null,
      "",
      "未知",
      "blue",
      "双色",
      123,
      {},
      "黑色".repeat(100),
    ]
  ) {
    const result = parseRecognition(
      JSON.stringify({ ...answer, vehicleColor: color }),
    );
    eq(result.vehicle_color, "");
    eq(result.plate, "苏K5F218");
  }
});

Deno.test("provider timeout, throttling, errors and invalid responses fail without retries or leaking credentials", async () => {
  for (const status of [401, 429, 500]) {
    let calls = 0;
    await rejected(() =>
      recognizePhoto("image", config, () => {
        calls++;
        return Promise.resolve(
          new Response("secret upstream detail", { status }),
        );
      }), status === 429 ? 429 : 502);
    eq(calls, 1);
  }
  await rejected(
    () =>
      recognizePhoto(
        "image",
        config,
        () => Promise.reject(new DOMException("timeout", "TimeoutError")),
      ),
    504,
  );
  await rejected(
    () =>
      recognizePhoto(
        "image",
        config,
        () => Promise.reject(new Error("network")),
      ),
    502,
  );
  await rejected(
    () =>
      recognizePhoto(
        "image",
        config,
        () => Promise.resolve(new Response("bad-json")),
      ),
    502,
  );
  await rejected(
    () =>
      recognizePhoto("image", config, () => Promise.resolve(Response.json({}))),
    502,
  );
  await rejected(
    () =>
      recognizePhoto(
        "image",
        config,
        () => Promise.resolve(completion({ ...answer, plateNumber: "" })),
      ),
    422,
  );
});

const storeId = "11111111-1111-4111-8111-111111111111";
const memberId = "22222222-2222-4222-8222-222222222222";
function lookupFixture(
  { matched = true, deleted = false, failure = "", quota = "ok" } = {},
) {
  const queries: URL[] = [];
  const logs: unknown[] = [];
  let paidCalls = 0;
  const db = createClient("https://db.example", "test-key", {
    // This fixture only exercises database requests; no auth session to refresh.
    auth: { persistSession: false, autoRefreshToken: false },
    global: {
      fetch: async (url, init) => {
        const query = new URL(String(url));
        queries.push(query);
        const table = query.pathname.split("/").at(-1)!;
        if (table === "reserve_plate_recognition") {
          eq(JSON.parse(String(init?.body)), { p_store: storeId });
          return failure === "quota"
            ? Response.json({ message: "failed" }, { status: 500 })
            : Response.json(quota);
        }
        eq(query.searchParams.get("store_id"), `eq.${storeId}`);
        if (table === failure) {
          return Response.json({ message: "database unavailable" }, {
            status: 500,
          });
        }
        if (table === "member_vehicles") {
          eq(query.searchParams.get("plate"), "eq.苏K5F218");
          return Response.json(matched ? [{ member_id: memberId }] : []);
        }
        if (table === "members") {
          eq(query.searchParams.get("id"), `eq.${memberId}`);
          eq(query.searchParams.get("deleted_at"), "is.null");
          return Response.json(
            deleted ? [] : [{
              id: memberId,
              name: "真实会员",
              last_visit_at: "2026-10-31T09:00:00Z",
            }],
          );
        }
        eq(query.searchParams.get("member_id"), `eq.${memberId}`);
        if (table === "member_packages") {
          return Response.json([
            {
              name: "洗车年卡",
              expires_at: null,
              items: [{ total: 10, used: 2 }],
            },
            {
              name: "已过期",
              expires_at: "2020-01-01",
              items: [{ total: 10, used: 0 }],
            },
          ]);
        }
        if (table === "orders") {
          eq(query.searchParams.get("status"), "eq.completed");
          return Response.json([{
            items: [{ name: "内饰", position: 1 }, {
              name: "洗车",
              position: 0,
            }],
          }]);
        }
        throw new Error(`Unexpected query ${query}`);
      },
    },
  });
  const run = (data = input) =>
    recognizeAndFindMember(
      data,
      storeId,
      db,
      "id,name,last_visit_at",
      () => config,
      () => {
        paidCalls++;
        return Promise.resolve(completion());
      },
      (event) => logs.push(event),
    );
  return {
    run,
    queries,
    logs,
    get paidCalls() {
      return paidCalls;
    },
  };
}

Deno.test("real recognition matches exact plate only within the authenticated store and returns real member summaries", async () => {
  const fixture = lookupFixture();
  const result = await fixture.run();
  if (!("member" in result)) throw new Error("Expected matching member");
  eq(result.matched, true);
  eq(result.member?.name, "真实会员");
  eq(result.package_summary, "洗车年卡 8 次");
  eq(result.last_visit_text, "10.31 · 洗车");
  eq(fixture.paidCalls, 1);
  if (JSON.stringify(fixture.logs).includes(png)) {
    throw new Error("Photo leaked into logs");
  }
});

Deno.test("unknown plate and deleted member return unmatched; DB failures never masquerade as unmatched", async () => {
  for (const options of [{ matched: false }, { deleted: true }]) {
    const result = await lookupFixture(options).run();
    eq(result.matched, false);
    eq(result.plate, "苏K5F218");
  }
  for (
    const table of ["member_vehicles", "members", "member_packages", "orders"]
  ) {
    await rejected(() => lookupFixture({ failure: table }).run(), 500);
  }
});

Deno.test("invalid image, failed quota storage and exhausted limits prevent paid recognition", async () => {
  const invalid = lookupFixture();
  await rejected(
    () => invalid.run({ image_base64: "", mime_type: "image/png" }),
    400,
  );
  eq(invalid.queries.length, 0);
  eq(invalid.paidCalls, 0);
  for (
    const options of [{ quota: "minute" }, { quota: "day" }, {
      failure: "quota",
    }]
  ) {
    const fixture = lookupFixture(options);
    await rejected(() => fixture.run(), options.failure ? 503 : 429);
    eq(fixture.paidCalls, 0);
  }
});
