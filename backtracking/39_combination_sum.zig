const std = @import("std");
const Allocator = std.mem.Allocator;

fn backtrack(
    candidates: []const i32,
    target: i32,
    start: usize,
    current_sum: i32,
    current: *std.ArrayList(i32),
    result: *std.ArrayList([]i32),
    allocator: *Allocator,
) !void {
    if (current_sum == target) {
        const combination = try allocator.alloc(i32, current.items.len);
        std.mem.copyForwards(i32, combination, current.items);
        try result.append(combination);
        return;
    }

    if (current_sum > target) {
        return;
    }

    var i: usize = start;
    while (i < candidates.len) : (i += 1) {
        try current.append(candidates[i]);
        try backtrack(candidates, target, i, current_sum + candidates[i], current, result, allocator);
        _ = current.pop();
    }
}

pub fn combinationSum(candidates: []const i32, target: i32, allocator: *Allocator) ![][]i32 {
    var result = std.ArrayList([]i32).init(allocator);
    var current = std.ArrayList(i32).init(allocator);
    defer current.deinit();

    try backtrack(candidates, target, 0, 0, &current, &result, allocator);
    return result.toOwnedSlice();
}

pub fn main() !void {}

test "combination sum - basic case" {
    const allocator = std.testing.allocator;
    const candidates = [_]i32{ 2, 3, 6, 7 };
    const target: i32 = 7;
    const result = try combinationSum(&candidates, target, allocator);
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
        if (combo.len == 1 and combo[0] == 7) {
            found_combo2 = true;
        } else if (combo.len == 3 and combo[0] == 2 and combo[1] == 2 and combo[2] == 3) {
            found_combo1 = true;
        }
    }

    try std.testing.expect(found_combo1);
    try std.testing.expect(found_combo2);
}

test "combination sum - multiple combinations" {
    const allocator = std.testing.allocator;
    const candidates = [_]i32{ 2, 3, 5 };
    const target: i32 = 8;
    const result = try combinationSum(&candidates, target, allocator);
    defer {
        for (result) |combination| {
            allocator.free(combination);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 3), result.len);

    var found_combo1 = false;
    var found_combo2 = false;
    var found_combo3 = false;

    for (result) |combo| {
        if (combo.len == 4 and combo[0] == 2 and combo[1] == 2 and combo[2] == 2 and combo[3] == 2) {
            found_combo1 = true;
        } else if (combo.len == 3 and combo[0] == 2 and combo[1] == 3 and combo[2] == 3) {
            found_combo2 = true;
        } else if (combo.len == 2 and combo[0] == 3 and combo[1] == 5) {
            found_combo3 = true;
        }
    }

    try std.testing.expect(found_combo1);
    try std.testing.expect(found_combo2);
    try std.testing.expect(found_combo3);
}

test "combination sum - no solutions" {
    const allocator = std.testing.allocator;
    const candidates = [_]i32{ 2, 4, 6 };
    const target: i32 = 1;
    const result = try combinationSum(&candidates, target, allocator);
    defer {
        for (result) |combination| {
            allocator.free(combination);
        }
        allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 0), result.len);
}

