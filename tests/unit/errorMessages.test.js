// SPDX-License-Identifier: PMPL-1.0-or-later
// Unit tests for ErrorMessages module (Deno-native, ESM)
import {
  assertEquals,
  assertNotEquals,
  assertExists,
  assert,
} from "jsr:@std/assert";
import {
  getRandomErrorJS,
  getErrorByCodeJS,
  getAllStopCodes,
} from "../../src/ErrorMessages.bs.js";

Deno.test("ErrorMessages: getRandomErrorJS returns valid shape", () => {
  const error = getRandomErrorJS();
  assertExists(error.stopCode);
  assertExists(error.description);
  assertExists(error.technicalDetail);
  assertExists(error.qrMessage);
  assert(error.percentage >= 0 && error.percentage <= 100);
});

Deno.test("ErrorMessages: getRandomErrorJS percentage is 0-100", () => {
  for (let i = 0; i < 20; i++) {
    const error = getRandomErrorJS();
    assert(error.percentage >= 0, `percentage ${error.percentage} < 0`);
    assert(error.percentage <= 100, `percentage ${error.percentage} > 100`);
  }
});

Deno.test("ErrorMessages: getRandomErrorJS returns code from list", () => {
  const codes = getAllStopCodes();
  const error = getRandomErrorJS();
  assert(codes.includes(error.stopCode), `${error.stopCode} not in stop codes list`);
});

Deno.test("ErrorMessages: getRandomErrorJS returns variety over 10 calls", () => {
  const errors = Array.from({ length: 10 }, () => getRandomErrorJS());
  const uniqueCodes = new Set(errors.map((e) => e.stopCode));
  assert(uniqueCodes.size > 1, "Expected variety of stop codes");
});

Deno.test("ErrorMessages: getErrorByCodeJS returns correct code", () => {
  const error = getErrorByCodeJS("COFFEE_NOT_FOUND");
  assertExists(error);
  assertEquals(error.stopCode, "COFFEE_NOT_FOUND");
});

Deno.test("ErrorMessages: getErrorByCodeJS handles lowercase with dashes", () => {
  const error = getErrorByCodeJS("coffee-not-found");
  assertExists(error);
  assertEquals(error.stopCode, "COFFEE_NOT_FOUND");
});

Deno.test("ErrorMessages: getErrorByCodeJS returns null for invalid code", () => {
  const error = getErrorByCodeJS("INVALID_CODE_XYZ_NOPE");
  assertEquals(error, null);
});

Deno.test("ErrorMessages: getAllStopCodes contains humorous codes", () => {
  const codes = getAllStopCodes();
  assert(codes.includes("COFFEE_NOT_FOUND"));
  assert(codes.includes("STACKOVERFLOW_COPY_PASTE_ERROR"));
  assert(codes.includes("PRODUCTION_DEPLOYMENT_ON_FRIDAY"));
});

Deno.test("ErrorMessages: getAllStopCodes returns non-empty array", () => {
  const codes = getAllStopCodes();
  assert(Array.isArray(codes));
  assert(codes.length > 0);
});

Deno.test("ErrorMessages: getErrorByCodeJS description is string", () => {
  const error = getErrorByCodeJS("COFFEE_NOT_FOUND");
  assertExists(error);
  assertEquals(typeof error.description, "string");
  assertNotEquals(error.description, "");
});
