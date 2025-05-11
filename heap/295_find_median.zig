const std = @import("std");
const Allocator = std.mem.Allocator;

fn compareMin(_: void, a: i32, b: i32) std.math.Order {
    return std.math.order(a, b);
}

fn compareMax(_: void, a: i32, b: i32) std.math.Order {
    return std.math.order(b, a);
}

pub const MedianFinder = struct {
    allocator: Allocator,
    max_heap: std.PriorityQueue(i32, void, compareMax),
    min_heap: std.PriorityQueue(i32, void, compareMin),

    pub fn init(allocator: Allocator) !*MedianFinder {
        var self = try allocator.create(MedianFinder);
        self.allocator = allocator;
        self.max_heap = std.PriorityQueue(i32, void, compareMax).init(allocator, {});
        self.min_heap = std.PriorityQueue(i32, void, compareMin).init(allocator, {});
        return self;
    }

    pub fn deinit(self: *MedianFinder) void {
        self.max_heap.deinit();
        self.min_heap.deinit();
        self.allocator.destroy(self);
    }

    pub fn addNum(self: *MedianFinder, num: i32) !void {
        if (self.max_heap.count() == 0 or num <= self.max_heap.peek().?) {
            try self.max_heap.add(num);
        } else {
            try self.min_heap.add(num);
        }

        if (self.max_heap.count() > self.min_heap.count() + 1) {
            const max = self.max_heap.remove();
            try self.min_heap.add(max);
        } else if (self.min_heap.count() > self.max_heap.count()) {
            const min = self.min_heap.remove();
            try self.max_heap.add(min);
        }
    }

    pub fn findMedian(self: *MedianFinder) f64 {
        if (self.max_heap.count() == self.min_heap.count()) {
            return @as(f64, @floatFromInt(self.max_heap.peek().? + self.min_heap.peek().?)) / 2.0;
        } else if (self.max_heap.count() > self.min_heap.count()) {
            return @floatFromInt(self.max_heap.peek().?);
        } else {
            return @floatFromInt(self.min_heap.peek().?);
        }
    }
};

pub fn main() !void {}

test "median finder - basic operations" {
    const allocator = std.testing.allocator;
    var finder = try MedianFinder.init(allocator);
    defer finder.deinit();

    try finder.addNum(1);
    try finder.addNum(2);
    try std.testing.expectEqual(@as(f64, 1.5), finder.findMedian());

    try finder.addNum(3);
    try std.testing.expectEqual(@as(f64, 2.0), finder.findMedian());
}

test "median finder - negative numbers" {
    const allocator = std.testing.allocator;
    var finder = try MedianFinder.init(allocator);
    defer finder.deinit();

    try finder.addNum(-1);
    try finder.addNum(-2);
    try std.testing.expectEqual(@as(f64, -1.5), finder.findMedian());

    try finder.addNum(-3);
    try std.testing.expectEqual(@as(f64, -2.0), finder.findMedian());
}

test "median finder - large numbers" {
    const allocator = std.testing.allocator;
    var finder = try MedianFinder.init(allocator);
    defer finder.deinit();

    try finder.addNum(1000);
    try finder.addNum(2000);
    try std.testing.expectEqual(@as(f64, 1500.0), finder.findMedian());

    try finder.addNum(3000);
    try std.testing.expectEqual(@as(f64, 2000.0), finder.findMedian());
}



