const std = @import("std");
const Allocator = std.mem.Allocator;

fn generateParenthesis(allocator: Allocator, n: i32) ![][]u8 {
    var result = std.ArrayList([]u8).init(allocator);
    defer result.deinit();

    const current = try allocator.alloc(u8, @intCast(2 * n));
    defer allocator.free(current);

    try backtrack(allocator, &result, current, 0, n, n);
    return result.toOwnedSlice();
}

fn backtrack(allocator: Allocator, result: *std.ArrayList([]u8), current: []u8, pos: usize, open: i32, close: i32) !void {
    if (open == 0 and close == 0) {
        const str = try allocator.alloc(u8, current.len);
        @memcpy(str, current);
        try result.append(str);
        return;
    }

    if (open > 0) {
        current[pos] = '(';
        try backtrack(allocator, result, current, pos + 1, open - 1, close);
    }

    if (close > open) {
        current[pos] = ')';
        try backtrack(allocator, result, current, pos + 1, open, close - 1);
    }
}

pub fn main() !void {}

test "generate parentheses - n = 1" {
    const n: i32 = 1;
    const expected = [_][]const u8{"()"};
    const result = try generateParenthesis(std.testing.allocator, n);
    defer {
        for (result) |s| std.testing.allocator.free(s);
        std.testing.allocator.free(result);
    }
    std.debug.print("Test 'n = 1': result={any}\n", .{result});
    try std.testing.expectEqual(expected.len, result.len);
    for (expected, result) |exp, res| {
        try std.testing.expectEqualStrings(exp, res);
    }
}

test "generate parentheses - n = 2" {
    const n: i32 = 2;
    const expected = [_][]const u8{ "(())", "()()" };
    const result = try generateParenthesis(std.testing.allocator, n);
    defer {
        for (result) |s| std.testing.allocator.free(s);
        std.testing.allocator.free(result);
    }
    std.debug.print("Test 'n = 2': result={any}\n", .{result});
    try std.testing.expectEqual(expected.len, result.len);
    for (expected, result) |exp, res| {
        try std.testing.expectEqualStrings(exp, res);
    }
}

test "generate parentheses - n = 3" {
    const n: i32 = 3;
    const expected = [_][]const u8{ "((()))", "(()())", "(())()", "()(())", "()()()" };
    const result = try generateParenthesis(std.testing.allocator, n);
    defer {
        for (result) |s| std.testing.allocator.free(s);
        std.testing.allocator.free(result);
    }
    std.debug.print("Test 'n = 3': result={any}\n", .{result});
    try std.testing.expectEqual(expected.len, result.len);
    for (expected, result) |exp, res| {
        try std.testing.expectEqualStrings(exp, res);
    }
}

test "generate parentheses - n = 0" {
    const n: i32 = 0;
    const expected = [_][]const u8{""};
    const result = try generateParenthesis(std.testing.allocator, n);
    defer {
        for (result) |s| std.testing.allocator.free(s);
        std.testing.allocator.free(result);
    }
    std.debug.print("Test 'n = 0': result={any}\n", .{result});
    try std.testing.expectEqual(expected.len, result.len);
    for (expected, result) |exp, res| {
        try std.testing.expectEqualStrings(exp, res);
    }
}
