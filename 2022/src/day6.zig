const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [4096]u8 = undefined;
    _ = try stdin.readAll(buffer[0..]);

    inline for ([_]u8{4, 14}) |n, part| {
        var chars = std.mem.zeroes([26]u8);
        var dupes: u8 = 0;
        for (buffer[0..n]) |x| {
            chars[x-'a'] += 1;
            if (chars[x-'a'] > 1) {
                dupes += 1;
            }
        }
        for (buffer[n..]) |x, i| {
            var beg = buffer[i] - 'a';
            var end = x - 'a';
            if (chars[beg] > 1) {
                dupes -= 1;
            }
            chars[beg] -= 1;
            chars[end] += 1;
            if (chars[end] > 1) {
                dupes += 1;
            }
            if (dupes == 0) {
                print("part {d}: {d}\n", .{part+1, i + n + 1});
                break;
            }
        }
    }
}
