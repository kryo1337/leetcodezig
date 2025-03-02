const std = @import("std");

fn maxProfit(prices: []const i32) i32 {
    if (prices.len < 2) return 0;

    var min_price: i32 = std.math.maxInt(i32);
    var max_profit: i32 = 0;
    for (prices) |num| {
        min_price = @min(min_price, num);
        const profit = num - min_price;
        max_profit = @max(max_profit, profit);
    }
    return max_profit;
}

pub fn main() !void {}

test "best time to buy and sell - basic case" {
    const prices = [_]i32{ 7, 1, 5, 3, 6, 4 };
    const expected: i32 = 5;
    const result = maxProfit(&prices);
    std.debug.print("Test 'basic case': prices={any}, result={}\n", .{ prices, result });
    try std.testing.expectEqual(expected, result);
}

test "best time to buy and sell - no profit" {
    const prices = [_]i32{ 7, 6, 4, 3, 1 };
    const expected: i32 = 0;
    const result = maxProfit(&prices);
    std.debug.print("Test 'no profit': prices={any}, result={}\n", .{ prices, result });
    try std.testing.expectEqual(expected, result);
}

test "best time to buy and sell - short array" {
    const prices = [_]i32{ 2, 4, 1 };
    const expected: i32 = 2;
    const result = maxProfit(&prices);
    std.debug.print("Test 'short array': prices={any}, result={}\n", .{ prices, result });
    try std.testing.expectEqual(expected, result);
}

test "best time to buy and sell - single price" {
    const prices = [_]i32{3};
    const expected: i32 = 0;
    const result = maxProfit(&prices);
    std.debug.print("Test 'single price': prices={any}, result={}\n", .{ prices, result });
    try std.testing.expectEqual(expected, result);
}

test "best time to buy and sell - increasing prices" {
    const prices = [_]i32{ 1, 2, 3, 4, 5 };
    const expected: i32 = 4;
    const result = maxProfit(&prices);
    std.debug.print("Test 'increasing prices': prices={any}, result={}\n", .{ prices, result });
    try std.testing.expectEqual(expected, result);
}
