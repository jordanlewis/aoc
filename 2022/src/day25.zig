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

    var buffer: [1024]u8 = undefined;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    var input: i64 = 0;
    const base: i64 = 5;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        var i = line.len;
        var n: i64 = 0;
        var place: i64 = 1;
        while (i > 0) {
            i -= 1;
            var x: i64 = switch (line[i]) {
                '0' => 0,
                '1' => 1,
                '2' => 2,
                '-' => -1,
                '=' => -2,
                else => unreachable,
            };
            n += place * x;
            place = place * base;
        }
        input += n;
        print("{s} = {d}\n", .{ line, n });
    }
    print("Input is {d}\n", .{input});

    //var x: i64 = 3;
    //while (x <= 125) : (x += 1) {
    var diff: i64 = 0;
    var mult: i64 = 1;
    var place: i64 = 1;
    var buf = ArrayList(u8).init(allocator);
    while (true) {
        print("Trying place {d} {d} {d}\n", .{ place, mult, diff });
        if (input >= mult - diff and input <= 2 * mult + diff) {
            if (input <= mult + diff) {
                try buf.append('1');
                input -= mult;
            } else {
                try buf.append('2');
                input -= mult * 2;
            }
            mult = @divExact(mult, base);
            // Found our place
            break;
        }
        place += 1;
        diff += 2 * mult;
        mult *= base;
    }
    //input -= (div * mult);

    while (true) {
        //var sign = std.math.sign(input);
        //var div = @divFloor(std.math.absInt(input) catch unreachable, mult) * sign;
        //print("dividing {d}/{d} = {d}\n", .{ input, mult, div });
        diff -= 2 * mult;
        print("Diff, {d} {d} {d}\n", .{ diff, input, mult });
        if (input >= mult - diff and input <= mult + diff) {
            try buf.append('1');
            input -= mult;
        } else if (input >= mult - diff and input <= 2 * mult + diff) {
            try buf.append('2');
            input -= mult * 2;
        } else if (input <= -(mult - diff) and input >= -(mult + diff)) {
            try buf.append('-');
            input += mult;
        } else if (input <= -(mult - diff) and input >= 2 * -(mult + diff)) {
            try buf.append('=');
            input += mult * 2;
        } else {
            try buf.append('0');
        }
        if (mult == 1) {
            break;
        }
        mult = @divExact(mult, base);
    }
    print("part 1: {s}\n", .{buf.items});
    buf.clearAndFree();
    //}

    // 24
    // 5 => 4 // we write 1-
    //     remainder is now 4
    // 1 => 4 // we write 1-

    //print("part 1: {s}\n", .{buf.items});
    print("part 2: {d}\n", .{part2});
}
