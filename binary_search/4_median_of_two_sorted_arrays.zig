const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn findMedianSortedArrays(allocator: Allocator, nums1: []const i32, nums2: []const i32) !f64 {
    if (nums1.len > nums2.len) {
        return findMedianSortedArrays(allocator, nums2, nums1);
    }

    var low: usize = 0;
    var high: usize = nums1.len;
    while (low <= high) {
        const partition1 = (low + high) / 2;
        const partition2 = (nums1.len + nums2.len + 1) / 2 - partition1;

        const maxLeft1 = if (partition1 == 0) std.math.minInt(i32) else nums1[partition1 - 1];
        const minRight1 = if (partition1 == nums1.len) std.math.maxInt(i32) else nums1[partition1];
        
        const maxLeft2 = if (partition2 == 0) std.math.minInt(i32) else nums2[partition2 - 1];
        const minRight2 = if (partition2 == nums2.len) std.math.maxInt(i32) else nums2[partition2];

        if (maxLeft1 <= minRight2 and maxLeft2 <= minRight1) {
            if ((nums1.len + nums2.len) % 2 == 0) {
                const left = @max(maxLeft1, maxLeft2);
                const right = @min(minRight1, minRight2);
                return (@as(f64, @floatFromInt(left)) + @as(f64, @floatFromInt(right))) / 2.0;
            } else {
                return @floatFromInt(@max(maxLeft1, maxLeft2));
            }
        } else if (maxLeft1 > minRight2) {
            high = partition1 - 1;
        } else {
            low = partition1 + 1;
        }
    }
    return 0.0; 
}

pub fn main() !void {}

test "median of two sorted arrays - both arrays non-empty" {
    try std.testing.expectEqual(@as(f64, 2.0), findMedianSortedArrays(std.testing.allocator, &[_]i32{1, 3}, &[_]i32{2}));
    try std.testing.expectEqual(@as(f64, 2.5), findMedianSortedArrays(std.testing.allocator, &[_]i32{1, 2}, &[_]i32{3, 4}));
    try std.testing.expectEqual(@as(f64, 5.5), findMedianSortedArrays(std.testing.allocator, &[_]i32{1, 2, 3, 4, 5}, &[_]i32{6, 7, 8, 9, 10}));
}

test "median of two sorted arrays - one array empty" {
    try std.testing.expectEqual(@as(f64, 2.0), findMedianSortedArrays(std.testing.allocator, &[_]i32{}, &[_]i32{2}));
    try std.testing.expectEqual(@as(f64, 3.0), findMedianSortedArrays(std.testing.allocator, &[_]i32{3}, &[_]i32{}));
    try std.testing.expectEqual(@as(f64, 2.5), findMedianSortedArrays(std.testing.allocator, &[_]i32{}, &[_]i32{1, 2, 3, 4}));
}

test "median of two sorted arrays - same elements" {
    try std.testing.expectEqual(@as(f64, 1.0), findMedianSortedArrays(std.testing.allocator, &[_]i32{1, 1}, &[_]i32{1, 1}));
    try std.testing.expectEqual(@as(f64, 2.0), findMedianSortedArrays(std.testing.allocator, &[_]i32{2}, &[_]i32{2}));
}

test "median of two sorted arrays - interleaved elements" {
    try std.testing.expectEqual(@as(f64, 4.5), findMedianSortedArrays(std.testing.allocator, &[_]i32{1, 3, 5, 7}, &[_]i32{2, 4, 6, 8}));
    try std.testing.expectEqual(@as(f64, 5.0), findMedianSortedArrays(std.testing.allocator, &[_]i32{1, 3, 5, 7, 9}, &[_]i32{2, 4, 6, 8}));
}
