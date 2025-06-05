const std = @import("std");
const Allocator = std.mem.Allocator;

const TrieNode = struct {
    children: [26]?*TrieNode,
    is_end: bool,

    fn init(allocator: Allocator) !*TrieNode {
        const node = try allocator.create(TrieNode);
        node.* = .{
            .children = [_]?*TrieNode{null} ** 26,
            .is_end = false,
        };
        return node;
    }

    fn deinit(self: *TrieNode, allocator: Allocator) void {
        for (self.children) |maybe| {
            if (maybe) |child| {
                child.deinit(allocator);
            }
        }
        allocator.destroy(self);
    }
};

pub const Trie = struct {
    root: *TrieNode,
    allocator: Allocator,

    pub fn init(allocator: Allocator) !*Trie {
        const trie = try allocator.create(Trie);
        trie.* = .{
            .root = try TrieNode.init(allocator),
            .allocator = allocator,
        };
        return trie;
    }

    pub fn deinit(self: *Trie) void {
        self.root.deinit(self.allocator);
        self.allocator.destroy(self);
    }

    pub fn insert(self: *Trie, word: []const u8) !void {
        var current = self.root;
        for (word) |c| {
            const idx = c - 'a';
            if (current.children[idx] == null) {
                current.children[idx] = try TrieNode.init(self.allocator);
            }
            current = current.children[idx].?;
        }
        current.is_end = true;
    }

    pub fn search(self: *Trie, word: []const u8) bool {
        const node = self.findNode(word);
        return node != null and node.?.is_end;
    }

    pub fn startsWith(self: *Trie, prefix: []const u8) bool {
        return self.findNode(prefix) != null;
    }

    fn findNode(self: *Trie, prefix: []const u8) ?*TrieNode {
        var current = self.root;
        for (prefix) |c| {
            const idx = c - 'a';
            if (current.children[idx] == null) return null;
            current = current.children[idx].?;
        }
        return current;
    }
};

test "trie basic operations" {
    const trie = try Trie.init(std.testing.allocator);
    defer trie.deinit();

    try trie.insert("apple");
    try std.testing.expect(trie.search("apple"));
    try std.testing.expect(!trie.search("app"));
    try std.testing.expect(trie.startsWith("app"));

    try trie.insert("app");
    try std.testing.expect(trie.search("app"));
}

test "trie empty string" {
    const trie = try Trie.init(std.testing.allocator);
    defer trie.deinit();

    try trie.insert("");
    try std.testing.expect(trie.search(""));
    try std.testing.expect(trie.startsWith(""));
}

test "trie multiple words" {
    const trie = try Trie.init(std.testing.allocator);
    defer trie.deinit();

    try trie.insert("apple");
    try trie.insert("app");
    try trie.insert("application");
    try trie.insert("banana");

    try std.testing.expect(trie.search("apple"));
    try std.testing.expect(trie.search("app"));
    try std.testing.expect(trie.search("application"));
    try std.testing.expect(trie.search("banana"));
    try std.testing.expect(!trie.search("ban"));
    try std.testing.expect(trie.startsWith("ban"));
    try std.testing.expect(trie.startsWith("appl"));
}
