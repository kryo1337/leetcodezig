const std = @import("std");
const Allocator = std.mem.Allocator;

const Tweet = struct {
    id: i32,
    timestamp: i32,
    next: ?*Tweet = null,
};

const User = struct {
    id: i32,
    tweets: ?*Tweet = null,
    following: std.AutoHashMap(i32, void),
};

const TweetNode = struct {
    tweet: *Tweet,
    fn compare(context: void, a: TweetNode, b: TweetNode) std.math.Order {
        _ = context;
        return std.math.order(b.tweet.timestamp, a.tweet.timestamp);
    }
};

pub const Twitter = struct {
    allocator: Allocator,
    users: std.AutoHashMap(i32, *User),
    timestamp: i32,

    pub fn init(allocator: Allocator) !*Twitter {
        var self = try allocator.create(Twitter);
        self.allocator = allocator;
        self.users = std.AutoHashMap(i32, *User).init(allocator);
        self.timestamp = 0;
        return self;
    }

    pub fn deinit(self: *Twitter) void {
        var it = self.users.iterator();
        while (it.next()) |entry| {
            var user = entry.value_ptr.*;
            user.following.deinit();
            var tweet = user.tweets;
            while (tweet) |t| {
                const next = t.next;
                self.allocator.destroy(t);
                tweet = next;
            }
            self.allocator.destroy(user);
        }
        self.users.deinit();
        self.allocator.destroy(self);
    }

    fn getOrCreateUser(self: *Twitter, userId: i32) !*User {
        if (self.users.get(userId)) |user| {
            return user;
        }
        var user = try self.allocator.create(User);
        user.id = userId;
        user.tweets = null;
        user.following = std.AutoHashMap(i32, void).init(self.allocator);
        try self.users.put(userId, user);
        return user;
    }

    pub fn postTweet(self: *Twitter, userId: i32, tweetId: i32) !void {
        var user = try self.getOrCreateUser(userId);
        var tweet = try self.allocator.create(Tweet);
        tweet.id = tweetId;
        tweet.timestamp = self.timestamp;
        self.timestamp += 1;
        tweet.next = user.tweets;
        user.tweets = tweet;
    }

    pub fn getNewsFeed(self: *Twitter, userId: i32) ![]i32 {
        const user = try self.getOrCreateUser(userId);
        
        var heap = std.PriorityQueue(TweetNode, void, TweetNode.compare).init(self.allocator, {});
        defer heap.deinit();

        var tweet = user.tweets;
        while (tweet) |t| {
            heap.add(.{ .tweet = t }) catch unreachable;
            tweet = t.next;
        }
        var it = user.following.iterator();
        while (it.next()) |entry| {
            const followeeId = entry.key_ptr.*;
            if (self.users.get(followeeId)) |followee| {
                tweet = followee.tweets;
                while (tweet) |t| {
                    heap.add(.{ .tweet = t }) catch unreachable;
                    tweet = t.next;
                }
            }
        }
        var result = try self.allocator.alloc(i32, @min(heap.count(), 10));
        var i: usize = 0;
        while (i < result.len and heap.count() > 0) {
            const node = heap.remove();
            result[i] = node.tweet.id;
            i += 1;
        }
        return result;
    }

    pub fn follow(self: *Twitter, followerId: i32, followeeId: i32) !void {
        if (followerId == followeeId) return;
        var follower = try self.getOrCreateUser(followerId);
        _ = try follower.following.getOrPut(followeeId);
    }

    pub fn unfollow(self: *Twitter, followerId: i32, followeeId: i32) !void {
        if (followerId == followeeId) return;
        if (self.users.get(followerId)) |follower| {
            _ = follower.following.remove(followeeId);
        }
    }
};

pub fn main() !void {}

test "twitter - basic operations" {
    const allocator = std.testing.allocator;
    var twitter = try Twitter.init(allocator);
    defer twitter.deinit();

    try twitter.postTweet(1, 5);
    try twitter.postTweet(1, 3);

    const feed = try twitter.getNewsFeed(1);
    defer allocator.free(feed);
    try std.testing.expectEqual(@as(usize, 2), feed.len);
    try std.testing.expectEqual(@as(i32, 3), feed[0]);
    try std.testing.expectEqual(@as(i32, 5), feed[1]);
}

test "twitter - follow operations" {
    const allocator = std.testing.allocator;
    var twitter = try Twitter.init(allocator);
    defer twitter.deinit();

    try twitter.postTweet(1, 5);
    try twitter.postTweet(2, 6);

    try twitter.follow(1, 2);

    const feed = try twitter.getNewsFeed(1);
    defer allocator.free(feed);
    try std.testing.expectEqual(@as(usize, 2), feed.len);
    try std.testing.expectEqual(@as(i32, 6), feed[0]);
    try std.testing.expectEqual(@as(i32, 5), feed[1]);
}

test "twitter - unfollow operations" {
    const allocator = std.testing.allocator;
    var twitter = try Twitter.init(allocator);
    defer twitter.deinit();

    try twitter.postTweet(1, 5);
    try twitter.postTweet(2, 6);

    try twitter.follow(1, 2);
    try twitter.unfollow(1, 2);

    const feed = try twitter.getNewsFeed(1);
    defer allocator.free(feed);
    try std.testing.expectEqual(@as(usize, 1), feed.len);
    try std.testing.expectEqual(@as(i32, 5), feed[0]);
}

test "twitter - multiple followees" {
    const allocator = std.testing.allocator;
    var twitter = try Twitter.init(allocator);
    defer twitter.deinit();

    try twitter.postTweet(1, 1);
    try twitter.postTweet(2, 2);
    try twitter.postTweet(3, 3);
    try twitter.postTweet(4, 4);

    try twitter.follow(1, 2);
    try twitter.follow(1, 3);
    try twitter.follow(1, 4);

    const feed = try twitter.getNewsFeed(1);
    defer allocator.free(feed);
    try std.testing.expectEqual(@as(usize, 4), feed.len);
    try std.testing.expectEqual(@as(i32, 4), feed[0]);
    try std.testing.expectEqual(@as(i32, 3), feed[1]);
    try std.testing.expectEqual(@as(i32, 2), feed[2]);
    try std.testing.expectEqual(@as(i32, 1), feed[3]);
}

test "twitter - non-existent user" {
    const allocator = std.testing.allocator;
    var twitter = try Twitter.init(allocator);
    defer twitter.deinit();

    const feed = try twitter.getNewsFeed(999);
    defer allocator.free(feed);
    try std.testing.expectEqual(@as(usize, 0), feed.len);

    try twitter.follow(1, 999);
    try twitter.postTweet(1, 1);
    const feed2 = try twitter.getNewsFeed(1);
    defer allocator.free(feed2);
    try std.testing.expectEqual(@as(usize, 1), feed2.len);
    try std.testing.expectEqual(@as(i32, 1), feed2[0]);
}