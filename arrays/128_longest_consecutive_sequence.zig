const std = @import("std");
const Allocator = std.mem.Allocator;

fn longestConsecutive(allocator: Allocator, nums: []i32) i32 {
    if (nums.len == 0) return 0;

    var map = std.AutoHashMap(i32, void).init(allocator);
    defer map.deinit();

    for (nums) |num| {
        map.put(num, {}) catch unreachable;
    }

    var max: i32 = 0;
    for (nums) |num| {
        if (!map.contains(num - 1)) {
            var current = num;
            var length: i32 = 1;
            while (map.contains(current + 1)) {
                current += 1;
                length += 1;
            }
            max = @max(max, length);
        }
    }

    return max;
}

pub fn main() !void {}

test "longest consecutive sequence - basic case" {
    var nums = [_]i32{ 100, 4, 200, 1, 3, 2 };
    const result = longestConsecutive(std.testing.allocator, &nums);
    std.debug.print("Test 'basic case': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expect(result == 4);
}

test "longest consecutive sequence - no sequence" {
    var nums = [_]i32{ 1, 3, 5, 7 };
    const result = longestConsecutive(std.testing.allocator, &nums);
    std.debug.print("Test 'no sequence': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expect(result == 1);
}

test "longest consecutive sequence - empty array" {
    var nums = [_]i32{};
    const result = longestConsecutive(std.testing.allocator, &nums);
    std.debug.print("Test 'empty array': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expect(result == 0);
}

test "longest consecutive sequence - all consecutive" {
    var nums = [_]i32{ 1, 2, 3, 4, 5 };
    const result = longestConsecutive(std.testing.allocator, &nums);
    std.debug.print("Test 'all consecutive': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expect(result == 5);
}
