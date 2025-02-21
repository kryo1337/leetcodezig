const std = @import("std");

const Pair = struct {
    num: i32,
    count: usize,
};

fn pairComparator(_: void, a: Pair, b: Pair) bool {
    return a.count > b.count;
}

fn topKFrequent(nums: []i32, k: usize, allocator: std.mem.Allocator) ![]i32 {
    var map = std.AutoHashMap(i32, usize).init(allocator);
    defer map.deinit();

    for (nums) |num| {
        const entry = try map.getOrPut(num);
        if (!entry.found_existing) {
            entry.value_ptr.* = 0;
        }
        entry.value_ptr.* += 1;
    }

    var pairs = std.ArrayList(Pair).init(allocator);
    defer pairs.deinit();
    var it = map.iterator();
    while (it.next()) |entry| {
        try pairs.append(Pair{ .num = entry.key_ptr.*, .count = entry.value_ptr.* });
    }

    std.sort.pdq(Pair, pairs.items, {}, pairComparator);

    var result = std.ArrayList(i32).init(allocator);
    const n = if (k < pairs.items.len) k else pairs.items.len;
    for (pairs.items[0..n]) |pair| {
        try result.append(pair.num);
    }
    return result.toOwnedSlice();
}

pub fn main() !void {
    std.debug.print("run zig test\n", .{});
}

test "top k frequent - basic case" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var nums = [_]i32{ 1, 1, 1, 2, 2, 3 };
    const k: usize = 2;
    const result = try topKFrequent(nums[0..], k, allocator);
    std.debug.print("Test 'basic case': nums={any}, k={}, result={any}\n", .{ nums, k, result });
    try std.testing.expect(result.len == 2);
    const expected = [_]i32{ 1, 2 };
    for (expected) |val| {
        var found = false;
        for (result) |res| {
            if (res == val) found = true;
        }
        try std.testing.expect(found);
    }
}

test "top k frequent - single element" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var nums = [_]i32{1};
    const k: usize = 1;
    const result = try topKFrequent(nums[0..], k, allocator);
    std.debug.print("Test 'single element': nums={any}, k={}, result={any}\n", .{ nums, k, result });
    try std.testing.expect(result.len == 1);
    try std.testing.expectEqual(@as(i32, 1), result[0]);
}

test "top k frequent - all same" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var nums = [_]i32{ 5, 5, 5, 5 };
    const k: usize = 1;
    const result = try topKFrequent(nums[0..], k, allocator);
    std.debug.print("Test 'all same': nums={any}, k={}, result={any}\n", .{ nums, k, result });
    try std.testing.expect(result.len == 1);
    try std.testing.expectEqual(@as(i32, 5), result[0]);
}
