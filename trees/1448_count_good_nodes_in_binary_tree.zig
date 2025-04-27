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

fn countGoodNodes(node: ?*const TreeNode, maxSoFar: i32) i32 {
    if (node == null) return 0;

    const isGood: i32 = if (node.?.val >= maxSoFar) 1 else 0;
    const newMax = @max(maxSoFar, node.?.val);
    const leftGood = countGoodNodes(node.?.left, newMax);
    const rightGood = countGoodNodes(node.?.right, newMax);

    return isGood + leftGood + rightGood;
}

fn goodNodes(root: ?*const TreeNode) i32 {
    return countGoodNodes(root, std.math.minInt(i32));
}

pub fn main() !void {}

test "good nodes - multi-level tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 3, 1, 4, 3, null, 1, 5 });

    const result = goodNodes(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 4;
    try std.testing.expectEqual(expected, result);
}

test "good nodes - mixed values" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 3, 3, null, 4, 2 });

    const result = goodNodes(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 3;
    try std.testing.expectEqual(expected, result);
}

test "good nodes - single node" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{1});

    const result = goodNodes(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 1;
    try std.testing.expectEqual(expected, result);
}

test "good nodes - all nodes good" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, 3 });

    const result = goodNodes(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 3;
    try std.testing.expectEqual(expected, result);
}

test "good nodes - all nodes bad except root" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 5, 4, 3 });

    const result = goodNodes(root);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 1;
    try std.testing.expectEqual(expected, result);
}
