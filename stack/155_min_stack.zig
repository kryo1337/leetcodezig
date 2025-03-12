const std = @import("std");
const Allocator = std.mem.Allocator;

const MinStack = struct {
    stack: std.ArrayList(i32),
    min_stack: std.ArrayList(i32),
    allocator: Allocator,

    fn init(allocator: Allocator) !MinStack {
        return MinStack{
            .stack = std.ArrayList(i32).init(allocator),
            .min_stack = std.ArrayList(i32).init(allocator),
            .allocator = allocator,
        };
    }

    fn deinit(self: *MinStack) void {
        self.stack.deinit();
        self.min_stack.deinit();
    }

    fn push(self: *MinStack, val: i32) !void {
        try self.stack.append(val);
        if (self.min_stack.items.len == 0 or val <= self.getMin()) {
            try self.min_stack.append(val);
        }
    }

    fn pop(self: *MinStack) void {
        if (self.stack.items.len == 0) return;
        const val = self.stack.pop();
        if (val == self.getMin()) {
            _ = self.min_stack.pop();
        }
    }

    fn top(self: *MinStack) i32 {
        if (self.stack.items.len == 0) return 0;
        return self.stack.items[self.stack.items.len - 1];
    }

    fn getMin(self: *MinStack) i32 {
        if (self.min_stack.items.len == 0) return 0;
        return self.min_stack.items[self.min_stack.items.len - 1];
    }
};

pub fn main() !void {}

test "min stack - basic operations" {
    var ms = try MinStack.init(std.testing.allocator);
    defer ms.deinit();

    try ms.push(3);
    try ms.push(5);
    try ms.push(2);
    try ms.push(1);

    try std.testing.expectEqual(@as(i32, 1), ms.top());
    try std.testing.expectEqual(@as(i32, 1), ms.getMin());

    ms.pop();
    try std.testing.expectEqual(@as(i32, 2), ms.top());
    try std.testing.expectEqual(@as(i32, 2), ms.getMin());

    ms.pop();
    try std.testing.expectEqual(@as(i32, 5), ms.top());
    try std.testing.expectEqual(@as(i32, 3), ms.getMin());
}

test "min stack - single element" {
    var ms = try MinStack.init(std.testing.allocator);
    defer ms.deinit();

    try ms.push(42);
    try std.testing.expectEqual(@as(i32, 42), ms.top());
    try std.testing.expectEqual(@as(i32, 42), ms.getMin());

    ms.pop();
}

test "min stack - negative numbers" {
    var ms = try MinStack.init(std.testing.allocator);
    defer ms.deinit();

    try ms.push(-2);
    try ms.push(-5);
    try ms.push(-1);

    try std.testing.expectEqual(@as(i32, -1), ms.top());
    try std.testing.expectEqual(@as(i32, -5), ms.getMin());

    ms.pop();
    try std.testing.expectEqual(@as(i32, -5), ms.getMin());
}

test "min stack - duplicates" {
    var ms = try MinStack.init(std.testing.allocator);
    defer ms.deinit();

    try ms.push(3);
    try ms.push(3);
    try ms.push(3);

    try std.testing.expectEqual(@as(i32, 3), ms.top());
    try std.testing.expectEqual(@as(i32, 3), ms.getMin());

    ms.pop();
    try std.testing.expectEqual(@as(i32, 3), ms.getMin());
}

test "min stack - increasing order" {
    var ms = try MinStack.init(std.testing.allocator);
    defer ms.deinit();

    try ms.push(1);
    try ms.push(2);
    try ms.push(3);

    try std.testing.expectEqual(@as(i32, 3), ms.top());
    try std.testing.expectEqual(@as(i32, 1), ms.getMin());

    ms.pop();
    try std.testing.expectEqual(@as(i32, 2), ms.top());
    try std.testing.expectEqual(@as(i32, 1), ms.getMin());
}

test "min stack - decreasing order" {
    var ms = try MinStack.init(std.testing.allocator);
    defer ms.deinit();

    try ms.push(3);
    try ms.push(2);
    try ms.push(1);

    try std.testing.expectEqual(@as(i32, 1), ms.top());
    try std.testing.expectEqual(@as(i32, 1), ms.getMin());

    ms.pop();
    try std.testing.expectEqual(@as(i32, 2), ms.top());
    try std.testing.expectEqual(@as(i32, 2), ms.getMin());
}
