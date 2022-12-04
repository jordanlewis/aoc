const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buffer: [1024]u8 = undefined;
    var part1: u64 = 0;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        for (line) |val, i| {
            try stdout.print("{d}:{d} = {d}\n", .{ nLine, i, val });
        }
        nLine += 1;
    }
    try stdout.print("part 1: {d}\n", .{part1});
    try stdout.print("part 2: {d}\n", .{part2});
}
