const std = @import("std");
const Allocator = std.mem.Allocator;

const Task = struct {
    freq: i32,
    task: u8,
};

fn compare(context: void, a: Task, b: Task) std.math.Order {
    _ = context;
    return std.math.order(b.freq, a.freq);
}

pub fn leastInterval(tasks: []const u8, n: i32, allocator: Allocator) i32 {
    var freq = std.AutoHashMap(u8, i32).init(allocator);
    defer freq.deinit();
    for (tasks) |task| {
        const gop = freq.getOrPut(task) catch unreachable;
        if (gop.found_existing) {
            gop.value_ptr.* += 1;
        } else {
            gop.value_ptr.* = 1;
        }
    }

    var heap = std.PriorityQueue(Task, void, compare).init(allocator, {});
    defer heap.deinit();
    var it = freq.iterator();
    while (it.next()) |entry| {
        heap.add(.{ .freq = entry.value_ptr.*, .task = entry.key_ptr.* }) catch unreachable;
    }

    var time: i32 = 0;
    while (heap.count() > 0) {
        var count: i32 = 0;
        var t = std.ArrayList(Task).init(allocator);
        defer t.deinit();
        while (count < n + 1 and heap.count() > 0) {
            const task = heap.remove();
            t.append(task) catch unreachable;
            count += 1;
        }
        for (t.items) |task| {
            if (task.freq > 1) {
                heap.add(.{ .freq = task.freq - 1, .task = task.task }) catch unreachable;
            }
        }
        time += if (heap.count() > 0) n + 1 else count;
    }
    return time;
}

pub fn main() !void {}

test "task scheduler - example 1" {
    const allocator = std.testing.allocator;
    const tasks = "AAABBB";
    const n: i32 = 2;
    const result = leastInterval(tasks, n, allocator);
    try std.testing.expectEqual(@as(i32, 8), result);
}

test "task scheduler - no cooling" {
    const allocator = std.testing.allocator;
    const tasks = "AAABBB";
    const n: i32 = 0;
    const result = leastInterval(tasks, n, allocator);
    try std.testing.expectEqual(@as(i32, 6), result);
}

test "task scheduler - complex case" {
    const allocator = std.testing.allocator;
    const tasks = "AAAAAABCDEFG";
    const n: i32 = 2;
    const result = leastInterval(tasks, n, allocator);
    try std.testing.expectEqual(@as(i32, 16), result);
}

test "task scheduler - empty array" {
    const allocator = std.testing.allocator;
    const tasks = "";
    const n: i32 = 2;
    const result = leastInterval(tasks, n, allocator);
    try std.testing.expectEqual(@as(i32, 0), result);
}

test "task scheduler - single task" {
    const allocator = std.testing.allocator;
    const tasks = "A";
    const n: i32 = 3;
    const result = leastInterval(tasks, n, allocator);
    try std.testing.expectEqual(@as(i32, 1), result);
}