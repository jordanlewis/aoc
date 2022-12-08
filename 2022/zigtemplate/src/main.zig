const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const ptr = try allocator.create(i32);
    print("ptr={*}\n", .{ptr});

    var buffer: [1024]u8 = undefined;
    var part1: u64 = 0;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        for (line) |val, i| {
            print("{d}:{d} = {d}\n", .{ nLine, i, val });
        }
        nLine += 1;
    }
    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}
