// SPDX-License-Identifier: PMPL-1.0-or-later
// Blue Screen of App — Zig FFI Integration Tests
//
// These tests verify the Zig FFI layer for the BSOD application.
// They run standalone without requiring the shared library, testing
// the FFI helper logic and error code arithmetic independently.

const std = @import("std");
const testing = std.testing;

// ---------------------------------------------------------------------------
// FFI helper types (mirrors what ffi/zig/src/main.zig exports)
// ---------------------------------------------------------------------------

/// Error codes returned by FFI functions (C ABI compatible)
const BsodError = enum(c_int) {
    ok = 0,
    null_pointer = 1,
    invalid_arg = 2,
    out_of_memory = 3,
    unknown = 255,
};

/// A simulated error record as the FFI layer would produce it
const BsodRecord = struct {
    stop_code: []const u8,
    percentage: u8,
    is_custom: bool,
};

// ---------------------------------------------------------------------------
// Pure Zig helpers that mirror FFI logic
// ---------------------------------------------------------------------------

fn clampPercentage(raw: i32) u8 {
    if (raw < 0) return 0;
    if (raw > 100) return 100;
    return @intCast(raw);
}

fn normaliseStopCode(buf: []u8, input: []const u8) usize {
    var len: usize = 0;
    for (input) |c| {
        if (len >= buf.len) break;
        buf[len] = if (c == '-') '_' else std.ascii.toUpper(c);
        len += 1;
    }
    return len;
}

fn isKnownCode(code: []const u8, known: []const []const u8) bool {
    for (known) |k| {
        if (std.mem.eql(u8, code, k)) return true;
    }
    return false;
}

fn errorFromCode(code: c_int) BsodError {
    return switch (code) {
        0 => .ok,
        1 => .null_pointer,
        2 => .invalid_arg,
        3 => .out_of_memory,
        else => .unknown,
    };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "BsodError: ok code is 0" {
    try testing.expectEqual(@as(c_int, 0), @intFromEnum(BsodError.ok));
}

test "BsodError: null_pointer code is 1" {
    try testing.expectEqual(@as(c_int, 1), @intFromEnum(BsodError.null_pointer));
}

test "BsodError: round-trip from c_int" {
    try testing.expectEqual(BsodError.ok, errorFromCode(0));
    try testing.expectEqual(BsodError.null_pointer, errorFromCode(1));
    try testing.expectEqual(BsodError.invalid_arg, errorFromCode(2));
    try testing.expectEqual(BsodError.out_of_memory, errorFromCode(3));
    try testing.expectEqual(BsodError.unknown, errorFromCode(99));
}

test "clampPercentage: values within range are preserved" {
    try testing.expectEqual(@as(u8, 0), clampPercentage(0));
    try testing.expectEqual(@as(u8, 50), clampPercentage(50));
    try testing.expectEqual(@as(u8, 100), clampPercentage(100));
}

test "clampPercentage: negative clamped to 0" {
    try testing.expectEqual(@as(u8, 0), clampPercentage(-1));
    try testing.expectEqual(@as(u8, 0), clampPercentage(-100));
}

test "clampPercentage: over 100 clamped to 100" {
    try testing.expectEqual(@as(u8, 100), clampPercentage(101));
    try testing.expectEqual(@as(u8, 100), clampPercentage(999));
}

test "normaliseStopCode: uppercase conversion" {
    var buf: [64]u8 = undefined;
    const len = normaliseStopCode(&buf, "coffee_not_found");
    try testing.expectEqualStrings("COFFEE_NOT_FOUND", buf[0..len]);
}

test "normaliseStopCode: dashes become underscores" {
    var buf: [64]u8 = undefined;
    const len = normaliseStopCode(&buf, "coffee-not-found");
    try testing.expectEqualStrings("COFFEE_NOT_FOUND", buf[0..len]);
}

test "normaliseStopCode: already uppercase is idempotent" {
    var buf: [64]u8 = undefined;
    const len = normaliseStopCode(&buf, "COFFEE_NOT_FOUND");
    try testing.expectEqualStrings("COFFEE_NOT_FOUND", buf[0..len]);
}

test "isKnownCode: recognises valid codes" {
    const known = [_][]const u8{
        "COFFEE_NOT_FOUND",
        "PRODUCTION_DEPLOYMENT_ON_FRIDAY",
        "STACKOVERFLOW_COPY_PASTE_ERROR",
    };
    try testing.expect(isKnownCode("COFFEE_NOT_FOUND", &known));
    try testing.expect(isKnownCode("PRODUCTION_DEPLOYMENT_ON_FRIDAY", &known));
}

test "isKnownCode: rejects unknown codes" {
    const known = [_][]const u8{
        "COFFEE_NOT_FOUND",
        "PRODUCTION_DEPLOYMENT_ON_FRIDAY",
    };
    try testing.expect(!isKnownCode("INVALID_CODE_XYZ", &known));
    try testing.expect(!isKnownCode("", &known));
}

test "BsodRecord: is_custom flag is preserved" {
    const r = BsodRecord{
        .stop_code = "COFFEE_NOT_FOUND",
        .percentage = 42,
        .is_custom = true,
    };
    try testing.expect(r.is_custom);
    try testing.expectEqualStrings("COFFEE_NOT_FOUND", r.stop_code);
    try testing.expectEqual(@as(u8, 42), r.percentage);
}

test "BsodRecord: default non-custom record" {
    const r = BsodRecord{
        .stop_code = "CRITICAL_PROCESS_DIED",
        .percentage = 0,
        .is_custom = false,
    };
    try testing.expect(!r.is_custom);
}
