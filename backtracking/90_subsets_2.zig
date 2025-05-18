const std = @import("std");
const Allocator = std.mem.Allocator;

fn backtrack(nums: []i32, start: usize, current: *std.ArrayList(i32), result: *std.ArrayList([]i32), allocator: Allocator) !void {
    const subset = try allocator.alloc(i32, current.items.len);
    std.mem.copyForwards(i32, subset, current.items);
    try result.append(subset);

    var i: usize = start;
    while (i < nums.len) : (i += 1) {
        if (i > start and nums[i] == nums[i - 1]) continue;

        try current.append(nums[i]);
        try backtrack(nums, i + 1, current, result, allocator);
        _ = current.pop();
    }
}

pub fn subsetsWithDup(nums: []const i32, allocator: Allocator) ![][]i32 {
    const sorted = try allocator.alloc(i32, nums.len);
    defer allocator.free(sorted);
    std.mem.copyForwards(i32, sorted, nums);
    std.sort.insertion(i32, sorted, {}, std.sort.asc(i32));

    var result = std.ArrayList([]i32).init(allocator);
    var current = std.ArrayList(i32).init(allocator);
    defer current.deinit();

    try backtrack(sorted, 0, &current, &result, allocator);
    return result.toOwnedSlice();
}

pub fn main() !void {}

test "subsets II - basic case" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ 1, 2, 2 };
    const result = try subsetsWithDup(&nums, allocator);
    defer {
        for (result) |subset| {
            allocator.free(subset);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 6), result.len);
}

test "subsets II - empty array" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{};
    const result = try subsetsWithDup(&nums, allocator);
    defer {
        for (result) |subset| {
            allocator.free(subset);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(usize, 0), result[0].len);
}

test "subsets II - single element" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{0};
    const result = try subsetsWithDup(&nums, allocator);
    defer {
        for (result) |subset| {
            allocator.free(subset);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 2), result.len);
}

test "subsets II - multiple duplicates" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ 1, 1, 2, 2 };
    const result = try subsetsWithDup(&nums, allocator);
    defer {
        for (result) |subset| {
            allocator.free(subset);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 9), result.len);
}

