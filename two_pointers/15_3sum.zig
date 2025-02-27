const std = @import("std");
const Allocator = std.mem.Allocator;

fn threeSum(allocator: Allocator, nums: []const i32) ![][3]i32 {
    var result = std.ArrayList([3]i32).init(allocator);

    if (nums.len < 3) return result.toOwnedSlice();

    const sorted = try allocator.dupe(i32, nums);
    defer allocator.free(sorted);
    std.sort.pdq(i32, sorted, {}, std.sort.asc(i32));

    for (sorted, 0..) |num, i| {
        if (i > 0 and num == sorted[i - 1]) continue;
        var left: usize = i + 1;
        var right: usize = sorted.len - 1;
        while (left < right) {
            const sum = num + sorted[left] + sorted[right];
            if (sum == 0) {
                try result.append([3]i32{ num, sorted[left], sorted[right] });

                while (left < right and sorted[left] == sorted[left + 1]) left += 1;
                while (left < right and sorted[right] == sorted[right - 1]) right -= 1;
                left += 1;
                right -= 1;
            } else if (sum < 0) {
                left += 1;
            } else {
                right -= 1;
            }
        }
    }

    return result.toOwnedSlice();
}

pub fn main() !void {}

test "3sum - basic case" {
    const nums = [_]i32{ -1, 0, 1, 2, -1, -4 };
    const expected = [_][3]i32{
        [3]i32{ -1, -1, 2 },
        [3]i32{ -1, 0, 1 },
    };
    const result = try threeSum(std.testing.allocator, &nums);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'basic case': nums={any}, result={any}\n", .{ nums, result });
    try std.testing.expectEqual(expected.len, result.len);
}

test "3sum - no triplets" {
    const nums = [_]i32{ 0, 1, 1 };
    const expected = [_][3]i32{};
    const result = try threeSum(std.testing.allocator, &nums);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'no triplets': nums={any}, result={any}\n", .{ nums, result });
    try std.testing.expectEqualSlices([3]i32, &expected, result);
}

test "3sum - all zeros" {
    const nums = [_]i32{ 0, 0, 0 };
    const expected = [_][3]i32{[3]i32{ 0, 0, 0 }};
    const result = try threeSum(std.testing.allocator, &nums);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'all zeros': nums={any}, result={any}\n", .{ nums, result });
    try std.testing.expectEqualSlices([3]i32, &expected, result);
}

test "3sum - empty array" {
    const nums = [_]i32{};
    const expected = [_][3]i32{};
    const result = try threeSum(std.testing.allocator, &nums);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'empty array': nums={any}, result={any}\n", .{ nums, result });
    try std.testing.expectEqualSlices([3]i32, &expected, result);
}

test "3sum - single triplet" {
    const nums = [_]i32{ -2, 0, 2 };
    const expected = [_][3]i32{[3]i32{ -2, 0, 2 }};
    const result = try threeSum(std.testing.allocator, &nums);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'single triplet': nums={any}, result={any}\n", .{ nums, result });
    try std.testing.expectEqualSlices([3]i32, &expected, result);
}
