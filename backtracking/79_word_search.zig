const std = @import("std");
const Allocator = std.mem.Allocator;

fn dfs(
    board: []const []const u8,
    word: []const u8,
    row: usize,
    col: usize,
    word_idx: usize,
    visited: [][]bool,
) bool {
    if (word_idx == word.len) return true;

    if (row >= board.len or
        col >= board[0].len or
        visited[row][col] or
        board[row][col] != word[word_idx])
    {
        return false;
    }

    visited[row][col] = true;
    if (word_idx == word.len - 1) return true;

    const directions = [_][2]i32{
        .{ -1, 0 },
        .{ 1, 0 },
        .{ 0, -1 },
        .{ 0, 1 },
    };

    for (directions) |dir| {
        const new_row = @as(i32, @intCast(row)) + dir[0];
        const new_col = @as(i32, @intCast(col)) + dir[1];

        if (new_row < 0 or new_col < 0 or
            new_row >= @as(i32, @intCast(board.len)) or
            new_col >= @as(i32, @intCast(board[0].len)))
        {
            continue;
        }
        if (dfs(board, word, @intCast(new_row), @intCast(new_col), word_idx + 1, visited)) {
            return true;
        }
    }
    visited[row][col] = false;
    return false;
}

pub fn exist(board: []const []const u8, word: []const u8, allocator: Allocator) !bool {
    if (board.len == 0) return false;
    if (board[0].len == 0) return false;
    if (word.len == 0) return true;

    var visited = try allocator.alloc([]bool, board.len);
    defer {
        for (visited) |row| {
            allocator.free(row);
        }
        allocator.free(visited);
    }

    for (visited, 0..) |_, i| {
        visited[i] = try allocator.alloc(bool, board[0].len);
        @memset(visited[i], false);
    }

    for (board, 0..) |row, i| {
        for (row, 0..) |_, j| {
            if (dfs(board, word, i, j, 0, visited)) {
                return true;
            }
        }
    }
    return false;
}

pub fn main() !void {}

test "word search - basic case" {
    const allocator = std.testing.allocator;
    const board = [_][]const u8{
        &[_]u8{ 'A', 'B', 'C', 'E' },
        &[_]u8{ 'S', 'F', 'C', 'S' },
        &[_]u8{ 'A', 'D', 'E', 'E' },
    };
    const word = "ABCCED";
    try std.testing.expect(try exist(&board, word, allocator));
}

test "word search - not found" {
    const allocator = std.testing.allocator;
    const board = [_][]const u8{
        &[_]u8{ 'A', 'B', 'C', 'E' },
        &[_]u8{ 'S', 'F', 'C', 'S' },
        &[_]u8{ 'A', 'D', 'E', 'E' },
    };
    const word = "ABCB";
    try std.testing.expect(!try exist(&board, word, allocator));
}

test "word search - empty board" {
    const allocator = std.testing.allocator;
    const board = [_][]const u8{};
    const word = "A";
    try std.testing.expect(!try exist(&board, word, allocator));
}

test "word search - single cell" {
    const allocator = std.testing.allocator;
    const board = [_][]const u8{
        &[_]u8{'A'},
    };
    const word = "A";
    try std.testing.expect(try exist(&board, word, allocator));
}

test "word search - same character multiple times" {
    const allocator = std.testing.allocator;
    const board = [_][]const u8{
        &[_]u8{ 'A', 'A', 'A', 'A' },
        &[_]u8{ 'A', 'A', 'A', 'A' },
        &[_]u8{ 'A', 'A', 'A', 'A' },
    };
    const word = "AAAAAAAA";
    try std.testing.expect(try exist(&board, word, allocator));
}

