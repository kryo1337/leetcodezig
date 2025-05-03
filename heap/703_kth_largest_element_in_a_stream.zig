const std = @import("std");
const Allocator = std.mem.Allocator;

pub const KthLargest = struct {
    k: usize,
    heap: std.PriorityQueue(i32, void, compare),
    allocator: Allocator,

    fn compare(context: void, a: i32, b: i32) std.math.Order {
        _ = context;
        return std.math.order(a, b);
    }

    pub fn init(allocator: Allocator, k: i32, nums: []const i32) !KthLargest {
        const heap = std.PriorityQueue(i32, void, compare).init(allocator, {});
        var self = KthLargest{
            .k = @intCast(k),
            .heap = heap,
            .allocator = allocator,
        };
        for (nums) |num| {
            try self.heap.add(num);
            if (self.heap.count() > self.k) {
                _ = self.heap.remove();
            }
        }
        return self;
    }

    pub fn deinit(self: *KthLargest) void {
        self.heap.deinit();
    }

    pub fn add(self: *KthLargest, val: i32) i32 {
        self.heap.add(val) catch unreachable;
        if (self.heap.count() > self.k) {
            _ = self.heap.remove();
        }
        return self.heap.peek().?;
    }
};

pub fn main() !void {}

test "kth largest - example 1" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ 4, 5, 8, 2 };
    var kthLargest = try KthLargest.init(allocator, 3, &nums);
    defer kthLargest.deinit();

    try std.testing.expectEqual(@as(i32, 4), kthLargest.add(3));
    try std.testing.expectEqual(@as(i32, 5), kthLargest.add(5));
    try std.testing.expectEqual(@as(i32, 5), kthLargest.add(10));
    try std.testing.expectEqual(@as(i32, 8), kthLargest.add(9));
    try std.testing.expectEqual(@as(i32, 8), kthLargest.add(4));
}

test "kth largest - single element" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{1};
    var kthLargest = try KthLargest.init(allocator, 1, &nums);
    defer kthLargest.deinit();

    try std.testing.expectEqual(@as(i32, 2), kthLargest.add(2));
    try std.testing.expectEqual(@as(i32, 3), kthLargest.add(3));
}

test "kth largest - k equals stream length" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ 5, 2, 8 };
    var kthLargest = try KthLargest.init(allocator, 3, &nums);
    defer kthLargest.deinit();

    try std.testing.expectEqual(@as(i32, 2), kthLargest.add(1));
}

test "kth largest - negative numbers" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ -1, -2, -3 };
    var kthLargest = try KthLargest.init(allocator, 2, &nums);
    defer kthLargest.deinit();

    try std.testing.expectEqual(@as(i32, -2), kthLargest.add(-4));
    try std.testing.expectEqual(@as(i32, -1), kthLargest.add(0));
}
