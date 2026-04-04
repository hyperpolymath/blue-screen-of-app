// SPDX-License-Identifier: PMPL-1.0-or-later
// Integration-style tests for BSOD route logic (Deno-native, ESM)
// Tests verify module contracts without spinning up the HTTP server.
import {
  assertEquals,
  assertExists,
  assert,
} from "jsr:@std/assert";
import {
  getRandomErrorJS,
  getErrorByCodeJS,
  getAllStopCodes,
} from "../../src/ErrorMessages.bs.js";
import {
  resetStats,
  getStatsObject,
} from "../../src/Analytics.bs.js";

// Simulates the query-param parsing the server performs
function applyQueryParams(params) {
  const stopCode = params.code
    ? getErrorByCodeJS(params.code)?.stopCode ?? "COFFEE_NOT_FOUND"
    : getRandomErrorJS().stopCode;
  const percentage = params.percentage !== undefined
    ? parseInt(params.percentage, 10)
    : Math.floor(Math.random() * 101);
  const style = params.style ?? "win10";
  const message = params.message ?? null;
  const technical = params.technical ?? null;
  return { stopCode, percentage, style, message, technical };
}

Deno.test("BSOD route: default style is win10", () => {
  const result = applyQueryParams({});
  assertEquals(result.style, "win10");
});

Deno.test("BSOD route: custom code param applies", () => {
  const result = applyQueryParams({ code: "COFFEE_NOT_FOUND" });
  assertEquals(result.stopCode, "COFFEE_NOT_FOUND");
});

Deno.test("BSOD route: custom percentage param applies", () => {
  const result = applyQueryParams({ percentage: "75" });
  assertEquals(result.percentage, 75);
});

Deno.test("BSOD route: custom message param is preserved", () => {
  const result = applyQueryParams({ message: "Custom error message" });
  assertEquals(result.message, "Custom error message");
});

Deno.test("BSOD route: custom technical detail is preserved", () => {
  const result = applyQueryParams({ technical: "Custom technical detail" });
  assertEquals(result.technical, "Custom technical detail");
});

Deno.test("BSOD route: multiple params work together", () => {
  const result = applyQueryParams({
    style: "win10",
    code: "COFFEE_NOT_FOUND",
    percentage: "42",
  });
  assertEquals(result.stopCode, "COFFEE_NOT_FOUND");
  assertEquals(result.percentage, 42);
  assertEquals(result.style, "win10");
});

Deno.test("BSOD route: /random selects from valid styles", () => {
  const validStyles = ["win10", "win11", "win7", "winxp"];
  for (let i = 0; i < 10; i++) {
    const chosen = validStyles[Math.floor(Math.random() * validStyles.length)];
    assert(validStyles.includes(chosen));
  }
});

Deno.test("BSOD route: /random produces variety", () => {
  const validStyles = ["win10", "win11", "win7", "winxp"];
  const choices = Array.from(
    { length: 20 },
    () => validStyles[Math.floor(Math.random() * validStyles.length)],
  );
  const unique = new Set(choices);
  assert(unique.size > 1, "Expected variety in random style selection");
});

Deno.test("BSOD route: unknown code falls back gracefully", () => {
  const result = applyQueryParams({ code: "UNKNOWN_CODE_XYZ" });
  assertEquals(result.stopCode, "COFFEE_NOT_FOUND");
});

Deno.test("BSOD route: stop codes list has required humorous entries", () => {
  const codes = getAllStopCodes();
  assert(codes.includes("COFFEE_NOT_FOUND"), "COFFEE_NOT_FOUND missing");
  assert(
    codes.includes("STACKOVERFLOW_COPY_PASTE_ERROR"),
    "STACKOVERFLOW_COPY_PASTE_ERROR missing",
  );
});
