const std = @import("std");

fn twoSum(numbers: []const i32, target: i32) [2]usize {
    var left: usize = 0;
    var right: usize = numbers.len - 1;

    while (left < right) {
        const sum: i32 = numbers[left] + numbers[right];
        if (sum == target) {
            return [_]usize{ left + 1, right + 1 };
        } else if (sum < target) {
            left += 1;
        } else {
            right -= 1;
        }
    }
    unreachable;
}

pub fn main() !void {}

test "two sum II - basic case" {
    const numbers = [_]i32{ 2, 7, 11, 15 };
    const target: i32 = 9;
    const expected = [_]usize{ 1, 2 };
    const result = twoSum(&numbers, target);
    std.debug.print("Test 'basic case': numbers={any}, target={}, result={any}\n", .{ numbers, target, result });
    try std.testing.expectEqualSlices(usize, &expected, &result);
}

test "two sum II - three elements" {
    const numbers = [_]i32{ 2, 3, 4 };
    const target: i32 = 6;
    const expected = [_]usize{ 1, 3 };
    const result = twoSum(&numbers, target);
    std.debug.print("Test 'three elements': numbers={any}, target={}, result={any}\n", .{ numbers, target, result });
    try std.testing.expectEqualSlices(usize, &expected, &result);
}

test "two sum II - negative numbers" {
    const numbers = [_]i32{ -1, 0 };
    const target: i32 = -1;
    const expected = [_]usize{ 1, 2 };
    const result = twoSum(&numbers, target);
    std.debug.print("Test 'negative numbers': numbers={any}, target={}, result={any}\n", .{ numbers, target, result });
    try std.testing.expectEqualSlices(usize, &expected, &result);
}

test "two sum II - minimal length" {
    const numbers = [_]i32{ 1, 2 };
    const target: i32 = 3;
    const expected = [_]usize{ 1, 2 };
    const result = twoSum(&numbers, target);
    std.debug.print("Test 'minimal length': numbers={any}, target={}, result={any}\n", .{ numbers, target, result });
    try std.testing.expectEqualSlices(usize, &expected, &result);
}

test "two sum II - large numbers" {
    const numbers = [_]i32{ 100, 200, 300, 400 };
    const target: i32 = 500;
    const expected = [_]usize{ 1, 4 };
    const result = twoSum(&numbers, target);
    std.debug.print("Test 'large numbers': numbers={any}, target={}, result={any}\n", .{ numbers, target, result });
    try std.testing.expectEqualSlices(usize, &expected, &result);
}
