const std = @import("std");
const Allocator = std.mem.Allocator;

fn findDuplicate(nums: []const i32) i32 {
    var slow: i32 = nums[0];
    var fast: i32 = nums[0];

    while (true) {
        slow = nums[@intCast(slow)];
        fast = nums[@intCast(nums[@intCast(fast)])];
        if (slow == fast) break;
    }

    slow = nums[0];
    while (slow != fast) {
        slow = nums[@intCast(slow)];
        fast = nums[@intCast(fast)];
    }
    return slow;
}

pub fn main() !void {}

test "find duplicate - basic case" {
    const nums = [_]i32{ 1, 3, 4, 2, 2 };
    const expected: i32 = 2;
    const result = findDuplicate(&nums);
    try std.testing.expectEqual(expected, result);
}

test "find duplicate - another case" {
    const nums = [_]i32{ 3, 1, 3, 4, 2 };
    const expected: i32 = 3;
    const result = findDuplicate(&nums);
    try std.testing.expectEqual(expected, result);
}

test "find duplicate - minimum length" {
    const nums = [_]i32{ 1, 1 };
    const expected: i32 = 1;
    const result = findDuplicate(&nums);
    try std.testing.expectEqual(expected, result);
}

test "find duplicate - duplicate at end" {
    const nums = [_]i32{ 1, 2, 3, 4, 4 };
    const expected: i32 = 4;
    const result = findDuplicate(&nums);
    try std.testing.expectEqual(expected, result);
}

test "find duplicate - larger array" {
    const nums = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 5 };
    const expected: i32 = 5;
    const result = findDuplicate(&nums);
    try std.testing.expectEqual(expected, result);
}
