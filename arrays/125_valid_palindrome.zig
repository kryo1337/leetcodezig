const std = @import("std");

fn isPalindrome(s: []const u8) bool {
    if (s.len == 0) return true;

    var left: usize = 0;
    var right: usize = s.len - 1;

    while (left < right) {
        while (left < right and !std.ascii.isAlphanumeric(s[left])) {
            left += 1;
        }
        while (left < right and !std.ascii.isAlphanumeric(s[right])) {
            right -= 1;
        }
        if (std.ascii.toLower(s[left]) != std.ascii.toLower(s[right])) {
            return false;
        }
        left += 1;
        right -= 1;
    }
    return true;
}

pub fn main() !void {}

test "valid palindrome - basic case" {
    const s = "A man, a plan, a canal: Panama";
    const result = isPalindrome(s);
    std.debug.print("Test 'basic case': s={s}, result={}\n", .{ s, result });
    try std.testing.expect(result == true);
}

test "valid palindrome - not a palindrome" {
    const s = "race a car";
    const result = isPalindrome(s);
    std.debug.print("Test 'not a palindrome': s={s}, result={}\n", .{ s, result });
    try std.testing.expect(result == false);
}

test "valid palindrome - empty string" {
    const s = "";
    const result = isPalindrome(s);
    std.debug.print("Test 'empty string': s={s}, result={}\n", .{ s, result });
    try std.testing.expect(result == true);
}

test "valid palindrome - single character" {
    const s = "a";
    const result = isPalindrome(s);
    std.debug.print("Test 'single character': s={s}, result={}\n", .{ s, result });
    try std.testing.expect(result == true);
}

test "valid palindrome - numbers and letters" {
    const s = "12321";
    const result = isPalindrome(s);
    std.debug.print("Test 'numbers and letters': s={s}, result={}\n", .{ s, result });
    try std.testing.expect(result == true);
}
