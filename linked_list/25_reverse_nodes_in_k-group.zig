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

fn reverseKGroup(head: ?*ListNode, k: i32) ?*ListNode {
    if (head == null or k == 1) return head;

    var curr = head;
    var count: i32 = 0;
    while (curr != null and count < k) {
        curr = curr.?.next;
        count += 1;
    }
    if (count < k) return head;

    var prev: ?*ListNode = null;
    curr = head;
    for (0..@intCast(k)) |_| {
        const next = curr.?.next;
        curr.?.next = prev;
        prev = curr;
        curr = next;
    }
    if (head != null) {
        head.?.next = reverseKGroup(curr, k);
    }
    return prev;
}

pub fn main() !void {}

test "reverse k group - k=2" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 3, 4, 5 });

    const result = reverseKGroup(head, 2);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 2, 1, 4, 3, 5 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "reverse k group - k=3" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 3, 4, 5 });

    const result = reverseKGroup(head, 3);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 3, 2, 1, 4, 5 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "reverse k group - k=1" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 3, 4, 5 });

    const result = reverseKGroup(head, 1);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 1, 2, 3, 4, 5 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "reverse k group - k larger than list length" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2 });

    const result = reverseKGroup(head, 3);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 1, 2 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "reverse k group - empty list" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{});

    const result = reverseKGroup(head, 2);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{};
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}

test "reverse k group - exact k nodes" {
    const allocator = std.testing.allocator;
    const head = try ListNode.fromArray(allocator, &[_]i32{ 1, 2, 3 });

    const result = reverseKGroup(head, 3);
    defer ListNode.free(result, allocator);

    const expected = [_]i32{ 3, 2, 1 };
    const result_array = try ListNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(i32, &expected, result_array);
}
