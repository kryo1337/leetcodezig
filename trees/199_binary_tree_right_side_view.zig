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

fn rightSideView(root: ?*const TreeNode, allocator: Allocator) ![]i32 {
    if (root == null) return &[_]i32{};

    var queue = std.ArrayList(*const TreeNode).init(allocator);
    defer queue.deinit();

    var result = std.ArrayList(i32).init(allocator);
    defer result.deinit();

    try queue.append(root.?);
    while (queue.items.len > 0) {
        const levelSize = queue.items.len;
        var rightMost: i32 = 0;

        for (0..levelSize) |i| {
            const node = queue.orderedRemove(0);

            if (i == levelSize - 1) {
                rightMost = node.val;
            }
            if (node.left != null) {
                try queue.append(node.left.?);
            }
            if (node.right != null) {
                try queue.append(node.right.?);
            }
        }
        try result.append(rightMost);
    }
    return try result.toOwnedSlice();
}

pub fn main() !void {}

test "right side view - multi-level tree with gaps" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, 3, null, 5, null, 4 });

    const result = try rightSideView(root, allocator);
    defer allocator.free(result);
    defer TreeNode.free(root, allocator);

    const expected = &[_]i32{ 1, 3, 4 };
    try std.testing.expectEqualSlices(i32, expected, result);
}

test "right side view - right skewed tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, null, 3 });

    const result = try rightSideView(root, allocator);
    defer allocator.free(result);
    defer TreeNode.free(root, allocator);

    const expected = &[_]i32{ 1, 3 };
    try std.testing.expectEqualSlices(i32, expected, result);
}

test "right side view - empty tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{});

    const result = try rightSideView(root, allocator);
    defer allocator.free(result);
    defer TreeNode.free(root, allocator);

    const expected = &[_]i32{};
    try std.testing.expectEqualSlices(i32, expected, result);
}

test "right side view - single node" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{1});

    const result = try rightSideView(root, allocator);
    defer allocator.free(result);
    defer TreeNode.free(root, allocator);

    const expected = &[_]i32{1};
    try std.testing.expectEqualSlices(i32, expected, result);
}

test "right side view - left skewed tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, null, 3 });

    const result = try rightSideView(root, allocator);
    defer allocator.free(result);
    defer TreeNode.free(root, allocator);

    const expected = &[_]i32{ 1, 2, 3 };
    try std.testing.expectEqualSlices(i32, expected, result);
}
