const std = @import("std");

pub const ListNode = struct {
    val: i32,
    next: ?*ListNode,

    pub fn init(val: i32) ListNode {
        return ListNode{ .val = val, .next = null };
    }

    pub fn fromArray(allocator: std.mem.Allocator, values: []const i32) !?*ListNode {
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

    pub fn fromArrayWithCycle(allocator: std.mem.Allocator, values: []const i32, pos: i32) !?*ListNode {
        if (values.len == 0) return null;
        var nodes = std.ArrayList(*ListNode).init(allocator);
        defer nodes.deinit();

        var dummy = ListNode{ .val = 0, .next = null };
        var current: *ListNode = &dummy;
        for (values) |val| {
            current.next = try allocator.create(ListNode);
            current = current.next.?;
            current.* = ListNode.init(val);
            try nodes.append(current);
        }

        if (pos >= 0) {
            current.next = nodes.items[@intCast(pos)];
        }

        return dummy.next;
    }

    pub fn free(self: ?*ListNode, allocator: std.mem.Allocator) void {
        var current = self;
        while (current) |node| {
            const next = node.next;
            allocator.destroy(node);
            current = next;
        }
    }
};

fn hasCycle(head: ?*const ListNode) bool {
    var slow = head;
    var fast = head;

    while (fast != null and fast.?.next != null) {
        slow = slow.?.next;
        fast = fast.?.next.?.next;
        if (slow == fast) {
            return true;
        }
    }
    return false;
}

pub fn main() !void {}

test "linked list cycle - has cycle" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArrayWithCycle(allocator, &[_]i32{ 3, 2, 0, -4 }, 1);

    const result = hasCycle(head);
    try std.testing.expectEqual(true, result);

    var nodes = std.ArrayList(*ListNode).init(allocator);
    defer nodes.deinit();
    var current = head;
    while (current) |node| {
        var is_duplicate = false;
        for (nodes.items) |seen_node| {
            if (seen_node == node) {
                node.next = null;
                is_duplicate = true;
                break;
            }
        }
        if (!is_duplicate) {
            try nodes.append(@constCast(node));
        }
        current = node.next;
    }

    for (nodes.items) |node| {
        allocator.destroy(node);
    }
}

test "linked list cycle - no cycle" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2 });
    defer ListNode.free(head, allocator);

    const result = hasCycle(head);
    try std.testing.expectEqual(false, result);
}

test "linked list cycle - single node no cycle" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{1});
    defer ListNode.free(head, allocator);

    const result = hasCycle(head);
    try std.testing.expectEqual(false, result);
}

test "linked list cycle - empty list" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{});
    defer ListNode.free(head, allocator);

    const result = hasCycle(head);
    try std.testing.expectEqual(false, result);
}

test "linked list cycle - cycle at start" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArrayWithCycle(allocator, &[_]i32{ 1, 2, 3 }, 0);

    const result = hasCycle(head);
    try std.testing.expectEqual(true, result);

    var nodes = std.ArrayList(*ListNode).init(allocator);
    defer nodes.deinit();
    var current = head;
    while (current) |node| {
        var is_duplicate = false;
        for (nodes.items) |seen_node| {
            if (seen_node == node) {
                node.next = null;
                is_duplicate = true;
                break;
            }
        }
        if (!is_duplicate) {
            try nodes.append(@constCast(node));
        }
        current = node.next;
    }

    for (nodes.items) |node| {
        allocator.destroy(node);
    }
}
