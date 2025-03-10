const std = @import("std");
const Allocator = std.mem.Allocator;

fn minWindow(allocator: Allocator, s: []const u8, t: []const u8) ![]const u8 {
    if (s.len < t.len) return "";
    var t_count = std.AutoHashMap(u8, i32).init(allocator);
    defer t_count.deinit();
    var window_count = std.AutoHashMap(u8, i32).init(allocator);
    defer window_count.deinit();
    var left: usize = 0;
    var right: usize = 0;
    var min_len: i32 = std.math.maxInt(i32);
    var result: []const u8 = "";
    for (t) |char| {
        const count = t_count.get(char) orelse 0;
        try t_count.put(char, count + 1);
    }
    const need = t_count.count();
    var have: usize = 0;

    while (right < s.len) {
        const r_char = s[right];
        const w_count = window_count.get(r_char) orelse 0;
        try window_count.put(r_char, w_count + 1);

        if (t_count.get(r_char)) |t_freq| {
            if (window_count.get(r_char).? == t_freq) {
                have += 1;
            }
        }

        while (have == need) {
            const w_len = right - left + 1;
            if (w_len < min_len) {
                min_len = @intCast(w_len);
                result = s[left .. right + 1];
            }

            const l_char = s[left];
            const w_count_left = window_count.get(l_char).?;
            try window_count.put(l_char, w_count_left - 1);

            if (t_count.get(l_char)) |t_freq| {
                if (window_count.get(l_char).? < t_freq) {
                    have -= 1;
                }
            }
            left += 1;
        }
        right += 1;
    }
    return result;
}

pub fn main() !void {}

test "minimum window substring - basic case" {
    const s = "ADOBECODEBANC";
    const t = "ABC";
    const expected = "BANC";
    const result = try minWindow(std.testing.allocator, s, t);
    std.debug.print("Test 'basic case': s={s}, t={s}, result={s}\n", .{ s, t, result });
    try std.testing.expectEqualStrings(expected, result);
}

test "minimum window substring - minimal match" {
    const s = "a";
    const t = "a";
    const expected = "a";
    const result = try minWindow(std.testing.allocator, s, t);
    std.debug.print("Test 'minimal match': s={s}, t={s}, result={s}\n", .{ s, t, result });
    try std.testing.expectEqualStrings(expected, result);
}

test "minimum window substring - no window" {
    const s = "a";
    const t = "aa";
    const expected = "";
    const result = try minWindow(std.testing.allocator, s, t);
    std.debug.print("Test 'no window': s={s}, t={s}, result={s}\n", .{ s, t, result });
    try std.testing.expectEqualStrings(expected, result);
}

test "minimum window substring - multiple options" {
    const s = "ADOBECODEBANCXYZ";
    const t = "ABC";
    const expected = "BANC";
    const result = try minWindow(std.testing.allocator, s, t);
    std.debug.print("Test 'multiple options': s={s}, t={s}, result={s}\n", .{ s, t, result });
    try std.testing.expectEqualStrings(expected, result);
}

test "minimum window substring - duplicates in t" {
    const s = "aa";
    const t = "aa";
    const expected = "aa";
    const result = try minWindow(std.testing.allocator, s, t);
    std.debug.print("Test 'duplicates in t': s={s}, t={s}, result={s}\n", .{ s, t, result });
    try std.testing.expectEqualStrings(expected, result);
}
