const std = @import("std");
const Allocator = std.mem.Allocator;

fn evalRPN(allocator: Allocator, tokens: []const []const u8) !i32 {
    var stack = std.ArrayList(i32).init(allocator);
    defer stack.deinit();

    for (tokens) |token| {
        if (std.mem.eql(u8, token, "+")) {
            if (stack.items.len < 2) return error.InvalidExpression;
            const first = stack.pop();
            const second = stack.pop();
            try stack.append(second + first);
        } else if (std.mem.eql(u8, token, "-")) {
            if (stack.items.len < 2) return error.InvalidExpression;
            const first = stack.pop();
            const second = stack.pop();
            try stack.append(second - first);
        } else if (std.mem.eql(u8, token, "*")) {
            if (stack.items.len < 2) return error.InvalidExpression;
            const first = stack.pop();
            const second = stack.pop();
            try stack.append(second * first);
        } else if (std.mem.eql(u8, token, "/")) {
            if (stack.items.len < 2) return error.InvalidExpression;
            const first = stack.pop();
            const second = stack.pop();
            if (first == 0) return error.DivisionByZero;
            try stack.append(@divTrunc(second, first));
        } else {
            const num = try std.fmt.parseInt(i32, token, 10);
            try stack.append(num);
        }
    }

    if (stack.items.len != 1) return error.InvalidExpression;
    return stack.items[0];
}

pub fn main() !void {}

test "evaluate RPN - basic addition" {
    const tokens = [_][]const u8{ "2", "1", "+" };
    const expected: i32 = 3;
    const result = try evalRPN(std.testing.allocator, &tokens);
    std.debug.print("Test 'basic addition': tokens={any}, result={}\n", .{ tokens, result });
    try std.testing.expectEqual(expected, result);
}

test "evaluate RPN - basic subtraction" {
    const tokens = [_][]const u8{ "4", "13", "-" };
    const expected: i32 = -9;
    const result = try evalRPN(std.testing.allocator, &tokens);
    std.debug.print("Test 'basic subtraction': tokens={any}, result={}\n", .{ tokens, result });
    try std.testing.expectEqual(expected, result);
}

test "evaluate RPN - multiplication and addition" {
    const tokens = [_][]const u8{ "2", "3", "*", "4", "+" };
    const expected: i32 = 10;
    const result = try evalRPN(std.testing.allocator, &tokens);
    std.debug.print("Test 'multiplication and addition': tokens={any}, result={}\n", .{ tokens, result });
    try std.testing.expectEqual(expected, result);
}

test "evaluate RPN - complex expression" {
    const tokens = [_][]const u8{ "10", "6", "9", "3", "+", "-11", "*", "/", "*", "17", "+", "5", "+" };
    const expected: i32 = 22;
    const result = try evalRPN(std.testing.allocator, &tokens);
    std.debug.print("Test 'complex expression': tokens={any}, result={}\n", .{ tokens, result });
    try std.testing.expectEqual(expected, result);
}

test "evaluate RPN - single number" {
    const tokens = [_][]const u8{"42"};
    const expected: i32 = 42;
    const result = try evalRPN(std.testing.allocator, &tokens);
    std.debug.print("Test 'single number': tokens={any}, result={}\n", .{ tokens, result });
    try std.testing.expectEqual(expected, result);
}

test "evaluate RPN - division" {
    const tokens = [_][]const u8{ "6", "3", "/" };
    const expected: i32 = 2;
    const result = try evalRPN(std.testing.allocator, &tokens);
    std.debug.print("Test 'division': tokens={any}, result={}\n", .{ tokens, result });
    try std.testing.expectEqual(expected, result);
}

test "evaluate RPN - negative numbers" {
    const tokens = [_][]const u8{ "-5", "3", "+" };
    const expected: i32 = -2;
    const result = try evalRPN(std.testing.allocator, &tokens);
    std.debug.print("Test 'negative numbers': tokens={any}, result={}\n", .{ tokens, result });
    try std.testing.expectEqual(expected, result);
}
