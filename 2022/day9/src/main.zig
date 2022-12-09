const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const point = struct {
    x: i32,
    y: i32,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;
    var part1: u64 = 0;
    var grid = std.AutoHashMap(point, bool).init(allocator);
    const nTails = 10;
    var snake: [nTails]point = std.mem.zeroes([nTails]point);
    try grid.put(snake[nTails - 1], true);
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var dir = line[0];
        var n = try parseInt(i8, line[2..], 10);
        var i: usize = 0;
        while (i < n) : (i += 1) {
            var h = &snake[0];
            switch (dir) {
                'R' => h.x += 1,
                'L' => h.x -= 1,
                'U' => h.y -= 1,
                'D' => h.y += 1,
                else => unreachable,
            }
            var j: usize = 1;
            while (j < snake.len) : (j += 1) {
                h = &snake[j - 1];
                var t = &snake[j];
                var xdiff = (h.x - t.x);
                var ydiff = (h.y - t.y);
                if (try std.math.absInt(xdiff) < 2 and try std.math.absInt(ydiff) < 2) continue;
                if (t.y != h.y) t.y += std.math.sign(ydiff);
                if (t.x != h.x) t.x += std.math.sign(xdiff);
            }
            try grid.put(snake[nTails - 1], true);
        }
    }
    var iterator = grid.iterator();
    while (iterator.next()) |_| {
        part1 += 1;
    }

    print("{d}\n", .{part1});
}
