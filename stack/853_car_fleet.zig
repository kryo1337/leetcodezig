const std = @import("std");
const Allocator = std.mem.Allocator;

fn carFleet(allocator: Allocator, target: i32, position: []const i32, speed: []const i32) !i32 {
    var pairs = std.AutoHashMap(i32, i32).init(allocator);
    defer pairs.deinit();
    for (position, speed) |p, s| {
        pairs.put(p, s) catch unreachable;
    }

    var pos = std.ArrayList(i32).init(allocator);
    defer pos.deinit();
    var iter = pairs.keyIterator();
    while (iter.next()) |key| {
        pos.append(key.*) catch unreachable;
    }
    std.sort.pdq(i32, pos.items, {}, compare);

    var stack = std.ArrayList(i32).init(allocator);
    defer stack.deinit();

    for (pos.items) |p| {
        const s = pairs.get(p).?;
        const time = @divTrunc(target - p, s);
        if (stack.items.len == 0 or time > stack.items[stack.items.len - 1]) {
            try stack.append(time);
        }
    }
    return @intCast(stack.items.len);
}

fn compare(_: void, a: i32, b: i32) bool {
    return a > b;
}

pub fn main() !void {}

test "car fleet - basic case" {
    const target: i32 = 12;
    const position = [_]i32{ 10, 8, 0, 5, 3 };
    const speed = [_]i32{ 2, 4, 1, 1, 3 };
    const expected: i32 = 3;
    const result = try carFleet(std.testing.allocator, target, &position, &speed);
    std.debug.print("Test 'basic case': position={any}, speed={any}, result={}\n", .{ position, speed, result });
    try std.testing.expectEqual(expected, result);
}

test "car fleet - single car" {
    const target: i32 = 10;
    const position = [_]i32{3};
    const speed = [_]i32{3};
    const expected: i32 = 1;
    const result = try carFleet(std.testing.allocator, target, &position, &speed);
    std.debug.print("Test 'single car': position={any}, speed={any}, result={}\n", .{ position, speed, result });
    try std.testing.expectEqual(expected, result);
}

test "car fleet - all arrive together" {
    const target: i32 = 100;
    const position = [_]i32{ 0, 2, 4 };
    const speed = [_]i32{ 4, 2, 1 };
    const expected: i32 = 1;
    const result = try carFleet(std.testing.allocator, target, &position, &speed);
    std.debug.print("Test 'all arrive together': position={any}, speed={any}, result={}\n", .{ position, speed, result });
    try std.testing.expectEqual(expected, result);
}

test "car fleet - same position different speeds" {
    const target: i32 = 10;
    const position = [_]i32{ 5, 5, 5 };
    const speed = [_]i32{ 3, 2, 1 };
    const expected: i32 = 1;
    const result = try carFleet(std.testing.allocator, target, &position, &speed);
    std.debug.print("Test 'same position different speeds': position={any}, speed={any}, result={}\n", .{ position, speed, result });
    try std.testing.expectEqual(expected, result);
}
