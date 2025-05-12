const std = @import("std");
const Allocator = std.mem.Allocator;

fn backtrack(
    nums: []const i32,
    start: usize,
    current: *std.ArrayList(i32),
    result: *std.ArrayList([]i32),
    allocator: Allocator,
) !void {
    const subset = try allocator.alloc(i32, current.items.len);
    std.mem.copyForwards(i32, subset, current.items);
    try result.append(subset);

    var i = start;
    while (i < nums.len) : (i += 1) {
        try current.append(nums[i]);
        try backtrack(nums, i + 1, current, result, allocator);
        _ = current.pop();
    }
}

pub fn subsets(nums: []const i32, allocator: Allocator) ![][]i32 {
    var result = std.ArrayList([]i32).init(allocator);
    defer result.deinit();
    var current = std.ArrayList(i32).init(allocator);
    defer current.deinit();

    try backtrack(nums, 0, &current, &result, allocator);
    return result.toOwnedSlice();
}

pub fn main() !void {}

test "subsets - basic case" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ 1, 2, 3 };
    const result = try subsets(&nums, allocator);
    defer {
        for (result) |subset| {
            allocator.free(subset);
        }
        allocator.free(result);
    }
    try std.testing.expectEqual(@as(usize, 8), result.len);
    const expected = [_][]const i32{
        &[_]i32{},
        &[_]i32{1},
        &[_]i32{1, 2},
        &[_]i32{1, 2, 3},
        &[_]i32{1, 3},
        &[_]i32{2},
        &[_]i32{2, 3},
        &[_]i32{3},
    };
    for (expected) |exp| {
        var found = false;
        for (result) |res| {
            if (std.mem.eql(i32, exp, res)) {
                found = true;
                break;
            }
        }
        try std.testing.expect(found);
    }
}

test "subsets - empty array" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{};
    const result = try subsets(&nums, allocator);
    defer {
        for (result) |subset| {
            allocator.free(subset);
        }
        allocator.free(result);
    }
    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(usize, 0), result[0].len);
}

test "subsets - single element" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{1};
    const result = try subsets(&nums, allocator);
    defer {
        for (result) |subset| {
            allocator.free(subset);
        }
        allocator.free(result);
    }
    try std.testing.expectEqual(@as(usize, 2), result.len);
    try std.testing.expectEqual(@as(usize, 0), result[0].len);
    try std.testing.expectEqual(@as(i32, 1), result[1][0]);
}