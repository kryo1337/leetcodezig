const std = @import("std");
const Allocator = std.mem.Allocator;

fn backtrack(
    nums: []const i32,
    current: *std.ArrayList(i32),
    result: *std.ArrayList([]i32),
    allocator: Allocator,
) !void {
    if (current.items.len == nums.len) {
        const permutation = try allocator.alloc(i32, current.items.len);
        std.mem.copyForwards(i32, permutation, current.items);
        try result.append(permutation);
        return;
    }

    for (nums) |num| {
        if (contains(current.items, num)) continue;
        try current.append(num);
        try backtrack(nums, current, result, allocator);
        _ = current.pop();
    }
}

fn contains(arr: []const i32, target: i32) bool {
    for (arr) |num| {
        if (num == target) return true;
    }
    return false;
}

pub fn permute(nums: []const i32, allocator: Allocator) ![][]i32 {
    var result = std.ArrayList([]i32).init(allocator);
    var current = std.ArrayList(i32).init(allocator);
    defer current.deinit();

    try backtrack(nums, &current, &result, allocator);
    return result.toOwnedSlice();
}

pub fn main() !void {}

test "permutations - basic case" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ 1, 2, 3 };
    const result = try permute(&nums, allocator);
    defer {
        for (result) |perm| {
            allocator.free(perm);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 6), result.len);

    var found_perm1 = false;
    var found_perm2 = false;
    var found_perm3 = false;
    var found_perm4 = false;
    var found_perm5 = false;
    var found_perm6 = false;

    for (result) |perm| {
        if (perm.len == 3 and perm[0] == 1 and perm[1] == 2 and perm[2] == 3) {
            found_perm1 = true;
        } else if (perm.len == 3 and perm[0] == 1 and perm[1] == 3 and perm[2] == 2) {
            found_perm2 = true;
        } else if (perm.len == 3 and perm[0] == 2 and perm[1] == 1 and perm[2] == 3) {
            found_perm3 = true;
        } else if (perm.len == 3 and perm[0] == 2 and perm[1] == 3 and perm[2] == 1) {
            found_perm4 = true;
        } else if (perm.len == 3 and perm[0] == 3 and perm[1] == 1 and perm[2] == 2) {
            found_perm5 = true;
        } else if (perm.len == 3 and perm[0] == 3 and perm[1] == 2 and perm[2] == 1) {
            found_perm6 = true;
        }
    }

    try std.testing.expect(found_perm1);
    try std.testing.expect(found_perm2);
    try std.testing.expect(found_perm3);
    try std.testing.expect(found_perm4);
    try std.testing.expect(found_perm5);
    try std.testing.expect(found_perm6);
}

test "permutations - single element" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{1};
    const result = try permute(&nums, allocator);
    defer {
        for (result) |perm| {
            allocator.free(perm);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(i32, 1), result[0][0]);
}

test "permutations - two elements" {
    const allocator = std.testing.allocator;
    const nums = [_]i32{ 0, 1 };
    const result = try permute(&nums, allocator);
    defer {
        for (result) |perm| {
            allocator.free(perm);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 2), result.len);

    var found_perm1 = false;
    var found_perm2 = false;

    for (result) |perm| {
        if (perm.len == 2 and perm[0] == 0 and perm[1] == 1) {
            found_perm1 = true;
        } else if (perm.len == 2 and perm[0] == 1 and perm[1] == 0) {
            found_perm2 = true;
        }
    }

    try std.testing.expect(found_perm1);
    try std.testing.expect(found_perm2);
}

