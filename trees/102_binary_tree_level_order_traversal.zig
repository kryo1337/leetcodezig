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

fn levelOrder(root: ?*const TreeNode, allocator: Allocator) ![][]i32 {
    if (root == null) return &[_][]i32{};

    var queue = std.ArrayList(*const TreeNode).init(allocator);
    defer queue.deinit();

    var result = std.ArrayList([]i32).init(allocator);
    defer {
        for (result.items) |level| {
            allocator.free(level);
        }
        result.deinit();
    }
    try queue.append(root.?);

    while (queue.items.len > 0) {
        const levelSize = queue.items.len;
        var currentLevel = std.ArrayList(i32).init(allocator);
        defer currentLevel.deinit();

        for (0..levelSize) |_| {
            const node = queue.orderedRemove(0);
            try currentLevel.append(node.val);

            if (node.left != null) {
                try queue.append(node.left.?);
            }
            if (node.right != null) {
                try queue.append(node.right.?);
            }
        }
        const levelSlice = try currentLevel.toOwnedSlice();
        try result.append(levelSlice);
    }
    return try result.toOwnedSlice();
}

pub fn main() !void {}

fn freeLevelOrderResult(result: [][]i32, allocator: Allocator) void {
    for (result) |level| {
        allocator.free(level);
    }
    allocator.free(result);
}

test "level order - multi-level tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 3, 9, 20, null, null, 15, 7 });

    const result = try levelOrder(root, allocator);
    defer freeLevelOrderResult(result, allocator);
    defer TreeNode.free(root, allocator);

    var expected_list = std.ArrayList([]i32).init(allocator);
    defer expected_list.deinit();

    var level0 = std.ArrayList(i32).init(allocator);
    try level0.append(3);
    try expected_list.append(try level0.toOwnedSlice());
    level0.deinit();

    var level1 = std.ArrayList(i32).init(allocator);
    try level1.append(9);
    try level1.append(20);
    try expected_list.append(try level1.toOwnedSlice());
    level1.deinit();

    var level2 = std.ArrayList(i32).init(allocator);
    try level2.append(15);
    try level2.append(7);
    try expected_list.append(try level2.toOwnedSlice());
    level2.deinit();

    const expected = try expected_list.toOwnedSlice();
    defer freeLevelOrderResult(expected, allocator);

    try std.testing.expectEqual(expected.len, result.len);
    for (expected, result) |exp_level, res_level| {
        try std.testing.expectEqualSlices(i32, exp_level, res_level);
    }
}

test "level order - single node" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{1});

    const result = try levelOrder(root, allocator);
    defer freeLevelOrderResult(result, allocator);
    defer TreeNode.free(root, allocator);

    var expected_list = std.ArrayList([]i32).init(allocator);
    defer expected_list.deinit();

    var level0 = std.ArrayList(i32).init(allocator);
    try level0.append(1);
    try expected_list.append(try level0.toOwnedSlice());
    level0.deinit();

    const expected = try expected_list.toOwnedSlice();
    defer freeLevelOrderResult(expected, allocator);

    try std.testing.expectEqual(expected.len, result.len);
    for (expected, result) |exp_level, res_level| {
        try std.testing.expectEqualSlices(i32, exp_level, res_level);
    }
}

test "level order - empty tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{});

    const result = try levelOrder(root, allocator);
    defer freeLevelOrderResult(result, allocator);
    defer TreeNode.free(root, allocator);

    const expected = &[_][]i32{};
    try std.testing.expectEqual(expected.len, result.len);
}

test "level order - skewed tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, null, 3, null, 4 });

    const result = try levelOrder(root, allocator);
    defer freeLevelOrderResult(result, allocator);
    defer TreeNode.free(root, allocator);

    var expected_list = std.ArrayList([]i32).init(allocator);
    defer expected_list.deinit();

    var level0 = std.ArrayList(i32).init(allocator);
    try level0.append(1);
    try expected_list.append(try level0.toOwnedSlice());
    level0.deinit();

    var level1 = std.ArrayList(i32).init(allocator);
    try level1.append(2);
    try expected_list.append(try level1.toOwnedSlice());
    level1.deinit();

    var level2 = std.ArrayList(i32).init(allocator);
    try level2.append(3);
    try expected_list.append(try level2.toOwnedSlice());
    level2.deinit();

    var level3 = std.ArrayList(i32).init(allocator);
    try level3.append(4);
    try expected_list.append(try level3.toOwnedSlice());
    level3.deinit();

    const expected = try expected_list.toOwnedSlice();
    defer freeLevelOrderResult(expected, allocator);

    try std.testing.expectEqual(expected.len, result.len);
    for (expected, result) |exp_level, res_level| {
        try std.testing.expectEqualSlices(i32, exp_level, res_level);
    }
}
