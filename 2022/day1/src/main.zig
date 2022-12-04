const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var mostCalories: i64 = 0;
    var curCalories: i64 = 0;
    var buffer: [1024]u8 = undefined;
    var allCalories: [1024]i64 = undefined;
    var i: usize = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        if (line.len == 0) {
            if (curCalories > mostCalories) {
                mostCalories = curCalories;
            }
            allCalories[i] = curCalories;
            i += 1;
            curCalories = 0;
            continue;
        }
        const n = (try std.fmt.parseInt(i32, line, 10));
        curCalories += n;
    }
    try stdout.print("top elf carries: {d}\n", .{mostCalories});

    // Part 2.
    var topThreeCaloriesSum: i64 = mostCalories;
    std.sort.sort(i64, &allCalories, {}, comptime std.sort.desc(i64));
    topThreeCaloriesSum += allCalories[1];
    topThreeCaloriesSum += allCalories[2];
    try stdout.print("top 3 elves carry: {d}\n", .{topThreeCaloriesSum});
}
