const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();

    var curCalories: u64 = 0;
    var buffer: [1024]u8 = undefined;
    var allCalories: [1024]u64 = undefined;
    var i: usize = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        if (line.len == 0) {
            allCalories[i] = curCalories;
            i += 1;
            curCalories = 0;
            continue;
        }
        curCalories += try std.fmt.parseInt(u64, line, 10);
    }
    std.sort.sort(u64, allCalories[0..i], {}, comptime std.sort.desc(u64));
    print("part 1: {d}\n", .{allCalories[0]});

    // Part 2.
    var topThreeCaloriesSum: u64 = 0;
    for (allCalories[0..3]) |n| {
        topThreeCaloriesSum += n;
    }
    print("part 2: {d}\n", .{topThreeCaloriesSum});
}
