const std = @import("std");

fn search(nums: []const i32, target: i32) i32 {
    if (nums.len == 0) return -1;
    var left: usize = 0;
    var right: usize = nums.len - 1;
    while (left <= right) {
        const mid = left + (right - left) / 2;
        if (nums[mid] == target) return @intCast(mid);
        if (nums[left] <= nums[mid]) {
            if (nums[left] <= target and target < nums[mid]) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        } else {
            if (nums[mid] < target and target <= nums[right]) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
    }
    return -1;
}

pub fn main() !void {}

test "search rotated - basic case found" {
    const nums = [_]i32{ 4, 5, 6, 7, 0, 1, 2 };
    const target: i32 = 0;
    const expected: i32 = 4;
    const result = search(&nums, target);
    std.debug.print("Test 'basic case found': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search rotated - basic case not found" {
    const nums = [_]i32{ 4, 5, 6, 7, 0, 1, 2 };
    const target: i32 = 3;
    const expected: i32 = -1;
    const result = search(&nums, target);
    std.debug.print("Test 'basic case not found': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search rotated - single element found" {
    const nums = [_]i32{1};
    const target: i32 = 1;
    const expected: i32 = 0;
    const result = search(&nums, target);
    std.debug.print("Test 'single element found': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search rotated - single element not found" {
    const nums = [_]i32{1};
    const target: i32 = 0;
    const expected: i32 = -1;
    const result = search(&nums, target);
    std.debug.print("Test 'single element not found': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search rotated - not rotated found" {
    const nums = [_]i32{ 0, 1, 2, 3, 4, 5, 6 };
    const target: i32 = 4;
    const expected: i32 = 4;
    const result = search(&nums, target);
    std.debug.print("Test 'not rotated found': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search rotated - not rotated not found" {
    const nums = [_]i32{ 0, 1, 2, 3, 4, 5, 6 };
    const target: i32 = 7;
    const expected: i32 = -1;
    const result = search(&nums, target);
    std.debug.print("Test 'not rotated not found': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search rotated - rotated at start" {
    const nums = [_]i32{ 2, 1 };
    const target: i32 = 1;
    const expected: i32 = 1;
    const result = search(&nums, target);
    std.debug.print("Test 'rotated at start': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}

test "search rotated - rotated at end" {
    const nums = [_]i32{ 2, 3, 4, 5, 1 };
    const target: i32 = 1;
    const expected: i32 = 4;
    const result = search(&nums, target);
    std.debug.print("Test 'rotated at end': nums={any}, target={}, result={}\n", .{ nums, target, result });
    try std.testing.expectEqual(expected, result);
}
