const std = @import("std");
const Allocator = std.mem.Allocator;

const TrieNode = struct {
    array: [26]?*TrieNode,
    is_end: bool,
    word: []const u8,

    fn init(allocator: Allocator) !*TrieNode {
        const node = try allocator.create(TrieNode);
        node.* = .{
            .array = [_]?*TrieNode{null} ** 26,
            .is_end = false,
            .word = undefined,
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

pub const WordSearch = struct {
    root: *TrieNode,
    allocator: Allocator,
    rows: usize,
    cols: usize,
    visited: []bool,

    pub fn init(allocator: Allocator) !*WordSearch {
        const ws = try allocator.create(WordSearch);
        ws.* = .{
            .root = try TrieNode.init(allocator),
            .allocator = allocator,
            .rows = 0,
            .cols = 0,
            .visited = undefined,
        };
        return ws;
    }

    pub fn deinit(self: *WordSearch) void {
        self.root.deinit(self.allocator);
        if (self.visited.len > 0) {
            self.allocator.free(self.visited);
        }
        self.allocator.destroy(self);
    }

    pub fn findWords(self: *WordSearch, board: [][]const u8, words: []const []const u8) ![][]const u8 {
        self.rows = board.len;
        self.cols = if (board.len > 0) board[0].len else 0;

        if (self.rows == 0 or self.cols == 0 or words.len == 0) {
            self.visited = &[_]bool{};
            return &[_][]const u8{};
        }
        self.visited = try self.allocator.alloc(bool, self.rows * self.cols);
        @memset(self.visited, false);

        try self.buildTrie(words);

        var result = std.ArrayList([]const u8).init(self.allocator);
        errdefer result.deinit();

        for (0..self.rows) |i| {
            for (0..self.cols) |j| {
                try self.dfs(board, i, j, self.root, &result);
            }
        }
        return result.toOwnedSlice();
    }

    fn dfs(self: *WordSearch, board: [][]const u8, i: usize, j: usize, node: *TrieNode, result: *std.ArrayList([]const u8)) !void {
        if (i >= self.rows or j >= self.cols) return;

        const pos = i * self.cols + j;
        if (self.visited[pos]) return;

        const c = board[i][j];
        const idx = c - 'a';

        if (node.array[idx] == null) return;
        self.visited[pos] = true;
        const next_node = node.array[idx].?;

        if (next_node.is_end) {
            try result.append(next_node.word);
            next_node.is_end = false;
        }
        if (i > 0) try self.dfs(board, i - 1, j, next_node, result);
        if (i < self.rows - 1) try self.dfs(board, i + 1, j, next_node, result);
        if (j > 0) try self.dfs(board, i, j - 1, next_node, result);
        if (j < self.cols - 1) try self.dfs(board, i, j + 1, next_node, result);

        self.visited[pos] = false;
    }

    fn buildTrie(self: *WordSearch, words: []const []const u8) !void {
        for (words) |word| {
            var current = self.root;
            for (word) |c| {
                const idx = c - 'a';
                if (current.array[idx] == null) {
                    current.array[idx] = try TrieNode.init(self.allocator);
                }
                current = current.array[idx].?;
            }
            current.is_end = true;
            current.word = word;
        }
    }
};

test "word search basic" {
    const allocator = std.testing.allocator;
    var board = [_][]const u8{
        "oaan",
        "etae",
        "ihkr",
        "iflv",
    };
    var words = [_][]const u8{ "oath", "pea", "eat", "rain" };

    const ws = try WordSearch.init(allocator);
    defer ws.deinit();

    const result = try ws.findWords(&board, &words);
    defer allocator.free(result);

    try std.testing.expect(result.len == 2);
    const found_eat = std.mem.eql(u8, result[0], "eat") or std.mem.eql(u8, result[1], "eat");
    const found_oath = std.mem.eql(u8, result[0], "oath") or std.mem.eql(u8, result[1], "oath");
    try std.testing.expect(found_eat);
    try std.testing.expect(found_oath);
}

test "word search empty" {
    const allocator = std.testing.allocator;
    var board = [_][]const u8{
        "a",
        "b",
    };
    var words = [_][]const u8{"ab"};

    const ws = try WordSearch.init(allocator);
    defer ws.deinit();

    const result = try ws.findWords(&board, &words);
    defer allocator.free(result);

    try std.testing.expect(result.len == 1);
    try std.testing.expect(std.mem.eql(u8, result[0], "ab"));
}

test "word search truly empty" {
    const allocator = std.testing.allocator;
    var board = [_][]const u8{};
    var words = [_][]const u8{};

    const ws = try WordSearch.init(allocator);
    defer ws.deinit();

    const result = try ws.findWords(&board, &words);
    defer allocator.free(result);

    try std.testing.expect(result.len == 0);
}

test "word search single cell" {
    const allocator = std.testing.allocator;
    var board = [_][]const u8{
        "a",
    };
    var words = [_][]const u8{"a"};

    const ws = try WordSearch.init(allocator);
    defer ws.deinit();

    const result = try ws.findWords(&board, &words);
    defer allocator.free(result);

    try std.testing.expect(result.len == 1);
    try std.testing.expect(std.mem.eql(u8, result[0], "a"));
}

