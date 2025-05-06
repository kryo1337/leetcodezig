const std = @import("std");
const Allocator = std.mem.Allocator;

fn lastStoneWeight(stones: []const i32, allocator: Allocator) i32 {
    if (stones.len == 1) return stones[0];
    var heap = std.PriorityQueue(i32, void, compare).init(allocator, {});
    defer heap.deinit();

    for (stones) |stone| {
        heap.add(stone) catch unreachable;
    }
    while (heap.count() > 1) {
        const stone1 = heap.remove();
        const stone2 = heap.remove();
        if (stone1 != stone2) {
            const remain = stone1 - stone2;
            heap.add(remain) catch unreachable;
        }
    }
    return if (heap.count() > 0) heap.peek().? else 0;
}

fn compare(context: void, a: i32, b: i32) std.math.Order {
    _ = context;
    return std.math.order(b, a);
}

pub fn main() !void {}

test "last stone weight - example 1" {
    const allocator = std.testing.allocator;
    const stones = [_]i32{ 2, 7, 4, 1, 8, 1 };
    const result = lastStoneWeight(&stones, allocator);
    const expected: i32 = 1;
    try std.testing.expectEqual(expected, result);
}

test "last stone weight - single stone" {
    const allocator = std.testing.allocator;
    const stones = [_]i32{1};
    const result = lastStoneWeight(&stones, allocator);
    const expected: i32 = 1;
    try std.testing.expectEqual(expected, result);
}

test "last stone weight - all equal stones" {
    const allocator = std.testing.allocator;
    const stones = [_]i32{ 3, 3, 3, 3 };
    const result = lastStoneWeight(&stones, allocator);
    const expected: i32 = 0;
    try std.testing.expectEqual(expected, result);
}

test "last stone weight - two stones" {
    const allocator = std.testing.allocator;
    const stones = [_]i32{ 5, 3 };
    const result = lastStoneWeight(&stones, allocator);
    const expected: i32 = 2;
    try std.testing.expectEqual(expected, result);
}
