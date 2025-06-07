const std = @import("std");
const Allocator = std.mem.Allocator;

const TrieNode = struct {
    array: [26]?*TrieNode,
    is_end: bool,

    fn init(allocator: Allocator) !*TrieNode {
        const node = try allocator.create(TrieNode);
        node.* = .{
            .array = [_]?*TrieNode{null} ** 26,
            .is_end = false,
        };
        return node;
    }

    fn deinit(self: *TrieNode, allocator: Allocator) void {
        for (self.array) |maybe| {
            if (maybe) |node| {
                node.deinit(allocator);
            }
        }
        allocator.destroy(self);
    }
};

pub const WordDictionary = struct {
    root: *TrieNode,
    allocator: Allocator,

    pub fn init(allocator: Allocator) !*WordDictionary {
        const dir = try allocator.create(WordDictionary);
        dir.* = .{
            .root = try TrieNode.init(allocator),
            .allocator = allocator,
        };
        return dir;
    }

    pub fn deinit(self: *WordDictionary) void {
        self.root.deinit(self.allocator);
        self.allocator.destroy(self);
    }

    pub fn addWord(self: *WordDictionary, word: []const u8) !void {
        var current = self.root;
        for (word) |c| {
            const idx = c - 'a';
            if (current.array[idx] == null) {
                current.array[idx] = try TrieNode.init(self.allocator);
            }
            current = current.array[idx].?;
        }
        current.is_end = true;
    }

    pub fn search(self: *WordDictionary, word: []const u8) bool {
        if (word.len == 0) return self.root.is_end;
        return self.searchNode(self.root, word, 0);
    }

    fn searchNode(self: *WordDictionary, node: *TrieNode, word: []const u8, idx: usize) bool {
        if (idx == word.len) return node.is_end;

        const c = word[idx];
        if (c == '.') {
            for (node.array) |maybe| {
                if (maybe) |child| {
                    if (self.searchNode(child, word, idx + 1)) return true;
                }
            }
            return false;
        }
        const child_idx = c - 'a';
        if (child_idx >= 26) return false;
        if (node.array[child_idx]) |child| {
            return self.searchNode(child, word, idx + 1);
        }
        return false;
    }
};

test "word dictionary basic operations" {
    const dict = try WordDictionary.init(std.testing.allocator);
    defer dict.deinit();

    try dict.addWord("bad");
    try dict.addWord("dad");
    try dict.addWord("mad");

    try std.testing.expect(dict.search("bad"));
    try std.testing.expect(!dict.search("pad"));
    try std.testing.expect(dict.search(".ad"));
    try std.testing.expect(dict.search("b.."));
}

test "word dictionary wildcards" {
    const dict = try WordDictionary.init(std.testing.allocator);
    defer dict.deinit();

    try dict.addWord("a");
    try dict.addWord("ab");

    try std.testing.expect(dict.search("a"));
    try std.testing.expect(dict.search("."));
    try std.testing.expect(dict.search("a."));
    try std.testing.expect(dict.search(".b"));
    try std.testing.expect(dict.search(".."));
}

test "word dictionary empty string" {
    const dict = try WordDictionary.init(std.testing.allocator);
    defer dict.deinit();

    try dict.addWord("");
    try std.testing.expect(dict.search(""));
    try std.testing.expect(!dict.search("a"));
}

test "word dictionary multiple wildcards" {
    const dict = try WordDictionary.init(std.testing.allocator);
    defer dict.deinit();

    try dict.addWord("abc");
    try dict.addWord("abd");
    try dict.addWord("adc");

    try std.testing.expect(dict.search("a.c"));
    try std.testing.expect(dict.search("ab."));
    try std.testing.expect(dict.search(".b."));
    try std.testing.expect(dict.search("a.."));
}

