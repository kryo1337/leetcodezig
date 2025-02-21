const std = @import("std");

fn containsDuplicate(nums: []i32) bool {
    var map = std.AutoHashMap(i32, void).init(std.heap.page_allocator);
    defer map.deinit();

    for (nums) |num| {
        if (map.contains(num)) {
            return true;
        }
        map.put(num, {}) catch unreachable;
    }
    return false;
}

pub fn main() !void {}

test "contains duplicate - has duplicate" {
    var nums = [_]i32{ 1, 2, 3, 1 };
    const result = containsDuplicate(&nums);
    std.debug.print("Test 'has duplicate': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expect(result == true);
}

test "contains duplicate - no duplicate" {
    var nums = [_]i32{ 1, 2, 3, 4 };
    const result = containsDuplicate(&nums);
    std.debug.print("Test 'no duplicate': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expect(result == false);
}

test "contains duplicate - empty array" {
    var nums = [_]i32{};
    const result = containsDuplicate(&nums);
    std.debug.print("Test 'empty array': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expect(result == false);
}

test "contains duplicate - single element" {
    var nums = [_]i32{1};
    const result = containsDuplicate(&nums);
    std.debug.print("Test 'single element': nums={any}, result={}\n", .{ nums, result });
    try std.testing.expect(result == false);
}
