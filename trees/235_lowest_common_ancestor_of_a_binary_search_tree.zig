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

    pub fn findNode(self: ?*const TreeNode, val: i32) ?*const TreeNode {
        if (self == null) return null;
        if (self.?.val == val) return self;

        if (val < self.?.val) {
            return findNode(self.?.left, val);
        } else {
            return findNode(self.?.right, val);
        }
    }
};

fn lowestCommonAncestor(root: ?*const TreeNode, p: ?*const TreeNode, q: ?*const TreeNode) ?*const TreeNode {
    if (root == null) return null;

    if (p.?.val < root.?.val and q.?.val < root.?.val) {
        return lowestCommonAncestor(root.?.left, p, q);
    } else if (p.?.val > root.?.val and q.?.val > root.?.val) {
        return lowestCommonAncestor(root.?.right, p, q);
    } else {
        return root;
    }
}

pub fn main() !void {}

test "LCA - nodes on different sides" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 6, 2, 8, 0, 4, 7, 9, null, null, 3, 5 });
    const p = TreeNode.findNode(root, 2).?;
    const q = TreeNode.findNode(root, 8).?;

    const result = lowestCommonAncestor(root, p, q);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 6;
    try std.testing.expectEqual(expected, result.?.val);
}

test "LCA - nodes on same side" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 6, 2, 8, 0, 4, 7, 9, null, null, 3, 5 });
    const p = TreeNode.findNode(root, 2).?;
    const q = TreeNode.findNode(root, 4).?;

    const result = lowestCommonAncestor(root, p, q);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 2;
    try std.testing.expectEqual(expected, result.?.val);
}

test "LCA - one node is root" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 6, 2, 8, 0, 4, 7, 9 });
    const p = TreeNode.findNode(root, 6).?;
    const q = TreeNode.findNode(root, 2).?;

    const result = lowestCommonAncestor(root, p, q);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 6;
    try std.testing.expectEqual(expected, result.?.val);
}

test "LCA - small tree" {
    const allocator = std.testing.allocator;
    const root = try TreeNode.fromArray(allocator, &[_]?i32{ 2, 1 });
    const p = TreeNode.findNode(root, 2).?;
    const q = TreeNode.findNode(root, 1).?;

    const result = lowestCommonAncestor(root, p, q);
    defer TreeNode.free(root, allocator);

    const expected: i32 = 2;
    try std.testing.expectEqual(expected, result.?.val);
}
