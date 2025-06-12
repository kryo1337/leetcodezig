const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn maxAreaOfIsland(allocator: Allocator, grid: []const []const u8) u32 {
    var visited = std.ArrayList(std.ArrayList(bool)).init(allocator);
    defer {
        for (visited.items) |*row| {
            row.deinit();
        }
        visited.deinit();
    }

    for (grid) |row| {
        var row_visited = std.ArrayList(bool).init(allocator);
        for (row) |_| {
            row_visited.append(false) catch unreachable;
        }
        visited.append(row_visited) catch unreachable;
    }

    var maxik: u32 = 0;
    for (grid, 0..) |row, i| {
        for (row, 0..) |cell, j| {
            if (cell == '1' and !visited.items[i].items[j]) {
                const area = dfs(grid, &visited, i, j);
                maxik = @max(maxik, area);
            }
        }
    }
    return maxik;
}

fn isValid(grid: []const []const u8, row: usize, col: usize) bool {
    return row < grid.len and col < grid[0].len;
}

fn dfs(grid: []const []const u8, visited: *std.ArrayList(std.ArrayList(bool)), row: usize, col: usize) u32 {
    if (!isValid(grid, row, col) or visited.items[row].items[col] or grid[row][col] != '1') return 0;

    visited.items[row].items[col] = true;
    var area: u32 = 1;

    if (row + 1 < grid.len) area += dfs(grid, visited, row + 1, col);
    if (row > 0) area += dfs(grid, visited, row - 1, col);
    if (col + 1 < grid[0].len) area += dfs(grid, visited, row, col + 1);
    if (col > 0) area += dfs(grid, visited, row, col - 1);

    return area;
}

test "single island" {
    const allocator = std.testing.allocator;
    const grid = [_][]const u8{
        "11100",
        "11000",
        "00000",
    };
    try std.testing.expectEqual(@as(u32, 5), maxAreaOfIsland(allocator, &grid));
}

test "multiple islands" {
    const allocator = std.testing.allocator;
    const grid = [_][]const u8{
        "11000",
        "11000",
        "00100",
        "00011",
    };
    try std.testing.expectEqual(@as(u32, 4), maxAreaOfIsland(allocator, &grid));
}

test "no islands" {
    const allocator = std.testing.allocator;
    const grid = [_][]const u8{
        "00000",
        "00000",
        "00000",
    };
    try std.testing.expectEqual(@as(u32, 0), maxAreaOfIsland(allocator, &grid));
}

test "one big island" {
    const allocator = std.testing.allocator;
    const grid = [_][]const u8{
        "11111",
        "11111",
        "11111",
    };
    try std.testing.expectEqual(@as(u32, 15), maxAreaOfIsland(allocator, &grid));
}

