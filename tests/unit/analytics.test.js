// SPDX-License-Identifier: PMPL-1.0-or-later
// Unit tests for Analytics module (Deno-native, ESM)
import { assertEquals, assertGreaterOrEqual, assertObjectMatch } from "jsr:@std/assert";
import {
  trackVisit,
  trackApiCall,
  resetStats,
  getStatsObject,
  getUptime,
} from "../../src/Analytics.bs.js";

Deno.test("Analytics: trackVisit increments totalVisits", () => {
  resetStats();
  trackVisit("win10", "COFFEE_NOT_FOUND", false);
  const stats = getStatsObject();
  assertEquals(stats.totalVisits, 1);
  resetStats();
});

Deno.test("Analytics: trackVisit tracks style views", () => {
  resetStats();
  trackVisit("win10", "COFFEE_NOT_FOUND", false);
  trackVisit("win10", "NPM_INSTALL_TIMEOUT", false);
  trackVisit("winxp", "COFFEE_NOT_FOUND", false);
  const stats = getStatsObject();
  assertEquals(stats.styleViews["win10"], 2);
  assertEquals(stats.styleViews["winxp"], 1);
  resetStats();
});

Deno.test("Analytics: trackVisit tracks error code views", () => {
  resetStats();
  trackVisit("win10", "COFFEE_NOT_FOUND", false);
  trackVisit("win10", "COFFEE_NOT_FOUND", false);
  trackVisit("win10", "NPM_INSTALL_TIMEOUT", false);
  const stats = getStatsObject();
  assertEquals(stats.errorCodeViews["COFFEE_NOT_FOUND"], 2);
  assertEquals(stats.errorCodeViews["NPM_INSTALL_TIMEOUT"], 1);
  resetStats();
});

Deno.test("Analytics: trackVisit counts custom messages", () => {
  resetStats();
  trackVisit("win10", null, true);
  trackVisit("win10", null, true);
  trackVisit("win10", null, false);
  const stats = getStatsObject();
  assertEquals(stats.customMessages, 2);
  resetStats();
});

Deno.test("Analytics: trackApiCall increments apiCalls", () => {
  resetStats();
  trackApiCall();
  trackApiCall();
  const stats = getStatsObject();
  assertEquals(stats.apiCalls, 2);
  resetStats();
});

Deno.test("Analytics: getStatsObject returns complete stats shape", () => {
  resetStats();
  trackVisit("win10", "COFFEE_NOT_FOUND", true);
  trackApiCall();
  const stats = getStatsObject();
  assertObjectMatch(stats, {
    totalVisits: 1,
    apiCalls: 1,
    customMessages: 1,
  });
  resetStats();
});

Deno.test("Analytics: getUptime returns non-negative value", () => {
  const uptime = getUptime();
  assertGreaterOrEqual(uptime, 0);
});

Deno.test("Analytics: resetStats clears all counters", () => {
  trackVisit("win10", "COFFEE_NOT_FOUND", true);
  trackApiCall();
  resetStats();
  const stats = getStatsObject();
  assertEquals(stats.totalVisits, 0);
  assertEquals(stats.apiCalls, 0);
  assertEquals(stats.customMessages, 0);
  assertEquals(Object.keys(stats.styleViews).length, 0);
  assertEquals(Object.keys(stats.errorCodeViews).length, 0);
});
