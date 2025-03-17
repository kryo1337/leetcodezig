const std = @import("std");
const Allocator = std.mem.Allocator;

fn largestRectangleArea(allocator: Allocator, heights: []const i32) i32 {
    var stack = std.ArrayList(usize).init(allocator);
    defer stack.deinit();
    var result: i32 = 0;
    for (heights, 0..) |height, i| {
        while (stack.items.len > 0 and heights[stack.items[stack.items.len - 1]] > height) {
            const h = heights[stack.pop()];
            const w = if (stack.items.len == 0) i else i - stack.items[stack.items.len - 1] - 1;
            const area = h * @as(i32, @intCast(w));
            result = @max(area, result);
        }
        stack.append(i) catch unreachable;
    }
    while (stack.items.len > 0) {
        const h = heights[stack.pop()];
        const w = if (stack.items.len == 0) heights.len else heights.len - stack.items[stack.items.len - 1] - 1;
        const area = h * @as(i32, @intCast(w));
        result = @max(area, result);
    }
    return result;
}

pub fn main() !void {}

test "largest rectangle - basic case" {
    const heights = [_]i32{ 2, 1, 5, 6, 2, 3 };
    const expected: i32 = 10;
    const result = largestRectangleArea(std.testing.allocator, &heights);
    std.debug.print("Test 'basic case': heights={any}, result={}\n", .{ heights, result });
    try std.testing.expectEqual(expected, result);
}

test "largest rectangle - single bar" {
    const heights = [_]i32{5};
    const expected: i32 = 5;
    const result = largestRectangleArea(std.testing.allocator, &heights);
    std.debug.print("Test 'single bar': heights={any}, result={}\n", .{ heights, result });
    try std.testing.expectEqual(expected, result);
}

test "largest rectangle - increasing heights" {
    const heights = [_]i32{ 1, 2, 3, 4, 5 };
    const expected: i32 = 9;
    const result = largestRectangleArea(std.testing.allocator, &heights);
    std.debug.print("Test 'increasing heights': heights={any}, result={}\n", .{ heights, result });
    try std.testing.expectEqual(expected, result);
}

test "largest rectangle - decreasing heights" {
    const heights = [_]i32{ 5, 4, 3, 2, 1 };
    const expected: i32 = 9;
    const result = largestRectangleArea(std.testing.allocator, &heights);
    std.debug.print("Test 'decreasing heights': heights={any}, result={}\n", .{ heights, result });
    try std.testing.expectEqual(expected, result);
}

test "largest rectangle - all same height" {
    const heights = [_]i32{ 4, 4, 4, 4 };
    const expected: i32 = 16;
    const result = largestRectangleArea(std.testing.allocator, &heights);
    std.debug.print("Test 'all same height': heights={any}, result={}\n", .{ heights, result });
    try std.testing.expectEqual(expected, result);
}

test "largest rectangle - empty" {
    const heights = [_]i32{};
    const expected: i32 = 0;
    const result = largestRectangleArea(std.testing.allocator, &heights);
    std.debug.print("Test 'empty': heights={any}, result={}\n", .{ heights, result });
    try std.testing.expectEqual(expected, result);
}

test "largest rectangle - two bars" {
    const heights = [_]i32{ 2, 4 };
    const expected: i32 = 4;
    const result = largestRectangleArea(std.testing.allocator, &heights);
    std.debug.print("Test 'two bars': heights={any}, result={}\n", .{ heights, result });
    try std.testing.expectEqual(expected, result);
}
