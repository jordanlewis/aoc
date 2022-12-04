const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buffer: [1024]u8 = undefined;
    var part1: u64 = 0;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var iter = std.mem.split(u8, line, ",");
        var l = iter.next().?;
        var liter = std.mem.split(u8, l, "-");
        var r = iter.next().?;
        var riter = std.mem.split(u8, r, "-");
        const a = (try std.fmt.parseInt(i32, liter.next().?, 10));
        const b = (try std.fmt.parseInt(i32, liter.next().?, 10));
        const c = (try std.fmt.parseInt(i32, riter.next().?, 10));
        const d = (try std.fmt.parseInt(i32, riter.next().?, 10));
        try stdout.print("{d} {d} {d} {d}\n", .{ a, b, c, d });

        if ((a <= c and b >= d) or (c <= a and d >= b)) {
            part1 += 1;
        }

        if ((a >= c and a <= d) or (b >= c and b <= d) or (c >= a and c <= b) or (d >= a and d <= b)) {
            part2 += 1;
        }
        nLine += 1;
    }
    try stdout.print("part 1: {d}\n", .{part1});
    try stdout.print("part 2: {d}\n", .{part2});
}
