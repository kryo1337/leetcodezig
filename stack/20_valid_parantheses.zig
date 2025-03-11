const std = @import("std");
const Allocator = std.mem.Allocator;

fn isValid(allocator: Allocator, s: []const u8) !bool {
    var stack = std.ArrayList(u8).init(allocator);
    defer stack.deinit();

    for (s) |char| {
        switch (char) {
            '(', '[', '{' => {
                try stack.append(char);
            },
            ')' => {
                if (stack.items.len == 0 or stack.pop() != '(') {
                    return false;
                }
            },
            ']' => {
                if (stack.items.len == 0 or stack.pop() != '[') {
                    return false;
                }
            },
            '}' => {
                if (stack.items.len == 0 or stack.pop() != '{') {
                    return false;
                }
            },
            else => {
                continue;
            },
        }
    }

    return stack.items.len == 0;
}
pub fn main() !void {}

test "valid parentheses - basic case" {
    const s = "()";
    const expected = true;
    const result = try isValid(std.testing.allocator, s);
    std.debug.print("Test 'basic case': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}

test "valid parentheses - all types" {
    const s = "()[]{}";
    const expected = true;
    const result = try isValid(std.testing.allocator, s);
    std.debug.print("Test 'all types': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}

test "valid parentheses - nested" {
    const s = "{[()]}";
    const expected = true;
    const result = try isValid(std.testing.allocator, s);
    std.debug.print("Test 'nested': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}

test "valid parentheses - single invalid" {
    const s = "(";
    const expected = false;
    const result = try isValid(std.testing.allocator, s);
    std.debug.print("Test 'single invalid': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}

test "valid parentheses - wrong order" {
    const s = "(]";
    const expected = false;
    const result = try isValid(std.testing.allocator, s);
    std.debug.print("Test 'wrong order': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}

test "valid parentheses - empty string" {
    const s = "";
    const expected = true;
    const result = try isValid(std.testing.allocator, s);
    std.debug.print("Test 'empty string': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}

test "valid parentheses - complex invalid" {
    const s = "([)]";
    const expected = false;
    const result = try isValid(std.testing.allocator, s);
    std.debug.print("Test 'complex invalid': s={s}, result={}\n", .{ s, result });
    try std.testing.expectEqual(expected, result);
}
