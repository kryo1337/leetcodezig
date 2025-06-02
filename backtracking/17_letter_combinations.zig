const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn letterCombinations(digits: []const u8, allocator: Allocator) ![][]const u8 {
    if (digits.len == 0) return &[_][]const u8{};

    const digit_map = [_][]const u8{
        "", // 0
        "", // 1
        "abc", // 2
        "def", // 3
        "ghi", // 4
        "jkl", // 5
        "mno", // 6
        "pqrs", // 7
        "tuv", // 8
        "wxyz", // 9
    };

    var result = std.ArrayList([]const u8).init(allocator);
    var current = std.ArrayList(u8).init(allocator);
    defer current.deinit();

    try backtrack(&result, &current, digits, &digit_map, 0, allocator);
    return result.toOwnedSlice();
}

fn backtrack(
    result: *std.ArrayList([]const u8),
    current: *std.ArrayList(u8),
    digits: []const u8,
    digit_map: []const []const u8,
    index: usize,
    allocator: Allocator,
) !void {
    if (index == digits.len) {
        const combination = try allocator.dupe(u8, current.items);
        try result.append(combination);
        return;
    }

    const digit = digits[index] - '0';
    const letters = digit_map[digit];

    for (letters) |letter| {
        try current.append(letter);
        try backtrack(result, current, digits, digit_map, index + 1, allocator);
        _ = current.pop();
    }
}

pub fn main() !void {}

test "letter combinations - basic case" {
    const digits = "23";
    const result = try letterCombinations(digits, std.testing.allocator);
    defer {
        for (result) |combination| {
            std.testing.allocator.free(combination);
        }
        std.testing.allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 9), result.len);
}

test "letter combinations - empty input" {
    const digits = "";
    const result = try letterCombinations(digits, std.testing.allocator);
    defer {
        for (result) |combination| {
            std.testing.allocator.free(combination);
        }
        std.testing.allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "letter combinations - single digit" {
    const digits = "2";
    const result = try letterCombinations(digits, std.testing.allocator);
    defer {
        for (result) |combination| {
            std.testing.allocator.free(combination);
        }
        std.testing.allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 3), result.len);
}

