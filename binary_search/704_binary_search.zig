const std = @import("std");

fn search(nums: []const i32, target: i32) i32 {
    if (nums.len == 0) return -1;
    var left: usize = 0;
    var right: usize = nums.len - 1;
    while (left <= right) {
        const mid = left + (right - left) / 2;
        if (nums[mid] == target) return @intCast(mid);
        if (nums[mid] < target) left = mid + 1 else right = mid - 1;
    }
    if (left < nums.len and nums[left] == target) {
        return @intCast(left);
    }
    return -1;
}

pub fn main() !void {}

test "binary search - basic case" {
    const nums = [_]i32{ -1, 0, 3, 5, 9, 12 };
    const target: i32 = 9;
    const expected: i32 = 4;
    const result = search(&nums, target);
    std.debug.print("Test 'basic case': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "binary search - target not found" {
    const nums = [_]i32{ -1, 0, 3, 5, 9, 12 };
    const target: i32 = 2;
    const expected: i32 = -1;
    const result = search(&nums, target);
    std.debug.print("Test 'target not found': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "binary search - empty array" {
    const nums = [_]i32{};
    const target: i32 = 7;
    const expected: i32 = -1;
    const result = search(&nums, target);
    std.debug.print("Test 'empty array': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "binary search - target at start" {
    const nums = [_]i32{ 1, 2, 3, 4, 5 };
    const target: i32 = 1;
    const expected: i32 = 0;
    const result = search(&nums, target);
    std.debug.print("Test 'target at start': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "binary search - target at end" {
    const nums = [_]i32{ 1, 2, 3, 4, 5 };
    const target: i32 = 5;
    const expected: i32 = 4;
    const result = search(&nums, target);
    std.debug.print("Test 'target at end': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}
