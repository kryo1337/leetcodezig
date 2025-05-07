const std = @import("std");
const Allocator = std.mem.Allocator;

fn kClosest(points: []const [2]i32, k: i32, allocator: Allocator) ![][2]i32 {
    var heap = std.PriorityQueue([2]i32, void, compare).init(allocator, {});
    defer heap.deinit();

    for (points) |point| {
        try heap.add(point);
        if (heap.count() > @as(usize, @intCast(k))) {
            _ = heap.remove();
        }
    }
    const result = try allocator.alloc([2]i32, @as(usize, @intCast(k)));
    var i: usize = 0;
    while (heap.count() > 0) : (i += 1) {
        result[@as(usize, @intCast(k)) - 1 - i] = heap.remove();
    }
    return result;
}

fn compare(_: void, a: [2]i32, b: [2]i32) std.math.Order {
    const dist_a: i64 = @as(i64, a[0]) * @as(i64, a[0]) + @as(i64, a[1]) * @as(i64, a[1]);
    const dist_b: i64 = @as(i64, b[0]) * @as(i64, b[0]) + @as(i64, b[1]) * @as(i64, b[1]);
    return std.math.order(dist_b, dist_a);
}

pub fn main() !void {}

test "k closest - example 1" {
    const allocator = std.testing.allocator;
    const points = [_][2]i32{ [2]i32{ 1, 3 }, [2]i32{ -2, 2 } };
    const k: i32 = 1;
    const result = try kClosest(&points, k, allocator);
    defer allocator.free(result);

    const expected = [_][2]i32{[2]i32{ -2, 2 }};
    try std.testing.expectEqualSlices([2]i32, &expected, result);
}

test "k closest - example 2" {
    const allocator = std.testing.allocator;
    const points = [_][2]i32{ [2]i32{ 3, 3 }, [2]i32{ 5, -1 }, [2]i32{ -2, 4 } };
    const k: i32 = 2;
    const result = try kClosest(&points, k, allocator);
    defer allocator.free(result);

    const expected = [_][2]i32{ [2]i32{ 3, 3 }, [2]i32{ -2, 4 } };
    try std.testing.expectEqualSlices([2]i32, &expected, result);
}

test "k closest - single point" {
    const allocator = std.testing.allocator;
    const points = [_][2]i32{[2]i32{ 1, 1 }};
    const k: i32 = 1;
    const result = try kClosest(&points, k, allocator);
    defer allocator.free(result);

    const expected = [_][2]i32{[2]i32{ 1, 1 }};
    try std.testing.expectEqualSlices([2]i32, &expected, result);
}

test "k closest - k equals points length" {
    const allocator = std.testing.allocator;
    const points = [_][2]i32{ [2]i32{ 1, 1 }, [2]i32{ 2, 2 } };
    const k: i32 = 2;
    const result = try kClosest(&points, k, allocator);
    defer allocator.free(result);

    const expected = [_][2]i32{ [2]i32{ 1, 1 }, [2]i32{ 2, 2 } };
    try std.testing.expectEqualSlices([2]i32, &expected, result);
}
