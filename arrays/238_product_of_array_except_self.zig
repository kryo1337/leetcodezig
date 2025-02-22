const std = @import("std");

fn productExceptSelf(nums: []i32) []i32 {
    var result = std.heap.page_allocator.alloc(i32, nums.len) catch unreachable;

    var left: i32 = 1;
    var i: usize = 0;
    while (i < nums.len) : (i += 1) {
        result[i] = left;
        left *= nums[i];
    }

    var right: i32 = 1;
    var j: usize = nums.len;
    while (j > 0) : (j -= 1) {
        result[j - 1] *= right;
        right *= nums[j - 1];
    }

    return result;
}

pub fn main() !void {}

test "product except self - basic case" {
    var nums = [_]i32{ 1, 2, 3, 4 };
    var expected = [_]i32{ 24, 12, 8, 6 };
    const result = productExceptSelf(&nums);
    defer std.heap.page_allocator.free(result);
    std.debug.print("Test 'basic case': nums={any}, result={any}\n", .{ nums, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "product except self - with zeros" {
    var nums = [_]i32{ 1, 0, 3, 4 };
    var expected = [_]i32{ 0, 12, 0, 0 };
    const result = productExceptSelf(&nums);
    defer std.heap.page_allocator.free(result);
    std.debug.print("Test 'with zeros': nums={any}, result={any}\n", .{ nums, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "product except self - two elements" {
    var nums = [_]i32{ 2, 3 };
    var expected = [_]i32{ 3, 2 };
    const result = productExceptSelf(&nums);
    defer std.heap.page_allocator.free(result);
    std.debug.print("Test 'two elements': nums={any}, result={any}\n", .{ nums, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}

test "product except self - single element" {
    var nums = [_]i32{5};
    var expected = [_]i32{1};
    const result = productExceptSelf(&nums);
    defer std.heap.page_allocator.free(result);
    std.debug.print("Test 'single element': nums={any}, result={any}\n", .{ nums, result });
    try std.testing.expectEqualSlices(i32, &expected, result);
}
