const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Node = struct {
    key: i32,
    value: i32,
    prev: ?*Node,
    next: ?*Node,

    pub fn init(key: i32, value: i32) Node {
        return Node{ .key = key, .value = value, .prev = null, .next = null };
    }
};

pub const LRUCache = struct {
    capacity: i32,
    size: i32,
    map: std.AutoHashMap(i32, *Node),
    head: *Node,
    tail: *Node,
    allocator: Allocator,

    pub fn init(capacity: i32, allocator: Allocator) !LRUCache {
        var cache = LRUCache{
            .capacity = capacity,
            .size = 0,
            .map = std.AutoHashMap(i32, *Node).init(allocator),
            .head = undefined,
            .tail = undefined,
            .allocator = allocator,
        };
        cache.head = try allocator.create(Node);
        cache.tail = try allocator.create(Node);
        cache.head.* = Node{ .key = 0, .value = 0, .prev = null, .next = cache.tail };
        cache.tail.* = Node{ .key = 0, .value = 0, .prev = cache.head, .next = null };

        return cache;
    }

    pub fn deinit(self: *LRUCache) void {
        var current: ?*Node = self.head;
        while (current != null) {
            const node = current.?;
            current = node.next;
            self.allocator.destroy(node);
        }
        self.map.deinit();
    }

    fn moveToFront(self: *LRUCache, node: *Node) void {
        node.prev.?.next = node.next;
        node.next.?.prev = node.prev;
        node.next = self.head.next;
        node.prev = self.head;
        self.head.next.?.prev = node;
        self.head.next = node;
    }

    fn removeLRU(self: *LRUCache) void {
        if (self.size == 0) return;
        const lru = self.tail.prev.?;
        lru.prev.?.next = self.tail;
        self.tail.prev = lru.prev;
        _ = self.map.remove(lru.key);
        self.allocator.destroy(lru);
        self.size -= 1;
    }

    pub fn get(self: *LRUCache, key: i32) i32 {
        if (self.map.get(key)) |node| {
            self.moveToFront(node);
            return node.value;
        }
        return -1;
    }

    pub fn put(self: *LRUCache, key: i32, value: i32) void {
        if (self.map.contains(key)) {
            const node = self.map.get(key).?;
            node.value = value;
            self.moveToFront(node);
        } else {
            if (self.size == self.capacity) {
                self.removeLRU();
            }
            const new_node = self.allocator.create(Node) catch unreachable;
            new_node.* = Node{ .key = key, .value = value, .prev = null, .next = null };
            self.map.put(key, new_node) catch unreachable;
            new_node.next = self.head.next;
            new_node.prev = self.head;
            self.head.next.?.prev = new_node;
            self.head.next = new_node;
            self.size += 1;
        }
    }
};

pub fn main() !void {}

test "lru cache - example case" {
    const allocator = std.testing.allocator;
    var cache = try LRUCache.init(2, allocator);
    defer cache.deinit();

    cache.put(1, 1);
    cache.put(2, 2);
    try std.testing.expectEqual(@as(i32, 1), cache.get(1));
    cache.put(3, 3);
    try std.testing.expectEqual(@as(i32, -1), cache.get(2));
    cache.put(4, 4);
    try std.testing.expectEqual(@as(i32, -1), cache.get(1));
    try std.testing.expectEqual(@as(i32, 3), cache.get(3));
    try std.testing.expectEqual(@as(i32, 4), cache.get(4));
}

test "lru cache - single capacity" {
    const allocator = std.testing.allocator;
    var cache = try LRUCache.init(1, allocator);
    defer cache.deinit();

    cache.put(1, 1);
    cache.put(2, 2);
    try std.testing.expectEqual(@as(i32, -1), cache.get(1));
    try std.testing.expectEqual(@as(i32, 2), cache.get(2));
}

test "lru cache - update existing key" {
    const allocator = std.testing.allocator;
    var cache = try LRUCache.init(2, allocator);
    defer cache.deinit();

    cache.put(1, 1);
    cache.put(1, 5);
    try std.testing.expectEqual(@as(i32, 5), cache.get(1));
    cache.put(2, 2);
    cache.put(3, 3);
    try std.testing.expectEqual(@as(i32, -1), cache.get(1));
}

test "lru cache - get non-existent key" {
    const allocator = std.testing.allocator;
    var cache = try LRUCache.init(2, allocator);
    defer cache.deinit();

    try std.testing.expectEqual(@as(i32, -1), cache.get(1));
    cache.put(1, 1);
    try std.testing.expectEqual(@as(i32, 1), cache.get(1));
}

test "lru cache - capacity 3 with multiple operations" {
    const allocator = std.testing.allocator;
    var cache = try LRUCache.init(3, allocator);
    defer cache.deinit();

    cache.put(1, 1);
    cache.put(2, 2);
    cache.put(3, 3);
    try std.testing.expectEqual(@as(i32, 1), cache.get(1));
    cache.put(4, 4);
    try std.testing.expectEqual(@as(i32, -1), cache.get(2));
    try std.testing.expectEqual(@as(i32, 3), cache.get(3));
}
