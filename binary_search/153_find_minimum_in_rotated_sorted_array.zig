const std = @import("std");

fn findMin(nums: []const i32) i32 {
    var left: usize = 0;
    var right: usize = nums.len - 1;
    while (left < right) {
        const mid = left + (right - left) / 2;
        if (nums[mid] > nums[right]) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    return nums[left];
}

pub fn main() !void {}

test "find min - basic case 1" {
    const nums = [_]i32{ 3, 4, 5, 1, 2 };
    const expected: i32 = 1;
    const result = findMin(&nums);
    std.debug.print("Test 'basic case 1': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expectEqual(expected, result);
}

test "find min - basic case 2" {
    const nums = [_]i32{ 4, 5, 6, 7, 0, 1, 2 };
    const expected: i32 = 0;
    const result = findMin(&nums);
    std.debug.print("Test 'basic case 2': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expectEqual(expected, result);
}

test "find min - single element" {
    const nums = [_]i32{1};
    const expected: i32 = 1;
    const result = findMin(&nums);
    std.debug.print("Test 'single element': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expectEqual(expected, result);
}

test "find min - not rotated" {
    const nums = [_]i32{ 1, 2, 3, 4, 5 };
    const expected: i32 = 1;
    const result = findMin(&nums);
    std.debug.print("Test 'not rotated': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expectEqual(expected, result);
}

test "find min - rotated at start" {
    const nums = [_]i32{ 2, 1 };
    const expected: i32 = 1;
    const result = findMin(&nums);
    std.debug.print("Test 'rotated at start': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expectEqual(expected, result);
}

test "find min - rotated at end" {
    const nums = [_]i32{ 2, 3, 4, 5, 1 };
    const expected: i32 = 1;
    const result = findMin(&nums);
    std.debug.print("Test 'rotated at end': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expectEqual(expected, result);
}
