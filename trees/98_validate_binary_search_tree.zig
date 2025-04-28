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

fn validate(node: ?*const TreeNode, min: i64, max: i64) bool {
    if (node == null) return true;

    const val: i64 = node.?.val;
    if (val <= min or val >= max) return false;
    const leftValid = validate(node.?.left, min, val);
    const rightValid = validate(node.?.right, val, max);

    return leftValid and rightValid;
}

fn isValidBST(root: ?*const TreeNode) bool {
    return validate(root, std.math.minInt(i64), std.math.maxInt(i64));
}

pub fn main() !void {}

test "valid BST - simple tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 2, 1, 3 });

    const result = isValidBST(root);
    defer TreeNode.free(root, allocator);

    const expected = true;
    try std.testing.expectEqual(expected, result);
}

test "invalid BST - wrong ordering" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 5, 1, 4, null, null, 3, 6 });

    const result = isValidBST(root);
    defer TreeNode.free(root, allocator);

    const expected = false;
    try std.testing.expectEqual(expected, result);
}

test "valid BST - single node" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{1});

    const result = isValidBST(root);
    defer TreeNode.free(root, allocator);

    const expected = true;
    try std.testing.expectEqual(expected, result);
}

test "invalid BST - duplicate values" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 2, 2, 2 });

    const result = isValidBST(root);
    defer TreeNode.free(root, allocator);

    const expected = false;
    try std.testing.expectEqual(expected, result);
}

test "valid BST - skewed tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 3, 2, null, 1 });

    const result = isValidBST(root);
    defer TreeNode.free(root, allocator);

    const expected = true;
    try std.testing.expectEqual(expected, result);
}
