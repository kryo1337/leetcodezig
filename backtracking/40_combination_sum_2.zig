const std = @import("std");
const Allocator = std.mem.Allocator;

fn backtrack(
    candidates: []const i32,
    target: i32,
    start: usize,
    current_sum: i32,
    current: *std.ArrayList(i32),
    result: *std.ArrayList([]i32),
    allocator: Allocator,
) !void {
    if (current_sum == target) {
        const combination = try allocator.alloc(i32, current.items.len);
        std.mem.copyForwards(i32, combination, current.items);
        try result.append(combination);
        return;
    }

    if (current_sum > target) return;

    var i: usize = start;
    while (i < candidates.len) : (i += 1) {
        if (i > start and candidates[i] == candidates[i - 1]) continue;
        try current.append(candidates[i]);
        try backtrack(candidates, target, i + 1, current_sum + candidates[i], current, result, allocator);
        _ = current.pop();
    }
}

pub fn combinationSum2(candidates: []const i32, target: i32, allocator: Allocator) ![][]i32 {
    const sorted = try allocator.alloc(i32, candidates.len);
    defer allocator.free(sorted);
    std.mem.copyForwards(i32, sorted, candidates);
    std.sort.insertion(i32, sorted, {}, std.sort.asc(i32));

    var result = std.ArrayList([]i32).init(allocator);
    var current = std.ArrayList(i32).init(allocator);
    defer current.deinit();

    try backtrack(sorted, target, 0, 0, &current, &result, allocator);
    return result.toOwnedSlice();
}

pub fn main() !void {}

test "combination sum 2 - basic case" {
    const allocator = std.testing.allocator;
    const candidates = [_]i32{ 10, 1, 2, 7, 6, 1, 5 };
    const target: i32 = 8;
    const result = try combinationSum2(&candidates, target, allocator);
    defer {
        for (result) |combination| {
            allocator.free(combination);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 4), result.len);

    var found_combo1 = false;
    var found_combo2 = false;
    var found_combo3 = false;
    var found_combo4 = false;

    for (result) |combo| {
        if (combo.len == 3 and combo[0] == 1 and combo[1] == 1 and combo[2] == 6) {
            found_combo1 = true;
        } else if (combo.len == 3 and combo[0] == 1 and combo[1] == 2 and combo[2] == 5) {
            found_combo2 = true;
        } else if (combo.len == 2 and combo[0] == 1 and combo[1] == 7) {
            found_combo3 = true;
        } else if (combo.len == 2 and combo[0] == 2 and combo[1] == 6) {
            found_combo4 = true;
        }
    }

    try std.testing.expect(found_combo1);
    try std.testing.expect(found_combo2);
    try std.testing.expect(found_combo3);
    try std.testing.expect(found_combo4);
}

test "combination sum 2 - duplicates" {
    const allocator = std.testing.allocator;
    const candidates = [_]i32{ 2, 5, 2, 1, 2 };
    const target: i32 = 5;
    const result = try combinationSum2(&candidates, target, allocator);
    defer {
        for (result) |combination| {
            allocator.free(combination);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 2), result.len);

    var found_combo1 = false;
    var found_combo2 = false;

    for (result) |combo| {
        if (combo.len == 3 and combo[0] == 1 and combo[1] == 2 and combo[2] == 2) {
            found_combo1 = true;
        } else if (combo.len == 1 and combo[0] == 5) {
            found_combo2 = true;
        }
    }

    try std.testing.expect(found_combo1);
    try std.testing.expect(found_combo2);
}

test "combination sum 2 - no solutions" {
    const allocator = std.testing.allocator;
    const candidates = [_]i32{ 1, 2, 3 };
    const target: i32 = 10;
    const result = try combinationSum2(&candidates, target, allocator);
    defer {
        for (result) |combination| {
            allocator.free(combination);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 0), result.len);
}



