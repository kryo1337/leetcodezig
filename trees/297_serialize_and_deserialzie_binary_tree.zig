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

pub const Codec = struct {
    allocator: Allocator,

    pub fn init(allocator: Allocator) Codec {
        return Codec{ .allocator = allocator };
    }

    pub fn serialize(self: *Codec, root: ?*const TreeNode) ![]u8 {
        if (root == null) return try self.allocator.dupe(u8, "null");

        var queue = std.ArrayList(?*const TreeNode).init(self.allocator);
        defer queue.deinit();
        try queue.append(root);

        var result = std.ArrayList(u8).init(self.allocator);
        defer result.deinit();

        while (queue.items.len > 0) {
            const node = queue.orderedRemove(0);
            if (result.items.len > 0) {
                try result.appendSlice(",");
            }
            if (node) |n| {
                const val = try std.fmt.allocPrint(self.allocator, "{}", .{n.val});
                defer self.allocator.free(val);
                try result.appendSlice(val);
                try queue.append(n.left);
                try queue.append(n.right);
            } else {
                try result.appendSlice("null");
            }
        }
        return try result.toOwnedSlice();
    }

    pub fn deserialize(self: *Codec, data: []const u8) !?*TreeNode {
        if (std.mem.eql(u8, data, "null")) return null;

        var tokens = std.mem.split(u8, data, ",");
        const first = tokens.next() orelse return error.InvalidInput;
        if (std.mem.eql(u8, first, "null")) return null;

        const val = try std.fmt.parseInt(i32, first, 10);
        const root = try self.allocator.create(TreeNode);
        root.* = TreeNode.init(val);

        var queue = std.ArrayList(*TreeNode).init(self.allocator);
        defer queue.deinit();
        try queue.append(root);

        while (queue.items.len > 0) {
            const node = queue.orderedRemove(0);
            if (tokens.next()) |left| {
                if (!std.mem.eql(u8, left, "null")) {
                    const left_val = try std.fmt.parseInt(i32, left, 10);
                    node.left = try self.allocator.create(TreeNode);
                    node.left.?.* = TreeNode.init(left_val);
                    try queue.append(node.left.?);
                }
            }
            if (tokens.next()) |right| {
                if (!std.mem.eql(u8, right, "null")) {
                    const right_val = try std.fmt.parseInt(i32, right, 10);
                    node.right = try self.allocator.create(TreeNode);
                    node.right.?.* = TreeNode.init(right_val);
                    try queue.append(node.right.?);
                }
            }
        }
        return root;
    }
};

pub fn main() !void {}

test "serialize and deserialize - example 1" {
    const allocator = std.testing.allocator;
    const original = try TreeNode.fromArray(allocator, &[_]?i32{ 1, 2, 3, null, null, 4, 5 });
    defer TreeNode.free(original, allocator);

    var codec = Codec.init(allocator);
    const serialized = try codec.serialize(original);
    defer allocator.free(serialized);

    const deserialized = try codec.deserialize(serialized);
    defer TreeNode.free(deserialized, allocator);

    const original_array = try TreeNode.toArray(original, allocator);
    defer allocator.free(original_array);
    const deserialized_array = try TreeNode.toArray(deserialized, allocator);
    defer allocator.free(deserialized_array);

    try std.testing.expectEqualSlices(?i32, original_array, deserialized_array);
}

test "serialize and deserialize - empty tree" {
    const allocator = std.testing.allocator;
    const original = try TreeNode.fromArray(allocator, &[_]?i32{});
    defer TreeNode.free(original, allocator);

    var codec = Codec.init(allocator);
    const serialized = try codec.serialize(original);
    defer allocator.free(serialized);

    const deserialized = try codec.deserialize(serialized);
    defer TreeNode.free(deserialized, allocator);

    const original_array = try TreeNode.toArray(original, allocator);
    defer allocator.free(original_array);
    const deserialized_array = try TreeNode.toArray(deserialized, allocator);
    defer allocator.free(deserialized_array);

    try std.testing.expectEqualSlices(?i32, original_array, deserialized_array);
}

test "serialize and deserialize - single node" {
    const allocator = std.testing.allocator;
    const original = try TreeNode.fromArray(allocator, &[_]?i32{1});
    defer TreeNode.free(original, allocator);

    var codec = Codec.init(allocator);
    const serialized = try codec.serialize(original);
    defer allocator.free(serialized);

    const deserialized = try codec.deserialize(serialized);
    defer TreeNode.free(deserialized, allocator);

    const original_array = try TreeNode.toArray(original, allocator);
    defer allocator.free(original_array);
    const deserialized_array = try TreeNode.toArray(deserialized, allocator);
    defer allocator.free(deserialized_array);

    try std.testing.expectEqualSlices(?i32, original_array, deserialized_array);
}

test "serialize and deserialize - right skewed tree" {
    const allocator = std.testing.allocator;
    const original = try TreeNode.fromArray(allocator, &[_]?i32{ 1, null, 2, null, 3 });
    defer TreeNode.free(original, allocator);

    var codec = Codec.init(allocator);
    const serialized = try codec.serialize(original);
    defer allocator.free(serialized);

    const deserialized = try codec.deserialize(serialized);
    defer TreeNode.free(deserialized, allocator);

    const original_array = try TreeNode.toArray(original, allocator);
    defer allocator.free(original_array);
    const deserialized_array = try TreeNode.toArray(deserialized, allocator);
    defer allocator.free(deserialized_array);

    try std.testing.expectEqualSlices(?i32, original_array, deserialized_array);
}
