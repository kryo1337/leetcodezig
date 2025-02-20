const std = @import("std");

fn twoSum(nums: []i32, target: i32) ?[2]usize {
    var map = std.AutoHashMap(i32, usize).init(std.heap.page_allocator);
    defer map.deinit();

    for (nums, 0..) |num, i| {
        const comp = target - num;
        if (map.get(comp)) |j| {
            return [2]usize{ j, i };
        }
        map.put(num, i) catch unreachable;
    }
    return null;
}

pub fn main() !void {
    std.debug.print("run zig test", .{});
}

test "two sum - basic case" {
    var nums = [_]i32{ 2, 7, 11, 15 };
    const target = 9;
    const result = twoSum(&nums, target);
    std.debug.print("Test 'basic case': nums={any}, target={}, result={any}\n", .{ nums, target, result });
    try std.testing.expectEqual([2]usize{ 0, 1 }, result.?);
}

test "two sum - negative numbers" {
    var nums = [_]i32{ -3, 4, 3, 90 };
    const target = 0;
    const result = twoSum(&nums, target);
    std.debug.print("Test 'negative numbers': nums={any}, target={}, result={any}\n", .{ nums, target, result });
    try std.testing.expectEqual([2]usize{ 0, 2 }, result.?);
}

test "two sum - small array" {
    var nums = [_]i32{ 3, 2 };
    const target = 5;
    const result = twoSum(&nums, target);
    std.debug.print("Test 'small array': nums={any}, target={}, result={any}\n", .{ nums, target, result });
    try std.testing.expectEqual([2]usize{ 0, 1 }, result.?);
}
