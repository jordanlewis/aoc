const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buffer: [1024]u8 = undefined;
    var prioritiesSum: u64 = 0;
    var nSack: u64 = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var sack: [2][52]u8 = std.mem.zeroes([2][52]u8);
        for (line) |val, i| {
            // Convert letters to integer priorities (0-indexed).
            // a-z is 0-25; A-Z is 26-51.
            var idx: u8 = undefined;
            if (val > 'a') {
                idx = val - 'a';
            } else {
                idx = val - 'A' + 26;
            }
            var compartment: u1 = 0;
            if (i >= line.len / 2) {
                compartment = 1;
            }
            sack[compartment][idx] += 1;
        }

        for (sack[0]) |n, i| {
            if (n > 0 and sack[1][i] > 0) {
                // Priorities in the puzzle are 1-indexed; we have 0-indexed.
                prioritiesSum += i + 1;
                //try stdout.print("sack {d}: {d}\n", .{ nSack, i + 1 });
            }
        }
        nSack += 1;
    }
    try stdout.print("part 1: {d}\n", .{prioritiesSum});
}
