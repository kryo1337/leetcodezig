const std = @import("std");

const Allocator = std.mem.Allocator;

fn maxSlidingWindow(allocator: Allocator, nums: []const i32, k: i32) ![]i32 {
    const result_len = nums.len - @as(usize, @intCast(k)) + 1;
    var result = try allocator.alloc(i32, result_len);
    var left: usize = 0;
    var right: usize = @intCast(k - 1);
    var i: usize = 0;
    while (right < nums.len) {
        var max = nums[left];
        for (nums[left .. right + 1]) |num| {
            if (num > max) max = num;
        }
        result[i] = max;
        left += 1;
        right += 1;
        i += 1;
    }
    return result;
}

pub fn main() !void {}

test "sliding window maximum - basic case" {
    const nums = [_]i32{ 1, 3, -1, -3, 5, 3, 6, 7 };
    const k: i32 = 3;
    const expected = [_]i32{ 3, 3, 5, 5, 6, 7 };
    const result = try maxSlidingWindow(std.testing.allocator, &nums, k);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'basic case': nums={any}, k={}, result={any}\n", .{ nums, k, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "sliding window maximum - single element" {
    const nums = [_]i32{1};
    const k: i32 = 1;
    const expected = [_]i32{1};
    const result = try maxSlidingWindow(std.testing.allocator, &nums, k);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'single element': nums={any}, k={}, result={any}\n", .{ nums, k, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "sliding window maximum - all same values" {
    const nums = [_]i32{ 5, 5, 5, 5 };
    const k: i32 = 2;
    const expected = [_]i32{ 5, 5, 5 };
    const result = try maxSlidingWindow(std.testing.allocator, &nums, k);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'all same values': nums={any}, k={}, result={any}\n", .{ nums, k, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "sliding window maximum - decreasing sequence" {
    const nums = [_]i32{ 9, 8, 7, 6, 5 };
    const k: i32 = 3;
    const expected = [_]i32{ 9, 8, 7 };
    const result = try maxSlidingWindow(std.testing.allocator, &nums, k);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'decreasing sequence': nums={any}, k={}, result={any}\n", .{ nums, k, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "sliding window maximum - increasing sequence" {
    const nums = [_]i32{ 1, 2, 3, 4, 5 };
    const k: i32 = 3;
    const expected = [_]i32{ 3, 4, 5 };
    const result = try maxSlidingWindow(std.testing.allocator, &nums, k);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'increasing sequence': nums={any}, k={}, result={any}\n", .{ nums, k, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "sliding window maximum - window size equals array" {
    const nums = [_]i32{ 1, 2, 3 };
    const k: i32 = 3;
    const expected = [_]i32{3};
    const result = try maxSlidingWindow(std.testing.allocator, &nums, k);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'window size equals array': nums={any}, k={}, result={any}\n", .{ nums, k, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}
