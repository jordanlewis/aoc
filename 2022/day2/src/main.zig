const std = @import("std");

const rps = enum(u8) {
    rock,
    paper,
    scissors,
    pub fn str(self: rps) []const u8 {
        return switch (self) {
            rps.rock => "rock",
            rps.paper => "paper",
            rps.scissors => "scissors",
        };
    }
};

pub fn parseRps(in: u8) !rps {
    return switch (in) {
        'A', 'X' => rps.rock,
        'B', 'Y' => rps.paper,
        'C', 'Z' => rps.scissors,
        else => unreachable,
    };
}

// 0 if loss, 3 if draw, 6 if won
var rpsScores: [3][3]u8 = .{ .{ 3, 0, 6 }, .{ 6, 3, 0 }, .{ 0, 6, 3 } };

pub fn evalRps(l: rps, r: rps) u8 {
    const i = @enumToInt(l);
    const j = @enumToInt(r);
    return rpsScores[i][j];
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buffer: [1024]u8 = undefined;
    var scoreSum: i64 = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        const them = try parseRps(line[0]);
        const us = try parseRps(line[2]);
        const score = evalRps(us, them);
        // The score is the ordinal value of the RPS, plus the score.
        // Add 1 since the enum is 0-indexed.
        const total = @enumToInt(us) + 1 + score;
        scoreSum += total;
    }
    try stdout.print("{d}\n", .{scoreSum});
}
