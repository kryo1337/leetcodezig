const std = @import("std");

fn maxArea(height: []const i32) i32 {
    var max_area: i32 = 0;
    var left: usize = 0;
    var right: usize = height.len - 1;

    while (left < right) {
        const area = @min(height[left], height[right]) * @as(i32, @intCast(right - left));
        max_area = @max(area, max_area);
        if (height[left] < height[right]) {
            left += 1;
        } else {
            right -= 1;
        }
    }
    return max_area;
}

pub fn main() !void {}

test "container with most water - basic case" {
    const height = [_]i32{ 1, 8, 6, 2, 5, 4, 8, 3, 7 };
    const expected: i32 = 49;
    const result = maxArea(&height);
    std.debug.print("Test 'basic case': height={any}, result={}\n", .{ height, result });
    try std.testing.expectEqual(expected, result);
}

test "container with most water - minimal length" {
    const height = [_]i32{ 1, 1 };
    const expected: i32 = 1;
    const result = maxArea(&height);
    std.debug.print("Test 'minimal length': height={any}, result={}\n", .{ height, result });
    try std.testing.expectEqual(expected, result);
}

test "container with most water - symmetric" {
    const height = [_]i32{ 4, 3, 2, 1, 4 };
    const expected: i32 = 16;
    const result = maxArea(&height);
    std.debug.print("Test 'symmetric': height={any}, result={}\n", .{ height, result });
    try std.testing.expectEqual(expected, result);
}

test "container with most water - all same height" {
    const height = [_]i32{ 2, 2, 2, 2 };
    const expected: i32 = 6;
    const result = maxArea(&height);
    std.debug.print("Test 'all same height': height={any}, result={}\n", .{ height, result });
    try std.testing.expectEqual(expected, result);
}

test "container with most water - increasing then decreasing" {
    const height = [_]i32{ 1, 2, 3, 4, 3, 2, 1 };
    const expected: i32 = 8;
    const result = maxArea(&height);
    std.debug.print("Test 'increasing then decreasing': height={any}, result={}\n", .{ height, result });
    try std.testing.expectEqual(expected, result);
}
