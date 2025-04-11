const std = @import("std");
const Allocator = std.mem.Allocator;

pub const ListNode = struct {
    val: i32,
    next: ?*ListNode,

    pub fn init(val: i32) ListNode {
        return ListNode{ .val = val, .next = null };
    }

    pub fn fromArray(allocator: Allocator, values: []const i32) !?*ListNode {
        if (values.len == 0) return null;
        var dummy = ListNode{ .val = 0, .next = null };
        var current: *ListNode = &dummy;
        for (values) |val| {
            current.next = try allocator.create(ListNode);
            current = current.next.?;
            current.* = ListNode.init(val);
        }
        return dummy.next;
    }

    pub fn toArray(self: ?*const ListNode, allocator: Allocator) ![]i32 {
        var result = std.ArrayList(i32).init(allocator);
        var current = self;
        while (current) |node| {
            try result.append(node.val);
            current = node.next;
        }
        return result.toOwnedSlice();
    }

    pub fn free(self: ?*ListNode, allocator: Allocator) void {
        var current = self;
        while (current) |node| {
            const next = node.next;
            allocator.destroy(node);
            current = next;
        }
    }
};

fn addTwoNumbers(l1: ?*ListNode, l2: ?*ListNode, allocator: Allocator) !?*ListNode {
    var dummy = ListNode{ .val = 0, .next = null };
    var tail = &dummy;
    var p1 = l1;
    var p2 = l2;
    var carry: i32 = 0;

    while (p1 != null or p2 != null or carry > 0) {
        const x = if (p1 != null) p1.?.val else 0;
        const y = if (p2 != null) p2.?.val else 0;

        const sum = x + y + carry;
        carry = @divTrunc(sum, 10);

        const node = try allocator.create(ListNode);
        node.* = ListNode{ .val = @mod(sum, 10), .next = null };

        tail.next = node;
        tail = node;

        p1 = if (p1 != null) p1.?.next else null;
        p2 = if (p2 != null) p2.?.next else null;
    }
    return dummy.next;
}

pub fn main() !void {}

test "add two numbers - basic case" {
    const allocator = std.testing.allocator;
    const l1 = try ListNode.fromArray(allocator, &[_]i32{ 2, 4, 3 });
    defer ListNode.free(l1, allocator);
    const l2 = try ListNode.fromArray(allocator, &[_]i32{ 5, 6, 4 });
    defer ListNode.free(l2, allocator);

    const result = try addTwoNumbers(l1, l2, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 7, 0, 8 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "add two numbers - both zeros" {
    const allocator = std.testing.allocator;
    const l1 = try ListNode.fromArray(allocator, &[_]i32{0});
    defer ListNode.free(l1, allocator);
    const l2 = try ListNode.fromArray(allocator, &[_]i32{0});
    defer ListNode.free(l2, allocator);

    const result = try addTwoNumbers(l1, l2, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{0};
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "add two numbers - different lengths" {
    const allocator = std.testing.allocator;
    const l1 = try ListNode.fromArray(allocator, &[_]i32{ 9, 9, 9 });
    defer ListNode.free(l1, allocator);
    const l2 = try ListNode.fromArray(allocator, &[_]i32{ 9, 9 });
    defer ListNode.free(l2, allocator);

    const result = try addTwoNumbers(l1, l2, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 8, 9, 0, 1 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "add two numbers - one empty" {
    const allocator = std.testing.allocator;
    const l1 = try ListNode.fromArray(allocator, &[_]i32{});
    defer ListNode.free(l1, allocator);
    const l2 = try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 3 });
    defer ListNode.free(l2, allocator);

    const result = try addTwoNumbers(l1, l2, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 1, 2, 3 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "add two numbers - carry at end" {
    const allocator = std.testing.allocator;
    const l1 = try ListNode.fromArray(allocator, &[_]i32{ 9, 9 });
    defer ListNode.free(l1, allocator);
    const l2 = try ListNode.fromArray(allocator, &[_]i32{1});
    defer ListNode.free(l2, allocator);

    const result = try addTwoNumbers(l1, l2, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 0, 0, 1 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}
