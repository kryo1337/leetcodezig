const std = @import("std");
const Allocator = std.mem.Allocator;

fn checkInclusion(allocator: Allocator, s1: []const u8, s2: []const u8) !bool {
    if (s2.len < s1.len) return false;

    var s1_count = std.AutoHashMap(u8, i32).init(allocator);
    defer s1_count.deinit();
    var window_count = std.AutoHashMap(u8, i32).init(allocator);
    defer window_count.deinit();
    var left: usize = 0;
    var right: usize = s1.len - 1;

    for (s1) |char| {
        const count = s1_count.get(char) orelse 0;
        try s1_count.put(char, count + 1);
    }

    for (s2[0..s1.len]) |char| {
        const count = window_count.get(char) orelse 0;
        try window_count.put(char, count + 1);
    }

    if (areCountEqual(&s1_count, &window_count)) return true;

    while (right < s2.len - 1) {
        right += 1;
        const left_char = s2[left];
        const left_count = window_count.get(left_char).?;
        try window_count.put(left_char, left_count - 1);
        if (left_count == 1) _ = window_count.remove(left_char);

        left += 1;
        const right_char = s2[right];
        const right_count = window_count.get(right_char) orelse 0;
        try window_count.put(right_char, right_count + 1);

        if (areCountEqual(&s1_count, &window_count)) return true;
    }

    return false;
}

fn areCountEqual(s1_count: *std.AutoHashMap(u8, i32), window_count: *std.AutoHashMap(u8, i32)) bool {
    if (s1_count.count() != window_count.count()) return false;

    var s1_iter = s1_count.iterator();
    while (s1_iter.next()) |entry| {
        const char = entry.key_ptr.*;
        const s1_freq = entry.value_ptr.*;
        const window_freq = window_count.get(char) orelse return false;
        if (s1_freq != window_freq) return false;
    }
    return true;
}

pub fn main() !void {}

test "permutation in string - basic case" {
    const s1 = "ab";
    const s2 = "eidbaooo";
    const expected: bool = true;
    const result = try checkInclusion(std.testing.allocator, s1, s2);
    std.debug.print("Test 'basic case': s1={s}, s2={s}, result={}\n", .{ s1, s2, result });
    try std.testing.expectEqual(expected, result);
}

test "permutation in string - no permutation" {
    const s1 = "ab";
    const s2 = "eidboaoo";
    const expected: bool = false;
    const result = try checkInclusion(std.testing.allocator, s1, s2);
    std.debug.print("Test 'no permutation': s1={s}, s2={s}, result={}\n", .{ s1, s2, result });
    try std.testing.expectEqual(expected, result);
}

test "permutation in string - full match" {
    const s1 = "abc";
    const s2 = "bca";
    const expected: bool = true;
    const result = try checkInclusion(std.testing.allocator, s1, s2);
    std.debug.print("Test 'full match': s1={s}, s2={s}, result={}\n", .{ s1, s2, result });
    try std.testing.expectEqual(expected, result);
}

test "permutation in string - minimal strings" {
    const s1 = "a";
    const s2 = "a";
    const expected: bool = true;
    const result = try checkInclusion(std.testing.allocator, s1, s2);
    std.debug.print("Test 'minimal strings': s1={s}, s2={s}, result={}\n", .{ s1, s2, result });
    try std.testing.expectEqual(expected, result);
}

test "permutation in string - s2 shorter than s1" {
    const s1 = "abc";
    const s2 = "ab";
    const expected: bool = false;
    const result = try checkInclusion(std.testing.allocator, s1, s2);
    std.debug.print("Test 's2 shorter than s1': s1={s}, s2={s}, result={}\n", .{ s1, s2, result });
    try std.testing.expectEqual(expected, result);
}
