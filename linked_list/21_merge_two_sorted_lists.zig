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

fn mergeTwoLists(list1: ?*ListNode, list2: ?*ListNode) ?*ListNode {
    var dummy = ListNode{ .val = 0, .next = null };
    var current: *ListNode = &dummy;

    var node1 = list1;
    var node2 = list2;

    while (node1 != null and node2 != null) {
        if (node1.?.val <= node2.?.val) {
            current.next = node1;
            node1 = node1.?.next;
        } else {
            current.next = node2;
            node2 = node2.?.next;
        }
        current = current.next.?;
    }
    if (node1 != null) {
        current.next = node1;
    }
    if (node2 != null) {
        current.next = node2;
    }
    return dummy.next;
}

pub fn main() !void {}

test "merge two lists - basic case" {
    const allocator = std.testing.allocator;
    const list1 = try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 4 });
    const list2 = try ListNode.fromArray(allocator, &[_]i32{ 1, 3, 4 });

    const merged = mergeTwoLists(list1, list2);
    defer ListNode.free(merged, allocator);

    const expected = [_]i32{ 1, 1, 2, 3, 4, 4 };
    const result = try ListNode.toArray(merged, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "merge two lists - empty lists" {
    const allocator = std.testing.allocator;
    const list1 = try ListNode.fromArray(allocator, &[_]i32{});
    const list2 = try ListNode.fromArray(allocator, &[_]i32{});

    const merged = mergeTwoLists(list1, list2);
    defer ListNode.free(merged, allocator);

    const expected = [_]i32{};
    const result = try ListNode.toArray(merged, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "merge two lists - one empty list" {
    const allocator = std.testing.allocator;
    const list1 = try ListNode.fromArray(allocator, &[_]i32{});
    const list2 = try ListNode.fromArray(allocator, &[_]i32{ 0, 1 });

    const merged = mergeTwoLists(list1, list2);
    defer ListNode.free(merged, allocator);

    const expected = [_]i32{ 0, 1 };
    const result = try ListNode.toArray(merged, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "merge two lists - single element lists" {
    const allocator = std.testing.allocator;
    const list1 = try ListNode.fromArray(allocator, &[_]i32{1});
    const list2 = try ListNode.fromArray(allocator, &[_]i32{2});

    const merged = mergeTwoLists(list1, list2);
    defer ListNode.free(merged, allocator);

    const expected = [_]i32{ 1, 2 };
    const result = try ListNode.toArray(merged, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "merge two lists - unequal length lists" {
    const allocator = std.testing.allocator;
    const list1 = try ListNode.fromArray(allocator, &[_]i32{ 1, 2 });
    const list2 = try ListNode.fromArray(allocator, &[_]i32{ 3, 4, 5, 6 });

    const merged = mergeTwoLists(list1, list2);
    defer ListNode.free(merged, allocator);

    const expected = [_]i32{ 1, 2, 3, 4, 5, 6 };
    const result = try ListNode.toArray(merged, allocator);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &expected, result);
}
