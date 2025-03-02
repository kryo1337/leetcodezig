const std = @import("std");
const Allocator = std.mem.Allocator;

fn lengthOfLongestSubstring(allocator: Allocator, s: []const u8) !i32 {
    if (s.len == 0) return 0;

    var map = std.AutoHashMap(u8, usize).init(allocator);
    defer map.deinit();
    var left: usize = 0;
    var max_len: i32 = 0;

    for (s, 0..) |char, right| {
        if (map.get(char)) |last_pos| {
            if (last_pos >= left) {
                left = last_pos + 1;
            }
        }
        try map.put(char, right);
        const size = @as(i32, @intCast(right - left + 1));
        max_len = @max(size, max_len);
    }
    return max_len;
}

pub fn main() !void {}

test "longest substring - basic case" {
    const s = "abcabcbb";
    const expected: i32 = 3;
    const result = try lengthOfLongestSubstring(std.testing.allocator, s);
    std.debug.print("Test 'basic case': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}

test "longest substring - all same" {
    const s = "bbbbb";
    const expected: i32 = 1;
    const result = try lengthOfLongestSubstring(std.testing.allocator, s);
    std.debug.print("Test 'all same': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}

test "longest substring - with repeats" {
    const s = "pwwkew";
    const expected: i32 = 3;
    const result = try lengthOfLongestSubstring(std.testing.allocator, s);
    std.debug.print("Test 'with repeats': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}

test "longest substring - empty" {
    const s = "";
    const expected: i32 = 0;
    const result = try lengthOfLongestSubstring(std.testing.allocator, s);
    std.debug.print("Test 'empty': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}

test "longest substring - single char" {
    const s = "a";
    const expected: i32 = 1;
    const result = try lengthOfLongestSubstring(std.testing.allocator, s);
    std.debug.print("Test 'single char': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}
