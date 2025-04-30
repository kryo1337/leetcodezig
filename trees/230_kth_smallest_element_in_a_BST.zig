const std = @import("std");
const Allocator = std.mem.Allocator;

pub const TreeNode = struct {
    val: i32,
    left: ?*TreeNode,
    right: ?*TreeNode,

    pub fn init(val: i32) TreeNode {
        return TreeNode{ .val = val, .left = null, .right = null };
    }

    pub fn fromArray(allocator: Allocator, values: []const ?i32) !?*TreeNode {
        if (values.len == 0 or values[0] == null) return null;

        const root = try allocator.create(TreeNode);
        root.* = TreeNode.init(values[0].?);
        var queue = std.ArrayList(*TreeNode).init(allocator);
        defer queue.deinit();
        try queue.append(root);

        var i: usize = 1;
        while (queue.items.len > 0 and i < values.len) {
            const node = queue.orderedRemove(0);
            if (i < values.len and values[i] != null) {
                node.left = try allocator.create(TreeNode);
                node.left.?.* = TreeNode.init(values[i].?);
                try queue.append(node.left.?);
            }
            i += 1;
            if (i < values.len and values[i] != null) {
                node.right = try allocator.create(TreeNode);
                node.right.?.* = TreeNode.init(values[i].?);
                try queue.append(node.right.?);
            }
            i += 1;
        }
        return root;
    }

    pub fn free(self: ?*TreeNode, allocator: Allocator) void {
        if (self == null) return;
        free(self.?.left, allocator);
        free(self.?.right, allocator);
        allocator.destroy(self.?);
    }
};

fn kthSmallest(allocator: Allocator, root: ?*const TreeNode, k: i32) !i32 {
    if (root == null) return 0;

    var stack = std.ArrayList(*const TreeNode).init(allocator);
    defer stack.deinit();

    var curr: ?*const TreeNode = root;
    var remain: i32 = k;

    while (true) {
        while (curr != null) {
            try stack.append(curr.?);
            curr = curr.?.left;
        }
        if (stack.items.len == 0) unreachable;

        const node = stack.pop();
        remain -= 1;
        if (remain == 0) return node.val;
        curr = node.right;
    }
    unreachable;
}

pub fn main() !void {}

test "kth smallest - example 1" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 3, 1, 4, null, 2 });

    const result = kthSmallest(allocator, root, 1);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 1;
    try std.testing.expectEqual(expected, result);
}

test "kth smallest - example 2" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 5, 3, 6, 2, 4, null, null, 1 });

    const result = kthSmallest(allocator, root, 3);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 3;
    try std.testing.expectEqual(expected, result);
}

test "kth smallest - single node" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{1});

    const result = kthSmallest(allocator, root, 1);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 1;
    try std.testing.expectEqual(expected, result);
}

test "kth smallest - right skewed tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, null, 2, null, 3 });

    const result = kthSmallest(allocator, root, 3);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 3;
    try std.testing.expectEqual(expected, result);
}

test "kth smallest - left skewed tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 3, 2, null, 1 });

    const result = kthSmallest(allocator, root, 1);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 1;
    try std.testing.expectEqual(expected, result);
}
