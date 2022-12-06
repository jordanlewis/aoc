const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const ptr = try allocator.create(i32);
    std.debug.print("ptr={*}\n", .{ptr});

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
