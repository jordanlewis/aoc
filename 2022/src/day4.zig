const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [1024]u8 = undefined;
    var part1: u64 = 0;
    var part2: u64 = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var iter = std.mem.tokenize(u8, line, ",-");
        const a = (try std.fmt.parseInt(i32, iter.next().?, 10));
        const b = (try std.fmt.parseInt(i32, iter.next().?, 10));
        const c = (try std.fmt.parseInt(i32, iter.next().?, 10));
        const d = (try std.fmt.parseInt(i32, iter.next().?, 10));

        if ((a <= c and b >= d) or (c <= a and d >= b)) {
            part1 += 1;
        }

        if (!(b < c or a > d)) {
            part2 += 1;
        }
    }
    print("part 1: {d}\npart 2: {d}\n", .{part1, part2});
}