const std = @import("std");

const Entry = struct {
    timestamp: i32,
    value: []const u8,
};

const TimeMap = struct {
    allocator: std.mem.Allocator,
    map: std.StringHashMap(std.ArrayList(Entry)),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) TimeMap {
        return TimeMap{
            .allocator = allocator,
            .map = std.StringHashMap(std.ArrayList(Entry)).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var iter = self.map.iterator();
        while (iter.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            for (entry.value_ptr.items) |e| {
                self.allocator.free(e.value);
            }
            entry.value_ptr.deinit();
        }
        self.map.deinit();
    }

    pub fn set(self: *Self, key: []const u8, value: []const u8, timestamp: i32) void {
        const key_dup = self.allocator.dupe(u8, key) catch return;
        const value_dup = self.allocator.dupe(u8, value) catch {
            self.allocator.free(key_dup);
            return;
        };

        var gop = self.map.getOrPut(key_dup) catch {
            self.allocator.free(key_dup);
            self.allocator.free(value_dup);
            return;
        };

        if (!gop.found_existing) {
            gop.value_ptr.* = std.ArrayList(Entry).init(self.allocator);
        } else {
            self.allocator.free(key_dup);
        }

        gop.value_ptr.append(Entry{
            .timestamp = timestamp,
            .value = value_dup,
        }) catch {
            if (!gop.found_existing) {
                _ = self.map.remove(key_dup);
                self.allocator.free(key_dup);
            }
            self.allocator.free(value_dup);
            return;
        };
    }

    pub fn get(self: *Self, key: []const u8, timestamp: i32) []const u8 {
        const entry_list = self.map.get(key) orelse return "";
        const items = entry_list.items;

        if (items.len == 0 or timestamp < items[0].timestamp) {
            return "";
        }

        var left: usize = 0;
        var right: usize = items.len;

        while (left < right) {
            const mid = left + (right - left) / 2;
            if (items[mid].timestamp <= timestamp) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return items[left - 1].value;
    }
};

pub fn main() !void {}  

test "time map - basic case" {
    var timeMap = TimeMap.init(std.testing.allocator);
    defer timeMap.deinit();

    timeMap.set("foo", "bar", 1);
    try std.testing.expectEqualStrings("bar", timeMap.get("foo", 1));
    try std.testing.expectEqualStrings("bar", timeMap.get("foo", 3));

    timeMap.set("foo", "bar2", 4);
    try std.testing.expectEqualStrings("bar2", timeMap.get("foo", 4));
    try std.testing.expectEqualStrings("bar2", timeMap.get("foo", 5));
}

test "time map - multiple keys" {
    var timeMap = TimeMap.init(std.testing.allocator);
    defer timeMap.deinit();

    timeMap.set("key1", "value1", 1);
    timeMap.set("key2", "value2", 2);
    try std.testing.expectEqualStrings("value1", timeMap.get("key1", 1));
    try std.testing.expectEqualStrings("value2", timeMap.get("key2", 2));
    try std.testing.expectEqualStrings("", timeMap.get("key1", 0));
    try std.testing.expectEqualStrings("", timeMap.get("key3", 3));
}

test "time map - multiple timestamps same key" {
    var timeMap = TimeMap.init(std.testing.allocator);
    defer timeMap.deinit();

    timeMap.set("key", "value1", 1);
    timeMap.set("key", "value2", 3);
    timeMap.set("key", "value3", 5);
    try std.testing.expectEqualStrings("value1", timeMap.get("key", 1));
    try std.testing.expectEqualStrings("value1", timeMap.get("key", 2));
    try std.testing.expectEqualStrings("value2", timeMap.get("key", 3));
    try std.testing.expectEqualStrings("value2", timeMap.get("key", 4));
    try std.testing.expectEqualStrings("value3", timeMap.get("key", 5));
    try std.testing.expectEqualStrings("value3", timeMap.get("key", 6));
}

test "time map - empty key" {
    var timeMap = TimeMap.init(std.testing.allocator);
    defer timeMap.deinit();

    timeMap.set("", "value", 1);
    try std.testing.expectEqualStrings("value", timeMap.get("", 1));
    try std.testing.expectEqualStrings("", timeMap.get("", 0));
}
