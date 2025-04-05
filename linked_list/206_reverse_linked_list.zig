const std = @import("std");

const ListNode = struct {
    val: i32,
    next: ?*ListNode,
};

const Solution = struct {
    const Self = @This();

    pub fn reverseList(head: ?*ListNode) ?*ListNode {
        var prev: ?*ListNode = null;
        var current = head;
        while (current) |node| {
            const next = node.next;
            node.next = prev;
            prev = node;
            current = next;
        }
        return prev;
    }
};

pub fn main() !void {}

test "reverse linked list - empty list" {
    const head: ?*ListNode = null;
    const result = Solution.reverseList(head);
    try std.testing.expect(result == null);
}

test "reverse linked list - single node" {
    var node = ListNode{ .val = 1, .next = null };
    const result = Solution.reverseList(&node);
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(i32, 1), result.?.val);
    try std.testing.expect(result.?.next == null);
}

test "reverse linked list - multiple nodes" {
    var node3 = ListNode{ .val = 3, .next = null };
    var node2 = ListNode{ .val = 2, .next = &node3 };
    var node1 = ListNode{ .val = 1, .next = &node2 };

    const result = Solution.reverseList(&node1);
    try std.testing.expect(result != null);
    try std.testing.expectEqual(@as(i32, 3), result.?.val);
    try std.testing.expectEqual(@as(i32, 2), result.?.next.?.val);
    try std.testing.expectEqual(@as(i32, 1), result.?.next.?.next.?.val);
    try std.testing.expect(result.?.next.?.next.?.next == null);
}
