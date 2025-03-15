const std = @import("std");
const Allocator = std.mem.Allocator;

fn dailyTemperatures(allocator: Allocator, temperatures: []const i32) ![]i32 {
    const result = try allocator.alloc(i32, temperatures.len);
    @memset(result, 0);

    var stack = std.ArrayList(usize).init(allocator);
    defer stack.deinit();

    for (temperatures, 0..) |temp, i| {
        while (stack.items.len > 0 and temp > temperatures[stack.items[stack.items.len - 1]]) {
            const prev = stack.pop();
            result[prev] = @intCast(i - prev);
        }
        try stack.append(i);
    }

    return result;
}

pub fn main() !void {}

test "daily temperatures - basic case" {
    const temps = [_]i32{ 73, 74, 75, 71, 69, 72, 76, 73 };
    const expected = [_]i32{ 1, 1, 4, 2, 1, 1, 0, 0 };
    const result = try dailyTemperatures(std.testing.allocator, &temps);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'basic case': temps={any}, result={any}\n", .{ temps, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "daily temperatures - increasing" {
    const temps = [_]i32{ 30, 40, 50, 60 };
    const expected = [_]i32{ 1, 1, 1, 0 };
    const result = try dailyTemperatures(std.testing.allocator, &temps);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'increasing': temps={any}, result={any}\n", .{ temps, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "daily temperatures - decreasing" {
    const temps = [_]i32{ 60, 50, 40, 30 };
    const expected = [_]i32{ 0, 0, 0, 0 };
    const result = try dailyTemperatures(std.testing.allocator, &temps);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'decreasing': temps={any}, result={any}\n", .{ temps, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "daily temperatures - single day" {
    const temps = [_]i32{55};
    const expected = [_]i32{0};
    const result = try dailyTemperatures(std.testing.allocator, &temps);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'single day': temps={any}, result={any}\n", .{ temps, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "daily temperatures - all same" {
    const temps = [_]i32{ 70, 70, 70, 70 };
    const expected = [_]i32{ 0, 0, 0, 0 };
    const result = try dailyTemperatures(std.testing.allocator, &temps);
    defer std.testing.allocator.free(result);
    std.debug.print("Test 'all same': temps={any}, result={any}\n", .{ temps, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}
