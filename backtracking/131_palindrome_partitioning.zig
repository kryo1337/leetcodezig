const std = @import("std");
const Allocator = std.mem.Allocator;

fn isPalindrome(s: []const u8) bool {
    var left: usize = 0;
    var right: usize = s.len - 1;
    while (left < right) {
        if (s[left] != s[right]) return false;
        left += 1;
        right -= 1;
    }
    return true;
}

fn backtrack(
    s: []const u8,
    start: usize,
    current: *std.ArrayList([]const u8),
    result: *std.ArrayList([]const []const u8),
    allocator: Allocator,
) !void {
    if (start >= s.len) {
        const slice = try allocator.alloc([]const u8, current.items.len);
        for (current.items, 0..) |item, i| {
            slice[i] = item;
        }
        try result.append(slice);
        return;
    }

    var i: usize = start;
    while (i < s.len) : (i += 1) {
        const substr = s[start .. i + 1];
        if (isPalindrome(substr)) {
            try current.append(substr);
            try backtrack(s, i + 1, current, result, allocator);
            _ = current.pop();
        }
    }
}

pub fn partition(s: []const u8, allocator: Allocator) ![][]const []const u8 {
    var result = std.ArrayList([]const []const u8).init(allocator);
    var current = std.ArrayList([]const u8).init(allocator);
    defer current.deinit();

    try backtrack(s, 0, &current, &result, allocator);
    return result.toOwnedSlice();
}

pub fn main() !void {}

test "palindrome partitioning - basic case" {
    const s = "aab";
    const result = try partition(s, std.testing.allocator);
    defer {
        for (result) |partition_slice| {
            std.testing.allocator.free(partition_slice);
        }
        std.testing.allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 2), result.len);
}

test "palindrome partitioning - single character" {
    const s = "a";
    const result = try partition(s, std.testing.allocator);
    defer {
        for (result) |partition_slice| {
            std.testing.allocator.free(partition_slice);
        }
        std.testing.allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqualStrings("a", result[0][0]);
}

test "palindrome partitioning - empty string" {
    const s = "";
    const result = try partition(s, std.testing.allocator);
    defer {
        for (result) |partition_slice| {
            std.testing.allocator.free(partition_slice);
        }
        std.testing.allocator.free(result);
    }

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(usize, 0), result[0].len);
}

