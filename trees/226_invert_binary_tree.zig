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

    pub fn toArray(root: ?*const TreeNode, allocator: Allocator) ![]?i32 {
        var result = std.ArrayList(?i32).init(allocator);
        if (root == null) return result.toOwnedSlice();

        var queue = std.ArrayList(?*const TreeNode).init(allocator);
        defer queue.deinit();
        try queue.append(root);

        while (queue.items.len > 0) {
            const node = queue.orderedRemove(0);
            if (node == null) {
                try result.append(null);
                continue;
            }
            try result.append(node.?.val);
            try queue.append(node.?.left);
            try queue.append(node.?.right);
        }

        while (result.items.len > 0 and result.items[result.items.len - 1] == null) {
            _ = result.pop();
        }
        return result.toOwnedSlice();
    }

    pub fn free(self: ?*TreeNode, allocator: Allocator) void {
        if (self == null) return;
        free(self.?.left, allocator);
        free(self.?.right, allocator);
        allocator.destroy(self.?);
    }
};

fn invertTree(root: ?*TreeNode) ?*TreeNode {
    if (root == null) return null;

    const temp = root.?.left;
    root.?.left = root.?.right;
    root.?.right = temp;

    _ = invertTree(root.?.left);
    _ = invertTree(root.?.right);

    return root;
}

pub fn main() !void {}

test "invert tree - example case" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 4, 2, 7, 1, 3, 6, 9 });

    const result = invertTree(root);
    defer TreeNode.free(result, allocator);

    const expected = &[_]?i32{ 4, 7, 2, 9, 6, 3, 1 };
    const result_array = try TreeNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(?i32, expected, result_array);
}

test "invert tree - simple case" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 2, 1, 3 });

    const result = invertTree(root);
    defer TreeNode.free(result, allocator);

    const expected = &[_]?i32{ 2, 3, 1 };
    const result_array = try TreeNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(?i32, expected, result_array);
}

test "invert tree - empty tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{});

    const result = invertTree(root);
    defer TreeNode.free(result, allocator);

    const expected = &[_]?i32{};
    const result_array = try TreeNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(?i32, expected, result_array);
}

test "invert tree - single node" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{1});

    const result = invertTree(root);
    defer TreeNode.free(result, allocator);

    const expected = &[_]?i32{1};
    const result_array = try TreeNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(?i32, expected, result_array);
}

test "invert tree - unbalanced tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, null, 3, 4 });

    const result = invertTree(root);
    defer TreeNode.free(result, allocator);

    const expected = &[_]?i32{ 1, null, 2, 4, 3 };
    const result_array = try TreeNode.toArray(result, allocator);
    defer allocator.free(result_array);

    try std.testing.expectEqualSlices(?i32, expected, result_array);
}
