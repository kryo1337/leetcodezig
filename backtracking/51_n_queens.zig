const std = @import("std");
const Allocator = std.mem.Allocator;

fn initBoard(n: usize, allocator: Allocator) ![][]u8 {
    const board = try allocator.alloc([]u8, n);
    for (board) |*row| {
        row.* = try allocator.alloc(u8, n);
        @memset(row.*, '.');
    }
    return board;
}

fn deinitBoard(board: [][]u8, allocator: Allocator) void {
    for (board) |row| {
        allocator.free(row);
    }
    allocator.free(board);
}

fn isValid(board: [][]u8, row: usize, col: usize) bool {
    const n = board.len;

    for (0..row) |i| {
        if (board[i][col] == 'Q') return false;
    }

    var i: usize = row;
    var j: usize = col;
    while (i > 0 and j > 0) {
        i -= 1;
        j -= 1;
        if (board[i][j] == 'Q') return false;
    }

    i = row;
    j = col;
    while (i > 0 and j < n - 1) {
        i -= 1;
        j += 1;
        if (board[i][j] == 'Q') return false;
    }
    return true;
}

fn boardToSolution(board: [][]u8, allocator: Allocator) ![]const []const u8 {
    const solution = try allocator.alloc([]const u8, board.len);
    for (board, 0..) |row, i| {
        solution[i] = try allocator.dupe(u8, row);
    }
    return solution;
}

fn backtrack(
    board: [][]u8,
    row: usize,
    result: *std.ArrayList([]const []const u8),
    allocator: Allocator,
) !void {
    const n = board.len;
    if (row == n) {
        const solution = try boardToSolution(board, allocator);
        try result.append(solution);
        return;
    }

    for (0..n) |col| {
        if (isValid(board, row, col)) {
            board[row][col] = 'Q';
            try backtrack(board, row + 1, result, allocator);
            board[row][col] = '.';
        }
    }
}

pub fn solveNQueens(n: usize, allocator: Allocator) ![][]const []const u8 {
    var result = std.ArrayList([]const []const u8).init(allocator);
    const board = try initBoard(n, allocator);
    defer deinitBoard(board, allocator);

    try backtrack(board, 0, &result, allocator);
    return result.toOwnedSlice();
}

test "n queens - n=1" {
    const result = try solveNQueens(1, std.testing.allocator);
    defer {
        for (result) |solution| {
            for (solution) |row| {
                std.testing.allocator.free(row);
            }
            std.testing.allocator.free(solution);
        }
        std.testing.allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqualStrings("Q", result[0][0]);
}

test "n queens - n=4" {
    const result = try solveNQueens(4, std.testing.allocator);
    defer {
        for (result) |solution| {
            for (solution) |row| {
                std.testing.allocator.free(row);
            }
            std.testing.allocator.free(solution);
        }
        std.testing.allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 2), result.len);
    try std.testing.expectEqualStrings(".Q..", result[0][0]);
    try std.testing.expectEqualStrings("...Q", result[0][1]);
    try std.testing.expectEqualStrings("Q...", result[0][2]);
    try std.testing.expectEqualStrings("..Q.", result[0][3]);
}

test "n queens - n=8" {
    const result = try solveNQueens(8, std.testing.allocator);
    defer {
        for (result) |solution| {
            for (solution) |row| {
                std.testing.allocator.free(row);
            }
            std.testing.allocator.free(solution);
        }
        std.testing.allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 92), result.len);
}

