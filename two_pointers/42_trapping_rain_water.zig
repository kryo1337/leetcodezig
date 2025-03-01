const std = @import("std");

fn trap(height: []const i32) i32 {
    var left: usize = 0;
    var right: usize = height.len - 1;
    var max_left: i32 = 0;
    var max_right: i32 = 0;
    var water: i32 = 0;
    while (left < right) {
        max_left = @max(max_left, height[left]);
        max_right = @max(max_right, height[right]);
        if (max_left <= max_right) {
            water += max_left - height[left];
            left += 1;
        } else {
            water += max_right - height[right];
            right -= 1;
        }
    }
    return water;
}

pub fn main() !void {}

test "trapping rain water - basic case" {
    const height = [_]i32{ 0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1 };
    const expected: i32 = 6;
    const result = trap(&height);
    std.debug.print("Test 'basic case': height={any}, result={}\n", .{ height, result });
    try std.testing.expectEqual(expected, result);
}

test "trapping rain water - another example" {
    const height = [_]i32{ 4, 2, 0, 3, 2, 5 };
    const expected: i32 = 9;
    const result = trap(&height);
    std.debug.print("Test 'another example': height={any}, result={}\n", .{ height, result });
    try std.testing.expectEqual(expected, result);
}

test "trapping rain water - minimal length" {
    const height = [_]i32{ 1, 2 };
    const expected: i32 = 0;
    const result = trap(&height);
    std.debug.print("Test 'minimal length': height={any}, result={}\n", .{ height, result });
    try std.testing.expectEqual(expected, result);
}

test "trapping rain water - no water" {
    const height = [_]i32{ 3, 2, 1 };
    const expected: i32 = 0;
    const result = trap(&height);
    std.debug.print("Test 'no water': height={any}, result={}\n", .{ height, result });
    try std.testing.expectEqual(expected, result);
}

test "trapping rain water - all same height" {
    const height = [_]i32{ 2, 2, 2, 2 };
    const expected: i32 = 0;
    const result = trap(&height);
    std.debug.print("Test 'all same height': height={any}, result={}\n", .{ height, result });
    try std.testing.expectEqual(expected, result);
}
