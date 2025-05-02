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

fn maxPathSumHelper(node: ?*const TreeNode, maxSum: *i32) i32 {
    if (node == null) return 0;

    const left = @max(0, maxPathSumHelper(node.?.left, maxSum));
    const right = @max(0, maxPathSumHelper(node.?.right, maxSum));

    const sum = node.?.val + left + right;
    maxSum.* = @max(maxSum.*, sum);

    return node.?.val + @max(left, right);
}

fn maxPathSum(root: ?*const TreeNode) i32 {
    if (root == null) return 0;

    var maxSum: i32 = std.math.minInt(i32);
    _ = maxPathSumHelper(root, &maxSum);

    return maxSum;
}

pub fn main() !void {}

test "max path sum - example 1" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, 3 });

    const result = maxPathSum(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 6;
    try std.testing.expectEqual(expected, result);
}

test "max path sum - example 2" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ -10, 9, 20, null, null, 15, 7 });

    const result = maxPathSum(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 42;
    try std.testing.expectEqual(expected, result);
}

test "max path sum - single node" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{1});

    const result = maxPathSum(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 1;
    try std.testing.expectEqual(expected, result);
}

test "max path sum - negative values" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ -1, -2, -3 });

    const result = maxPathSum(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = -1;
    try std.testing.expectEqual(expected, result);
}

test "max path sum - left skewed tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, null, 3 });

    const result = maxPathSum(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 6;
    try std.testing.expectEqual(expected, result);
}
