const std = @import("std");
const Allocator = std.mem.Allocator;

pub const ListNode = struct {
    val: i32,
    next: ?*ListNode,
    random: ?*ListNode,

    pub fn init(val: i32) ListNode {
        return ListNode{ .val = val, .next = null, .random = null };
    }

    pub fn fromArray(allocator: Allocator, values: []const [2]i32) !?*ListNode {
        if (values.len == 0) return null;
        var nodes = std.ArrayList(*ListNode).init(allocator);
        defer nodes.deinit();

        for (values) |val_and_random| {
            const node = try allocator.create(ListNode);
            node.* = ListNode.init(val_and_random[0]);
            try nodes.append(node);
        }

        for (0..nodes.items.len) |i| {
            if (i < nodes.items.len - 1) {
                nodes.items[i].next = nodes.items[i + 1];
            }
            const random_idx = values[i][1];
            if (random_idx >= 0) {
                nodes.items[i].random = nodes.items[@intCast(random_idx)];
            }
        }

        return nodes.items[0];
    }

    pub fn toArray(self: ?*const ListNode, allocator: Allocator) ![][2]i32 {
        var result = std.ArrayList([2]i32).init(allocator);
        var node_to_index = std.AutoHashMap(*const ListNode, usize).init(allocator);
        defer node_to_index.deinit();

        var current = self;
        var idx: usize = 0;
        while (current) |node| {
            try node_to_index.put(node, idx);
            idx += 1;
            current = node.next;
        }

        current = self;
        while (current) |node| {
            const random_idx: i32 = if (node.random) |r| @intCast(node_to_index.get(r).?) else -1;
            try result.append([2]i32{ node.val, random_idx });
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

fn copyRandomList(head: ?*ListNode, allocator: Allocator) !?*ListNode {
    if (head == null) return null;

    var current = head;
    while (current != null) {
        const copy = try allocator.create(ListNode);
        copy.* = ListNode{ .val = current.?.val, .next = current.?.next, .random = null };
        current.?.next = copy;
        current = copy.next;
    }

    current = head;
    while (current != null) {
        const copy = current.?.next;
        if (current.?.random) |r| {
            copy.?.random = r.next;
        } else {
            copy.?.random = null;
        }
        current = current.?.next.?.next;
    }

    var dummy = ListNode{ .val = 0, .next = null, .random = null };
    var tail = &dummy;
    current = head;
    while (current != null) {
        const copy = current.?.next;
        current.?.next = copy.?.next;
        tail.next = copy;
        tail = tail.next.?;
        current = current.?.next;
    }

    return dummy.next;
}

pub fn main() !void {}

test "copy random list - complex case" {
    const allocator = std.testing.allocator;
    const values = [_][2]i32{
        [2]i32{ 7, -1 },
        [2]i32{ 13, 0 },
        [2]i32{ 11, 4 },
        [2]i32{ 10, 2 },
        [2]i32{ 1, 0 },
    };
    const head = try ListNode.fromArray(allocator, &values);
    defer ListNode.free(head, allocator);

    const copy = try copyRandomList(head, allocator);
    defer ListNode.free(copy, allocator);

    const result_array = try ListNode.toArray(copy, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices([2]i32, &values, result_array);
}

test "copy random list - simple case" {
    const allocator = std.testing.allocator;
    const values = [_][2]i32{
        [2]i32{ 1, 1 },
        [2]i32{ 2, 1 },
    };
    const head = try ListNode.fromArray(allocator, &values);
    defer ListNode.free(head, allocator);

    const copy = try copyRandomList(head, allocator);
    defer ListNode.free(copy, allocator);

    const result_array = try ListNode.toArray(copy, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices([2]i32, &values, result_array);
}

test "copy random list - empty list" {
    const allocator = std.testing.allocator;
    const values = [_][2]i32{};
    const head = try ListNode.fromArray(allocator, &values);
    defer ListNode.free(head, allocator);

    const copy = try copyRandomList(head, allocator);
    defer ListNode.free(copy, allocator);

    const result_array = try ListNode.toArray(copy, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices([2]i32, &values, result_array);
}

test "copy random list - single node" {
    const allocator = std.testing.allocator;
    const values = [_][2]i32{
        [2]i32{ 3, -1 },
    };
    const head = try ListNode.fromArray(allocator, &values);
    defer ListNode.free(head, allocator);

    const copy = try copyRandomList(head, allocator);
    defer ListNode.free(copy, allocator);

    const result_array = try ListNode.toArray(copy, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices([2]i32, &values, result_array);
}

test "copy random list - two nodes no random" {
    const allocator = std.testing.allocator;
    const values = [_][2]i32{
        [2]i32{ 1, -1 },
        [2]i32{ 2, -1 },
    };
    const head = try ListNode.fromArray(allocator, &values);
    defer ListNode.free(head, allocator);

    const copy = try copyRandomList(head, allocator);
    defer ListNode.free(copy, allocator);

    const result_array = try ListNode.toArray(copy, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices([2]i32, &values, result_array);
}
