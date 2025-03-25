const std = @import("std");

// Linear search
// fn searchMatrix(matrix: []const []const i32, target: i32) bool {
//     if (matrix.len == 0 or matrix[0].len == 0) return false;
//     var row: usize = 0;
//     while (row < matrix.len) {
//         var col: usize = 0;
//         while (col < matrix[row].len) {
//             if (matrix[row][col] != target) {
//                 col += 1;
//             } else {
//                 return true;
//             }
//         }
//         row += 1;
//     }
//     return false;
// }

// Binary search
fn searchMatrix(matrix: []const []const i32, target: i32) bool {
    if (matrix.len == 0 or matrix[0].len == 0) return false;
    const rows: usize = matrix.len;
    const cols: usize = matrix[0].len;
    var left: usize = 0;
    var right: usize = rows * cols - 1;

    while (left <= right) {
        const mid = left + (right - left) / 2;
        const row = mid / cols;
        const col = mid % cols;
        const value = matrix[row][col];
        if (value == target) {
            return true;
        } else if (value < target) {
            left = mid + 1;
        } else {
            if (mid == 0) break;
            right = mid - 1;
        }
    }
    return false;
}

pub fn main() !void {}

test "search matrix - basic case found" {
    const matrix = [_][]const i32{
        &[_]i32{ 1, 3, 5, 7 },
        &[_]i32{ 10, 11, 16, 20 },
        &[_]i32{ 23, 30, 34, 60 },
    };
    const target: i32 = 3;
    const expected: bool = true;
    const result = searchMatrix(&matrix, target);
    std.debug.print("Test 'basic case found': matrix={any}, target={}, result={}\n", .{ matrix, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search matrix - basic case not found" {
    const matrix = [_][]const i32{
        &[_]i32{ 1, 3, 5, 7 },
        &[_]i32{ 10, 11, 16, 20 },
        &[_]i32{ 23, 30, 34, 60 },
    };
    const target: i32 = 13;
    const expected: bool = false;
    const result = searchMatrix(&matrix, target);
    std.debug.print("Test 'basic case not found': matrix={any}, target={}, result={}\n", .{ matrix, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search matrix - single element found" {
    const matrix = [_][]const i32{
        &[_]i32{5},
    };
    const target: i32 = 5;
    const expected: bool = true;
    const result = searchMatrix(&matrix, target);
    std.debug.print("Test 'single element found': matrix={any}, target={}, result={}\n", .{ matrix, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search matrix - single element not found" {
    const matrix = [_][]const i32{
        &[_]i32{5},
    };
    const target: i32 = 3;
    const expected: bool = false;
    const result = searchMatrix(&matrix, target);
    std.debug.print("Test 'single element not found': matrix={any}, target={}, result={}\n", .{ matrix, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search matrix - empty matrix" {
    const matrix = [_][]const i32{};
    const target: i32 = 7;
    const expected: bool = false;
    const result = searchMatrix(&matrix, target);
    std.debug.print("Test 'empty matrix': matrix={any}, target={}, result={}\n", .{ matrix, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search matrix - target at start" {
    const matrix = [_][]const i32{
        &[_]i32{ 1, 3, 5, 7 },
        &[_]i32{ 10, 11, 16, 20 },
    };
    const target: i32 = 1;
    const expected: bool = true;
    const result = searchMatrix(&matrix, target);
    std.debug.print("Test 'target at start': matrix={any}, target={}, result={}\n", .{ matrix, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search matrix - target at end" {
    const matrix = [_][]const i32{
        &[_]i32{ 1, 3, 5, 7 },
        &[_]i32{ 10, 11, 16, 20 },
    };
    const target: i32 = 20;
    const expected: bool = true;
    const result = searchMatrix(&matrix, target);
    std.debug.print("Test 'target at end': matrix={any}, target={}, result={}\n", .{ matrix, target, result });
    try std.testing.expectEqual(expected, result);
}
