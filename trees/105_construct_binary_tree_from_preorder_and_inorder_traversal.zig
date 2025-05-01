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

    pub fn toArray(self: ?*const TreeNode, allocator: Allocator) ![]?i32 {
        if (self == null) return &[_]?i32{};

        var result = std.ArrayList(?i32).init(allocator);
        defer result.deinit();

        var queue = std.ArrayList(?*const TreeNode).init(allocator);
        defer queue.deinit();

        try queue.append(self);
        while (queue.items.len > 0) {
            const node = queue.orderedRemove(0);
            if (node) |n| {
                try result.append(n.val);
                try queue.append(n.left);
                try queue.append(n.right);
            } else {
                try result.append(null);
            }
        }

        return try result.toOwnedSlice();
    }
};

fn buildTreeHelper(
    preorder: []const i32,
    preStart: usize,
    preEnd: usize,
    inorder: []const i32,
    inStart: usize,
    inEnd: usize,
    inorderMap: *const std.AutoHashMap(i32, usize),
    allocator: Allocator,
) !?*TreeNode {
    if (preStart > preEnd or inStart > inEnd) return null;

    const rootVal = preorder[preStart];
    var root = try allocator.create(TreeNode);
    root.* = TreeNode.init(rootVal);
    const rootInorderIdx = inorderMap.get(rootVal) orelse return error.ValueNotFound;
    const leftSubtreeSize = rootInorderIdx - inStart;

    if (leftSubtreeSize > 0) {
        root.left = try buildTreeHelper(
            preorder,
            preStart + 1,
            preStart + leftSubtreeSize,
            inorder,
            inStart,
            rootInorderIdx - 1,
            inorderMap,
            allocator,
        );
    } else {
        root.left = null;
    }

    const rightSubtreeSize = inEnd - rootInorderIdx;
    if (rightSubtreeSize > 0) {
        root.right = try buildTreeHelper(
            preorder,
            preStart + leftSubtreeSize + 1,
            preEnd,
            inorder,
            rootInorderIdx + 1,
            inEnd,
            inorderMap,
            allocator,
        );
    } else {
        root.right = null;
    }

    return root;
}

fn buildTree(preorder: []const i32, inorder: []const i32, allocator: Allocator) !?*TreeNode {
    if (preorder.len == 0) return null;

    var inorderMap = std.AutoHashMap(i32, usize).init(allocator);
    defer inorderMap.deinit();
    for (inorder, 0..) |val, idx| {
        try inorderMap.put(val, idx);
    }

    return try buildTreeHelper(preorder, 0, preorder.len - 1, inorder, 0, inorder.len - 1, &inorderMap, allocator);
}

pub fn main() !void {}

test "construct binary tree - example 1" {
    const allocator = std.testing.allocator;
    const preorder = [_]i32{ 3, 9, 20, 15, 7 };
    const inorder = [_]i32{ 9, 3, 15, 20, 7 };

    const root = try buildTree(&preorder, &inorder, allocator);
    defer TreeNode.free(root, allocator);

    const expected = try TreeNode.fromArray(allocator, &[_]?i32{ 3, 9, 20, null, null, 15, 7 });
    defer TreeNode.free(expected, allocator);

    const result_array = try TreeNode.toArray(root, allocator);
    defer allocator.free(result_array);
    const expected_array = try TreeNode.toArray(expected, allocator);
    defer allocator.free(expected_array);

    try std.testing.expectEqualSlices(?i32, expected_array, result_array);
}

test "construct binary tree - single node" {
    const allocator = std.testing.allocator;
    const preorder = [_]i32{-1};
    const inorder = [_]i32{-1};

    const root = try buildTree(&preorder, &inorder, allocator);
    defer TreeNode.free(root, allocator);

    const expected = try TreeNode.fromArray(allocator, &[_]?i32{-1});
    defer TreeNode.free(expected, allocator);

    const result_array = try TreeNode.toArray(root, allocator);
    defer allocator.free(result_array);
    const expected_array = try TreeNode.toArray(expected, allocator);
    defer allocator.free(expected_array);

    try std.testing.expectEqualSlices(?i32, expected_array, result_array);
}

test "construct binary tree - right skewed tree" {
    const allocator = std.testing.allocator;
    const preorder = [_]i32{ 1, 2, 3 };
    const inorder = [_]i32{ 1, 2, 3 };

    const root = try buildTree(&preorder, &inorder, allocator);
    defer TreeNode.free(root, allocator);

    const expected = try TreeNode.fromArray(allocator, &[_]?i32{ 1, null, 2, null, 3 });
    defer TreeNode.free(expected, allocator);

    const result_array = try TreeNode.toArray(root, allocator);
    defer allocator.free(result_array);
    const expected_array = try TreeNode.toArray(expected, allocator);
    defer allocator.free(expected_array);

    try std.testing.expectEqualSlices(?i32, expected_array, result_array);
}

test "construct binary tree - left skewed tree" {
    const allocator = std.testing.allocator;
    const preorder = [_]i32{ 3, 2, 1 };
    const inorder = [_]i32{ 1, 2, 3 };

    const root = try buildTree(&preorder, &inorder, allocator);
    defer TreeNode.free(root, allocator);

    const expected = try TreeNode.fromArray(allocator, &[_]?i32{ 3, 2, null, 1 });
    defer TreeNode.free(expected, allocator);

    const result_array = try TreeNode.toArray(root, allocator);
    defer allocator.free(result_array);
    const expected_array = try TreeNode.toArray(expected, allocator);
    defer allocator.free(expected_array);

    try std.testing.expectEqualSlices(?i32, expected_array, result_array);
}
