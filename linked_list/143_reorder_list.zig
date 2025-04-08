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

fn reorderList(head: ?*ListNode) void {
    if (head == null or head.?.next == null) return;
    var slow = head;
    var fast = head;

    while (fast != null and fast.?.next != null) {
        slow = slow.?.next;
        fast = fast.?.next.?.next;
    }

    var second = slow.?.next;
    slow.?.next = null;

    var prev: ?*ListNode = null;
    var curr = second;
    while (curr != null) {
        const next = curr.?.next;
        curr.?.next = prev;
        prev = curr;
        curr = next;
    }
    second = prev;

    var p1 = head;
    var p2 = second;
    while (p1 != null and p2 != null) {
        const p1next = p1.?.next;
        const p2next = p2.?.next;
        p1.?.next = p2;
        p2.?.next = p1next;
        p1 = p1next;
        p2 = p2next;
    }
}

pub fn main() !void {}

test "reorder list - even length" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 3, 4 });

    reorderList(head);

    const expected = [_]i32{ 1, 4, 2, 3 };
    const result = try ListNode.toArray(head, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &expected, result);

    ListNode.free(head, allocator);
}

test "reorder list - odd length" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 3, 4, 5 });

    reorderList(head);

    const expected = [_]i32{ 1, 5, 2, 4, 3 };
    const result = try ListNode.toArray(head, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &expected, result);

    ListNode.free(head, allocator);
}

test "reorder list - empty list" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{});

    reorderList(head);

    const expected = [_]i32{};
    const result = try ListNode.toArray(head, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &expected, result);

    ListNode.free(head, allocator);
}

test "reorder list - single node" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{1});

    reorderList(head);

    const expected = [_]i32{1};
    const result = try ListNode.toArray(head, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &expected, result);

    ListNode.free(head, allocator);
}

test "reorder list - two nodes" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2 });

    reorderList(head);

    const expected = [_]i32{ 1, 2 };
    const result = try ListNode.toArray(head, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &expected, result);

    ListNode.free(head, allocator);
}
