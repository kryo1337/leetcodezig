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

fn removeNthFromEnd(head: ?*ListNode, n: i32, allocator: Allocator) ?*ListNode {
    var dummy = ListNode{ .val = 0, .next = head };
    var slow = &dummy;
    var fast = &dummy;
    for (0..@as(usize, @intCast(n))) |_| {
        fast = fast.next.?;
    }
    while (fast.next != null) {
        slow = slow.next.?;
        fast = fast.next.?;
    }
    const remove = slow.next;
    slow.next = slow.next.?.next;
    if (remove != null) {
        allocator.destroy(remove.?);
    }
    return dummy.next;
}

pub fn main() !void {}

test "remove nth from end - basic case" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 3, 4, 5 });
    const n: i32 = 2;

    const result = removeNthFromEnd(head, n, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 1, 2, 3, 5 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "remove nth from end - single node" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{1});
    const n: i32 = 1;

    const result = removeNthFromEnd(head, n, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{};
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "remove nth from end - two nodes remove last" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2 });
    const n: i32 = 1;

    const result = removeNthFromEnd(head, n, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{1};
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "remove nth from end - two nodes remove first" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2 });
    const n: i32 = 2;

    const result = removeNthFromEnd(head, n, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{2};
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "remove nth from end - remove first in longer list" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 3, 4, 5 });
    const n: i32 = 5;

    const result = removeNthFromEnd(head, n, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 2, 3, 4, 5 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}
