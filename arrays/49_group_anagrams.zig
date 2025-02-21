const std = @import("std");

fn sortString(str: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const sorted = try allocator.dupe(u8, str);
    std.sort.insertion(u8, sorted, {}, std.sort.asc(u8));
    return sorted;
}

fn groupAnagrams(strs: []const []const u8, allocator: std.mem.Allocator) ![][][]const u8 {
    var map = std.StringHashMap(std.ArrayList([]const u8)).init(allocator);
    defer {
        var it = map.valueIterator();
        while (it.next()) |list| {
            list.deinit();
        }
        map.deinit();
    }

    for (strs) |str| {
        const key = try sortString(str, allocator);
        const gop = try map.getOrPut(key);
        if (!gop.found_existing) {
            gop.value_ptr.* = std.ArrayList([]const u8).init(allocator);
        }
        try gop.value_ptr.append(str);
    }

    var result = std.ArrayList([][]const u8).init(allocator);
    var it = map.iterator();
    while (it.next()) |entry| {
        try result.append(try entry.value_ptr.toOwnedSlice());
    }
    return result.toOwnedSlice();
}

pub fn main() !void {
    std.debug.print("run zig test\n", .{});
}

test "group anagrams - basic case" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const strs = [_][]const u8{ "eat", "tea", "tan", "ate", "nat", "bat" };
    const result = try groupAnagrams(strs[0..], allocator);
    std.debug.print("Test 'basic case': strs={any}, result={any}\n", .{ strs, result });

    try std.testing.expect(result.len == 3);
    const expected_groups = [_][]const []const u8{
        &[_][]const u8{ "eat", "tea", "ate" },
        &[_][]const u8{ "tan", "nat" },
        &[_][]const u8{"bat"},
    };
    for (expected_groups) |group| {
        var found = false;
        for (result) |res_group| {
            if (res_group.len == group.len) {
                var all_match = true;
                for (group) |str| {
                    var in_group = false;
                    for (res_group) |res_str| {
                        if (std.mem.eql(u8, str, res_str)) in_group = true;
                    }
                    if (!in_group) all_match = false;
                }
                if (all_match) found = true;
            }
        }
        try std.testing.expect(found);
    }
}

test "group anagrams - single string" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const strs = [_][]const u8{"abc"};
    const result = try groupAnagrams(strs[0..], allocator);
    std.debug.print("Test 'single string': strs={any}, result={any}\n", .{ strs, result });

    try std.testing.expect(result.len == 1);
    try std.testing.expectEqualStrings("abc", result[0][0]);
}

test "group anagrams - empty array" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const strs = [_][]const u8{};
    const result = try groupAnagrams(strs[0..], allocator);
    std.debug.print("Test 'empty array': strs={any}, result={any}\n", .{ strs, result });

    try std.testing.expect(result.len == 0);
}
