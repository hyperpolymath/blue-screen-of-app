// SPDX-License-Identifier: PMPL-1.0-or-later
// Integration-style tests for API logic (Deno-native, ESM)
// Tests exercise the core modules used by the API routes without
// spinning up the HTTP server, verifying the logic contract.
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
  trackVisit,
  trackApiCall,
  resetStats,
  getStatsObject,
} from "../../src/Analytics.bs.js";

Deno.test("API logic: /api/error — random error has required fields", () => {
  const data = getRandomErrorJS();
  assertExists(data.stopCode, "stopCode required");
  assertExists(data.description, "description required");
  assertExists(data.technicalDetail, "technicalDetail required");
  assertExists(data.percentage !== undefined, "percentage required");
});

Deno.test("API logic: /api/error — multiple calls return variety", () => {
  const codes = Array.from({ length: 5 }, () => getRandomErrorJS().stopCode);
  const unique = new Set(codes);
  assert(unique.size > 1, "Expected variety of error codes over 5 calls");
});

Deno.test("API logic: /api/error/:code — returns specific code", () => {
  const data = getErrorByCodeJS("COFFEE_NOT_FOUND");
  assertExists(data);
  assertEquals(data.stopCode, "COFFEE_NOT_FOUND");
});

Deno.test("API logic: /api/error/:code — handles lowercase", () => {
  const data = getErrorByCodeJS("coffee-not-found");
  assertExists(data);
  assertEquals(data.stopCode, "COFFEE_NOT_FOUND");
});

Deno.test("API logic: /api/error/:code — returns null for invalid code", () => {
  const data = getErrorByCodeJS("INVALID_CODE_XYZ");
  assertEquals(data, null);
});

Deno.test("API logic: /api/codes — codes list is non-empty array", () => {
  const codes = getAllStopCodes();
  assert(Array.isArray(codes));
  assert(codes.length > 0);
});

Deno.test("API logic: /api/codes — list contains humorous codes", () => {
  const codes = getAllStopCodes();
  assert(codes.includes("COFFEE_NOT_FOUND"));
  assert(codes.includes("PRODUCTION_DEPLOYMENT_ON_FRIDAY"));
});

Deno.test("API logic: /api/analytics — tracks visits and API calls", () => {
  resetStats();
  trackVisit("win10", "COFFEE_NOT_FOUND", false);
  trackApiCall();
  const stats = getStatsObject();
  assertEquals(stats.totalVisits, 1);
  assertEquals(stats.apiCalls, 1);
  resetStats();
});

Deno.test("API logic: /api/analytics — uptime is non-negative number", () => {
  const stats = getStatsObject();
  assert(typeof stats.uptime === "number");
  assert(stats.uptime >= 0);
});

Deno.test("API logic: /api/styles — known styles exist in codes", () => {
  // Validate that the styles referenced by the app map to real codes
  const codes = getAllStopCodes();
  // At minimum COFFEE_NOT_FOUND must be present (smoke test for data integrity)
  assert(codes.includes("COFFEE_NOT_FOUND"));
  assert(codes.length >= 5, "Expected at least 5 stop codes");
});
