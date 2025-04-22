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

fn isSameTree(p: ?*const TreeNode, q: ?*const TreeNode) bool {
    if (p == null and q == null) return true;
    if ((p == null) != (q == null)) return false;

    return p.?.val == q.?.val and
        isSameTree(p.?.left, q.?.left) and
        isSameTree(p.?.right, q.?.right);
}

pub fn main() !void {}

test "same tree - identical trees" {
    const allocator = std.testing.allocator;
    const p = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, 3 });
    const q = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, 3 });

    const result = isSameTree(p, q);
    defer TreeNode.free(p, allocator);
    defer TreeNode.free(q, allocator);

    const expected = true;
    try std.testing.expectEqual(expected, result);
}

test "same tree - different structure" {
    const allocator = std.testing.allocator;
    const p = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2 });
    const q = try TreeNode.fromArray(allocator, &[_]?i32{ 1, null, 2 });

    const result = isSameTree(p, q);
    defer TreeNode.free(p, allocator);
    defer TreeNode.free(q, allocator);

    const expected = false;
    try std.testing.expectEqual(expected, result);
}

test "same tree - different values" {
    const allocator = std.testing.allocator;
    const p = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, 1 });
    const q = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 1, 2 });

    const result = isSameTree(p, q);
    defer TreeNode.free(p, allocator);
    defer TreeNode.free(q, allocator);

    const expected = false;
    try std.testing.expectEqual(expected, result);
}

test "same tree - empty trees" {
    const allocator = std.testing.allocator;
    const p = try TreeNode.fromArray(allocator, &[_]?i32{});
    const q = try TreeNode.fromArray(allocator, &[_]?i32{});

    const result = isSameTree(p, q);
    defer TreeNode.free(p, allocator);
    defer TreeNode.free(q, allocator);

    const expected = true;
    try std.testing.expectEqual(expected, result);
}

test "same tree - one empty tree" {
    const allocator = std.testing.allocator;
    const p = try TreeNode.fromArray(allocator, &[_]?i32{1});
    const q = try TreeNode.fromArray(allocator, &[_]?i32{});

    const result = isSameTree(p, q);
    defer TreeNode.free(p, allocator);
    defer TreeNode.free(q, allocator);

    const expected = false;
    try std.testing.expectEqual(expected, result);
}
