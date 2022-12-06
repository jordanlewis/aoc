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

    var buffer: [4096]u8 = undefined;
    var part1: u64 = 0;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        for (line) |_, i| {
            if (i < 14) {
                continue;
            }
            var j: u8 = 0;
            var chars: [26]u8 = std.mem.zeroes([26]u8);
            while (j < 14) : (j += 1) {
                try stdout.print("{s}\n", .{[_]u8{line[i - j]}});
                chars[line[i - j] - 'a'] += 1;
            }
            var found = true;
            for (chars) |char| {
                if (char > 1) {
                    found = false;
                    break;
                }
            }
            if (found) {
                try stdout.print("part 1: {}\n", .{i + 1});
                break;
            }
        }
        nLine += 1;
    }
    try stdout.print("part 1: {d}\n", .{part1});
    try stdout.print("part 2: {d}\n", .{part2});
}
