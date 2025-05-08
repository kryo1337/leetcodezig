const std = @import("std");
const Allocator = std.mem.Allocator;

fn findKthLargest(nums: []const i32, k: i32, allocator: Allocator) i32 {
    var heap = std.PriorityQueue(i32, void, compare).init(allocator, {});
    defer heap.deinit();

    for (nums) |num| {
        heap.add(num) catch unreachable;
        if (heap.count() > k) {
            _ = heap.remove();
        }
    }
    return heap.remove();
}

fn compare(_: void, a: i32, b: i32) std.math.Order {
    return std.math.order(a, b);
}

pub fn main() !void {}

test "kth largest - example 1" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ 3, 2, 1, 5, 6, 4 };
    const k: i32 = 2;
    const result = findKthLargest(&nums, k, allocator);
    try std.testing.expectEqual(@as(i32, 5), result);
}

test "kth largest - example 2" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ 3, 2, 3, 1, 2, 4, 5, 5, 6 };
    const k: i32 = 4;
    const result = findKthLargest(&nums, k, allocator);
    try std.testing.expectEqual(@as(i32, 4), result);
}

test "kth largest - single element" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{1};
    const k: i32 = 1;
    const result = findKthLargest(&nums, k, allocator);
    try std.testing.expectEqual(@as(i32, 1), result);
}

test "kth largest - all same elements" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ 2, 2, 2, 2 };
    const k: i32 = 2;
    const result = findKthLargest(&nums, k, allocator);
    try std.testing.expectEqual(@as(i32, 2), result);
}

test "kth largest - negative numbers" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ -1, -2, -3, -4, -5 };
    const k: i32 = 2;
    const result = findKthLargest(&nums, k, allocator);
    try std.testing.expectEqual(@as(i32, -2), result);
}
