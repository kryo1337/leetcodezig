const std = @import("std");

fn isAnagram(s: []const u8, t: []const u8) bool {
    if (s.len != t.len) return false;

    var count = std.mem.zeroes([26]i32);
    for (s) |c| {
        count[c - 'a'] += 1;
    }
    for (t) |c| {
        count[c - 'a'] -= 1;
        if (count[c - 'a'] < 0) return false;
    }
    return true;
}

pub fn main() !void {
    std.debug.print("run zig test", .{});
}

test "valid anagram - true" {
    const s = "anagram";
    const t = "nagaram";
    const result = isAnagram(s, t);
    std.debug.print("Test 'valid anagram - true': s='{s}', t='{s}', result={}\n", .{ s, t, result });
    try std.testing.expect(result == true);
}

test "valid anagram - false" {
    const s = "rat";
    const t = "car";
    const result = isAnagram(s, t);
    std.debug.print("Test 'valid anagram - false': s='{s}', t='{s}', result={}\n", .{ s, t, result });
    try std.testing.expect(result == false);
}

test "valid anagram - different lengths" {
    const s = "hello";
    const t = "hell";
    const result = isAnagram(s, t);
    std.debug.print("Test 'different lengths': s='{s}', t='{s}', result={}\n", .{ s, t, result });
    try std.testing.expect(result == false);
}

test "valid anagram - empty strings" {
    const s = "";
    const t = "";
    const result = isAnagram(s, t);
    std.debug.print("Test 'empty strings': s='{s}', t='{s}', result={}\n", .{ s, t, result });
    try std.testing.expect(result == true);
}
