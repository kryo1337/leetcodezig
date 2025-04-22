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

fn height(node: ?*const TreeNode, maxDiameter: *i32) i32 {
    if (node == null) return 0;
    const leftHeight = height(node.?.left, maxDiameter);
    const rightHeight = height(node.?.right, maxDiameter);

    const currentDiameter = leftHeight + rightHeight;
    maxDiameter.* = @max(maxDiameter.*, currentDiameter);

    return 1 + @max(leftHeight, rightHeight);
}

fn diameterOfBinaryTree(root: ?*const TreeNode) i32 {
    var maxDiameter: i32 = 0;

    _ = height(root, &maxDiameter);

    return maxDiameter;
}

pub fn main() !void {}

test "diameter - example case" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, 3, 4, 5 });

    const result = diameterOfBinaryTree(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 3;
    try std.testing.expectEqual(expected, result);
}

test "diameter - simple case" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2 });

    const result = diameterOfBinaryTree(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 1;
    try std.testing.expectEqual(expected, result);
}

test "diameter - single node" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{1});

    const result = diameterOfBinaryTree(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 0;
    try std.testing.expectEqual(expected, result);
}

test "diameter - unbalanced tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, null, 3, 4, null, null, 5 });

    const result = diameterOfBinaryTree(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 3;
    try std.testing.expectEqual(expected, result);
}

test "diameter - deep tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, null, 3, null, 4, null, 5 });

    const result = diameterOfBinaryTree(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 4;
    try std.testing.expectEqual(expected, result);
}
