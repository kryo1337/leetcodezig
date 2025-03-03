const std = @import("std");
const Allocator = std.mem.Allocator;

fn characterReplacement(allocator: Allocator, s: []const u8, k: i32) !i32 {
    var map = std.AutoHashMap(u8, i32).init(allocator);
    defer map.deinit();
    var left: usize = 0;
    var max_len: i32 = 0;
    var max_count: i32 = 0;

    for (s, 0..) |char, right| {
        const count = map.get(char) orelse 0;
        try map.put(char, count + 1);

        max_count = @max(max_count, count + 1);
        const size = @as(i32, @intCast(right - left + 1));
        const repl = size - max_count;

        if (repl > k) {
            const left_char = s[left];
            const left_count = map.get(left_char).?;
            try map.put(left_char, left_count - 1);
            left += 1;
        }
        max_len = @max(max_len, @as(i32, @intCast(right - left + 1)));
    }
    return max_len;
}

pub fn main() !void {}

test "longest repeating - basic case" {
    const s = "ABAB";
    const k: i32 = 2;
    const expected: i32 = 4;
    const result = try characterReplacement(std.testing.allocator, s, k);
    std.debug.print("Test 'basic case': s={s}, k={}, result={}\n", .{ s, k, result });
    try std.testing.expectEqual(expected, result);
}

test "longest repeating - partial replacement" {
    const s = "AABABBA";
    const k: i32 = 1;
    const expected: i32 = 4;
    const result = try characterReplacement(std.testing.allocator, s, k);
    std.debug.print("Test 'partial replacement': s={s}, k={}, result={}\n", .{ s, k, result });
    try std.testing.expectEqual(expected, result);
}

test "longest repeating - no replacement" {
    const s = "AAAA";
    const k: i32 = 0;
    const expected: i32 = 4;
    const result = try characterReplacement(std.testing.allocator, s, k);
    std.debug.print("Test 'no replacement': s={s}, k={}, result={}\n", .{ s, k, result });
    try std.testing.expectEqual(expected, result);
}

test "longest repeating - single char" {
    const s = "A";
    const k: i32 = 0;
    const expected: i32 = 1;
    const result = try characterReplacement(std.testing.allocator, s, k);
    std.debug.print("Test 'single char': s={s}, k={}, result={}\n", .{ s, k, result });
    try std.testing.expectEqual(expected, result);
}

test "longest repeating - mixed with k equals length" {
    const s = "ABCDE";
    const k: i32 = 5;
    const expected: i32 = 5;
    const result = try characterReplacement(std.testing.allocator, s, k);
    std.debug.print("Test 'mixed with k equals length': s={s}, k={}, result={}\n", .{ s, k, result });
    try std.testing.expectEqual(expected, result);
}
