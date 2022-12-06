const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [4096]u8 = undefined;
    _ = try stdin.readAll(buffer[0..]);
    outer: for (buffer[14..]) |_, i| {
        var j: u8 = 0;
        var chars: [26]u2 = std.mem.zeroes([26]u2);
        while (j < 14) : (j += 1) {
            var x: *u2 = &chars[buffer[i + 14 - j] - 'a'];
            x.* += 1;
            if (x.* > 1) continue :outer;
        }
        std.debug.print("{}\n", .{i + 15});
        break;
    }
}
