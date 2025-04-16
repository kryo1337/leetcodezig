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

fn compareNodes(c: void, a: *ListNode, b: *ListNode) std.math.Order {
    _ = c;
    if (a.val < b.val) return .lt;
    if (a.val > b.val) return .gt;
    return .eq;
}

fn mergeKLists(lists: []?*ListNode, allocator: Allocator) !?*ListNode {
    var pq = std.PriorityQueue(*ListNode, void, compareNodes).init(allocator, {});
    defer pq.deinit();

    for (lists) |list| {
        if (list) |node| {
            try pq.add(node);
        }
    }
    var dummy = ListNode{ .val = 0, .next = null };
    var tail = &dummy;

    while (pq.count() > 0) {
        const node = pq.removeOrNull().?;
        tail.next = try allocator.create(ListNode);
        tail = tail.next.?;
        tail.* = ListNode{ .val = node.val, .next = null };

        if (node.next) |next| {
            try pq.add(next);
        }
    }
    return dummy.next;
}

pub fn main() !void {}

test "merge k lists - example case" {
    const allocator = std.testing.allocator;
    var lists = [_]?*ListNode{
        try ListNode.fromArray(allocator, &[_]i32{ 1, 4, 5 }),
        try ListNode.fromArray(allocator, &[_]i32{ 1, 3, 4 }),
        try ListNode.fromArray(allocator, &[_]i32{ 2, 6 }),
    };
    defer for (lists) |list| ListNode.free(list, allocator);

    const result = try mergeKLists(&lists, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 1, 1, 2, 3, 4, 4, 5, 6 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "merge k lists - empty array" {
    const allocator = std.testing.allocator;
    var lists = [_]?*ListNode{};
    defer for (lists) |list| ListNode.free(list, allocator);

    const result = try mergeKLists(&lists, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{};
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "merge k lists - single empty list" {
    const allocator = std.testing.allocator;
    var lists = [_]?*ListNode{null};
    defer for (lists) |list| ListNode.free(list, allocator);

    const result = try mergeKLists(&lists, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{};
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "merge k lists - single list" {
    const allocator = std.testing.allocator;
    var lists = [_]?*ListNode{
        try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 3 }),
    };
    defer for (lists) |list| ListNode.free(list, allocator);

    const result = try mergeKLists(&lists, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 1, 2, 3 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "merge k lists - multiple empty lists" {
    const allocator = std.testing.allocator;
    var lists = [_]?*ListNode{ null, null, null };
    defer for (lists) |list| ListNode.free(list, allocator);

    const result = try mergeKLists(&lists, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{};
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "merge k lists - lists with single elements" {
    const allocator = std.testing.allocator;
    var lists = [_]?*ListNode{
        try ListNode.fromArray(allocator, &[_]i32{1}),
        try ListNode.fromArray(allocator, &[_]i32{2}),
        try ListNode.fromArray(allocator, &[_]i32{3}),
    };
    defer for (lists) |list| ListNode.free(list, allocator);

    const result = try mergeKLists(&lists, allocator);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 1, 2, 3 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}
