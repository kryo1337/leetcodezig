const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Node = struct {
    val: i32,
    neighbors: std.ArrayList(*Node),
    allocator: Allocator,

    pub fn init(allocator: Allocator, val: i32) *Node {
        const node = allocator.create(Node) catch unreachable;
        node.* = .{
            .val = val,
            .neighbors = .{},
            .allocator = allocator,
        };
        return node;
    }

    pub fn deinit(self: *Node) void {
        self.neighbors.deinit(self.allocator);
        self.allocator.destroy(self);
    }
};

pub fn cloneGraph(allocator: Allocator, node: ?*Node) ?*Node {
    if (node == null) return null;

    var cloned = std.AutoHashMap(i32, *Node).init(allocator);
    defer cloned.deinit();

    return dfsClone(allocator, node.?, &cloned);
}

fn dfsClone(allocator: Allocator, node: *Node, cloned: *std.AutoHashMap(i32, *Node)) *Node {
    if (cloned.get(node.val)) |existing| {
        return existing;
    }

    const new_node = Node.init(allocator, node.val);
    cloned.put(node.val, new_node) catch unreachable;

    for (node.neighbors.items) |neighbor| {
        const cloned_neighbor = dfsClone(allocator, neighbor, cloned);
        new_node.neighbors.append(new_node.allocator, cloned_neighbor) catch unreachable;
    }

    return new_node;
}

fn buildGraph(allocator: Allocator, adjList: []const []const i32) ?*Node {
    if (adjList.len == 0) return null;

    var nodes = std.AutoHashMap(i32, *Node).init(allocator);
    defer nodes.deinit();

    for (adjList, 1..) |_, val| {
        const node = Node.init(allocator, @intCast(val));
        nodes.put(@intCast(val), node) catch unreachable;
    }

    for (adjList, 1..) |neighbors, val| {
        const node = nodes.get(@intCast(val)).?;
        for (neighbors) |neighbor_val| {
            const neighbor = nodes.get(neighbor_val).?;
            node.neighbors.append(node.allocator, neighbor) catch unreachable;
        }
    }

    return nodes.get(1).?;
}

fn graphToAdjList(allocator: Allocator, node: ?*Node, num_nodes: usize) [][]i32 {
    if (node == null) return &[0][]i32{};

    var visited = std.AutoHashMap(i32, *Node).init(allocator);
    defer visited.deinit();

    var queue = std.ArrayList(*Node).initCapacity(allocator, num_nodes) catch unreachable;
    defer queue.deinit(allocator);

    queue.append(allocator, node.?) catch unreachable;
    visited.put(node.?.val, node.?) catch unreachable;

    var head: usize = 0;
    while (head < queue.items.len) {
        const current = queue.items[head];
        head += 1;
        for (current.neighbors.items) |neighbor| {
            if (!visited.contains(neighbor.val)) {
                visited.put(neighbor.val, neighbor) catch unreachable;
                queue.append(allocator, neighbor) catch unreachable;
            }
        }
    }

    var adjList = std.ArrayList([]i32).initCapacity(allocator, num_nodes) catch unreachable;
    defer adjList.deinit(allocator);

    for (1..num_nodes + 1) |val| {
        const n = visited.get(@intCast(val)) orelse unreachable;
        var neighbors = std.ArrayList(i32).initCapacity(allocator, n.neighbors.items.len) catch unreachable;
        for (n.neighbors.items) |neighbor| {
            neighbors.append(allocator, neighbor.val) catch unreachable;
        }
        std.mem.sort(i32, neighbors.items, {}, comptime std.sort.asc(i32));
        adjList.append(allocator, neighbors.items) catch unreachable;
    }

    return adjList.toOwnedSlice(allocator) catch unreachable;
}

fn freeGraph(allocator: Allocator, node: ?*Node) void {
    if (node == null) return;

    var visited = std.AutoHashMap(i32, void).init(allocator);
    defer visited.deinit();

    var stack = std.ArrayList(*Node).initCapacity(allocator, 16) catch unreachable;
    defer stack.deinit(allocator);

    stack.append(allocator, node.?) catch unreachable;

    while (stack.items.len > 0) {
        const current = stack.pop().?;
        if (visited.contains(current.val)) continue;
        visited.put(current.val, {}) catch unreachable;

        for (current.neighbors.items) |neighbor| {
            if (!visited.contains(neighbor.val)) {
                stack.append(allocator, neighbor) catch unreachable;
            }
        }
        current.deinit();
    }
}

test "example 1 - simple cycle graph" {
    const allocator = std.testing.allocator;
    const adjList = [_][]const i32{
        &[_]i32{ 2, 4 },
        &[_]i32{ 1, 3 },
        &[_]i32{ 2, 4 },
        &[_]i32{ 1, 3 },
    };

    const original = buildGraph(allocator, &adjList).?;
    defer freeGraph(allocator, original);

    const cloned = cloneGraph(allocator, original).?;
    defer freeGraph(allocator, cloned);

    try std.testing.expect(&cloned.val != &original.val);
    try std.testing.expect(cloned != original);

    const clonedAdj = graphToAdjList(allocator, cloned, 4);
    defer {
        for (clonedAdj) |list| allocator.free(list);
        allocator.free(clonedAdj);
    }

    try std.testing.expectEqual(@as(usize, 4), clonedAdj.len);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4 }, clonedAdj[0]);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 3 }, clonedAdj[1]);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4 }, clonedAdj[2]);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 3 }, clonedAdj[3]);
}

test "example 2 - single node no neighbors" {
    const allocator = std.testing.allocator;
    const adjList = [_][]const i32{
        &[_]i32{},
    };

    const original = buildGraph(allocator, &adjList).?;
    defer freeGraph(allocator, original);

    const cloned = cloneGraph(allocator, original).?;
    defer freeGraph(allocator, cloned);

    try std.testing.expect(cloned != original);
    try std.testing.expectEqual(@as(i32, 1), cloned.val);
    try std.testing.expectEqual(@as(usize, 0), cloned.neighbors.items.len);
}

test "example 3 - empty graph" {
    const allocator = std.testing.allocator;
    const adjList = [_][]const i32{};

    const original = buildGraph(allocator, &adjList);
    const cloned = cloneGraph(allocator, original);

    try std.testing.expect(cloned == null);
}

test "linear graph - 3 nodes in line" {
    const allocator = std.testing.allocator;
    const adjList = [_][]const i32{
        &[_]i32{2},
        &[_]i32{ 1, 3 },
        &[_]i32{2},
    };

    const original = buildGraph(allocator, &adjList).?;
    defer freeGraph(allocator, original);

    const cloned = cloneGraph(allocator, original).?;
    defer freeGraph(allocator, cloned);

    try std.testing.expectEqual(@as(i32, 1), cloned.val);
    try std.testing.expectEqual(@as(usize, 1), cloned.neighbors.items.len);

    const node2 = cloned.neighbors.items[0];
    try std.testing.expectEqual(@as(i32, 2), node2.val);
    try std.testing.expectEqual(@as(usize, 2), node2.neighbors.items.len);

    try std.testing.expect(node2 != original.neighbors.items[0]);
}

test "complete graph - 4 nodes all connected" {
    const allocator = std.testing.allocator;
    const adjList = [_][]const i32{
        &[_]i32{ 2, 3, 4 },
        &[_]i32{ 1, 3, 4 },
        &[_]i32{ 1, 2, 4 },
        &[_]i32{ 1, 2, 3 },
    };

    const original = buildGraph(allocator, &adjList).?;
    defer freeGraph(allocator, original);

    const cloned = cloneGraph(allocator, original).?;
    defer freeGraph(allocator, cloned);

    const clonedAdj = graphToAdjList(allocator, cloned, 4);
    defer {
        for (clonedAdj) |list| allocator.free(list);
        allocator.free(clonedAdj);
    }

    try std.testing.expectEqual(@as(usize, 4), clonedAdj.len);
    for (clonedAdj) |neighbors| {
        try std.testing.expectEqual(@as(usize, 3), neighbors.len);
    }
}

test "cloned nodes are independent - modify clone" {
    const allocator = std.testing.allocator;
    const adjList = [_][]const i32{
        &[_]i32{2},
        &[_]i32{1},
    };

    const original = buildGraph(allocator, &adjList).?;
    defer freeGraph(allocator, original);

    const cloned = cloneGraph(allocator, original).?;
    defer freeGraph(allocator, cloned);

    cloned.val = 100;

    try std.testing.expectEqual(@as(i32, 1), original.val);
    try std.testing.expectEqual(@as(i32, 100), cloned.val);
}

test "verify neighbor references in clone are correct" {
    const allocator = std.testing.allocator;
    const adjList = [_][]const i32{
        &[_]i32{ 2, 3 },
        &[_]i32{ 1, 3 },
        &[_]i32{ 1, 2 },
    };

    const original = buildGraph(allocator, &adjList).?;
    defer freeGraph(allocator, original);

    const cloned = cloneGraph(allocator, original).?;
    defer freeGraph(allocator, cloned);

    const cloned_node1 = cloned;
    const cloned_node2 = cloned_node1.neighbors.items[0];
    const cloned_node3 = cloned_node1.neighbors.items[1];

    try std.testing.expect(cloned_node2.neighbors.items[0] == cloned_node1);
    try std.testing.expect(cloned_node3.neighbors.items[0] == cloned_node1);
}
