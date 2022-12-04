const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var mostCalories: i64 = 0;
    var curCalories: i64 = 0;
    var buffer: [1024]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        if (line.len == 0) {
            if (curCalories > mostCalories) {
                mostCalories = curCalories;
            }
            curCalories = 0;
            continue;
        }
        const i = (try std.fmt.parseInt(i32, line, 10));
        curCalories += i;
    }
    try stdout.print("{d}\n", .{mostCalories});
}
