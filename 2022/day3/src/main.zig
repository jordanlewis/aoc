const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buffer: [1024]u8 = undefined;
    var prioritiesSum: u64 = 0;
    var part2PrioritiesSum: u64 = 0;
    var nGroup: u2 = 0;
    var groupSacks = std.mem.zeroes([3][52]u8);
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var sack = std.mem.zeroes([2][52]u8);
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
            groupSacks[nGroup][idx] += 1;
        }

        for (sack[0]) |n, i| {
            if (n > 0 and sack[1][i] > 0) {
                // Priorities in the puzzle are 1-indexed; we have 0-indexed.
                prioritiesSum += i + 1;
            }
        }

        // Part 2.
        nGroup += 1;
        if (nGroup > 2) {
            // Calculate the badge (common item) in the group's sacks.
            for (groupSacks[0]) |n, i| {
                if (n > 0 and groupSacks[1][i] > 0 and groupSacks[2][i] > 0) {
                    // Badge found.
                    part2PrioritiesSum += i + 1;
                }
            }
            // Clear the group's sack memory.
            groupSacks = std.mem.zeroes([3][52]u8);
            nGroup = 0;
        }
    }
    try stdout.print("part 1: {d}\n", .{prioritiesSum});
    try stdout.print("part 2: {d}\n", .{part2PrioritiesSum});
}
