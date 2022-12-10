const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

var part1: i64 = 0;
pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [1024]u8 = undefined;
    var nLine: u64 = 0;
    var cycle: u64 = 0;
    var x: i64 = 1;
    var screen: [6][40]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        var iter = tokenize(u8, line, " ");
        var instr = iter.next().?;
        if (instr[0] == 'n') {
            cycle += 1;
            checkCycle(&screen, cycle, x);
        } else {
            var max: u64 = cycle + 2;
            while (cycle < max) {
                cycle += 1;
                checkCycle(&screen, cycle, x);
            }
            var n = try parseInt(i8, iter.next().?, 10);
            x += n;
        }
    }
    print("part 1: {d}\n", .{part1});
    for (screen) |line| {
        print("{s}\n", .{line});
    }
}

fn checkCycle(screen: *[6][40]u8, cycle: u64, x: i64) void {
    var i: usize = (cycle - 1) / 40;
    var j: usize = (cycle - 1) % 40;
    if (j == x or x - 1 == j or x + 1 == j) {
        screen[i][j] = '#';
    } else {
        screen[i][j] = ' ';
    }
    if ((cycle + 20) % 40 == 0) {
        part1 += @intCast(i64, cycle) * x;
    }
}
