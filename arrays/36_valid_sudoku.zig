const std = @import("std");
const Allocator = std.mem.Allocator;

fn isValidSudoku(allocator: Allocator, board: [9][9]u8) bool {
    var row: usize = 0;
    while (row < 9) : (row += 1) {
        var map = std.AutoHashMap(u8, void).init(allocator);
        defer map.deinit();
        var col: usize = 0;
        while (col < 9) : (col += 1) {
            const val = board[row][col];
            if (val != '.') {
                if (map.contains(val)) {
                    return false;
                }
                map.put(val, {}) catch unreachable;
            }
        }
    }

    var col: usize = 0;
    while (col < 9) : (col += 1) {
        var map = std.AutoHashMap(u8, void).init(allocator);
        defer map.deinit();
        row = 0;
        while (row < 9) : (row += 1) {
            const val = board[row][col];
            if (val != '.') {
                if (map.contains(val)) {
                    return false;
                }
                map.put(val, {}) catch unreachable;
            }
        }
    }

    var boxRow: usize = 0;
    while (boxRow < 9) : (boxRow += 3) {
        var boxCol: usize = 0;
        while (boxCol < 9) : (boxCol += 3) {
            var map = std.AutoHashMap(u8, void).init(allocator);
            defer map.deinit();
            var r: usize = boxRow;
            while (r < boxRow + 3) : (r += 1) {
                var c: usize = boxCol;
                while (c < boxCol + 3) : (c += 1) {
                    const val = board[r][c];
                    if (val != '.') {
                        if (map.contains(val)) {
                            return false;
                        }
                        map.put(val, {}) catch unreachable;
                    }
                }
            }
        }
    }

    return true;
}

pub fn main() !void {}

test "valid sudoku - valid board" {
    const board = [9][9]u8{
        "53..7....".*,
        "6..195...".*,
        ".98....6.".*,
        "8...6...3".*,
        "4..8.3..1".*,
        "7...2...6".*,
        ".6....28.".*,
        "...419..5".*,
        "....8..79".*,
    };
    const acc = std.heap.page_allocator;
    const result = isValidSudoku(acc, board);
    std.debug.print("Test 'valid board': result={}\n", .{result});
    try std.testing.expect(result == true);
}

test "valid sudoku - invalid row" {
    const board = [9][9]u8{
        "53..7....".*,
        "6..195...".*,
        ".98....6.".*,
        "8...6...3".*,
        "4..8.3..1".*,
        "7...2...6".*,
        ".6....28.".*,
        "...419..5".*,
        "5...8..79".*,
    };
    const acc = std.heap.page_allocator;
    const result = isValidSudoku(acc, board);
    std.debug.print("Test 'invalid row': result={}\n", .{result});
    try std.testing.expect(result == false);
}

test "valid sudoku - invalid column" {
    const board = [9][9]u8{
        "53..7....".*,
        "5..195...".*,
        ".98....6.".*,
        "8...6...3".*,
        "4..8.3..1".*,
        "7...2...6".*,
        ".6....28.".*,
        "...419..5".*,
        "....8..79".*,
    };
    const acc = std.heap.page_allocator;
    const result = isValidSudoku(acc, board);
    std.debug.print("Test 'invalid column': result={}\n", .{result});
    try std.testing.expect(result == false);
}

test "valid sudoku - invalid box" {
    const board = [9][9]u8{
        "53..7....".*,
        "6..195...".*,
        "598....6.".*,
        "8...6...3".*,
        "4..8.3..1".*,
        "7...2...6".*,
        ".6....28.".*,
        "...419..5".*,
        "....8..79".*,
    };
    const acc = std.heap.page_allocator;
    const result = isValidSudoku(acc, board);
    std.debug.print("Test 'invalid box': result={}\n", .{result});
    try std.testing.expect(result == false);
}
