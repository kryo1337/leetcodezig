const std = @import("std");

fn minEatingSpeed(piles: []const i32, h: i32) i32 {
    var max_pile: i32 = 0;
    for (piles) |pile| {
        max_pile = @max(max_pile, pile);
    }
    var left: i32 = 1;
    var right: i32 = max_pile;
    var min_speed: i32 = max_pile;

    while (left <= right) {
        const k = left + @divTrunc(right - left, 2);
        var hours: i64 = 0;
        for (piles) |pile| {
            hours += @divTrunc(pile + k - 1, k);
        }
        if (hours <= h) {
            min_speed = k;
            right = k - 1;
        } else {
            left = k + 1;
        }
    }
    return min_speed;
}

pub fn main() !void {}

test "koko eating - basic case" {
    const piles = [_]i32{ 3, 6, 7, 11 };
    const h: i32 = 8;
    const expected: i32 = 4;
    const result = minEatingSpeed(&piles, h);
    std.debug.print("Test 'basic case': piles={any}, h={}, result={}\n", .{ piles, h, result });
    try std.testing.expectEqual(expected, result);
}

test "koko eating - single pile" {
    const piles = [_]i32{30};
    const h: i32 = 1;
    const expected: i32 = 30;
    const result = minEatingSpeed(&piles, h);
    std.debug.print("Test 'single pile': piles={any}, h={}, result={}\n", .{ piles, h, result });
    try std.testing.expectEqual(expected, result);
}

test "koko eating - exact hours" {
    const piles = [_]i32{ 1, 1, 1, 1 };
    const h: i32 = 4;
    const expected: i32 = 1;
    const result = minEatingSpeed(&piles, h);
    std.debug.print("Test 'exact hours': piles={any}, h={}, result={}\n", .{ piles, h, result });
    try std.testing.expectEqual(expected, result);
}

test "koko eating - large piles" {
    const piles = [_]i32{312884470};
    const h: i32 = 968709470;
    const expected: i32 = 1;
    const result = minEatingSpeed(&piles, h);
    std.debug.print("Test 'large piles': piles={any}, h={}, result={}\n", .{ piles, h, result });
    try std.testing.expectEqual(expected, result);
}

test "koko eating - equal piles" {
    const piles = [_]i32{ 5, 5, 5 };
    const h: i32 = 3;
    const expected: i32 = 5;
    const result = minEatingSpeed(&piles, h);
    std.debug.print("Test 'equal piles': piles={any}, h={}, result={}\n", .{ piles, h, result });
    try std.testing.expectEqual(expected, result);
}
