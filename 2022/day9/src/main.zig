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
    const ptr = try allocator.create(i32);
    print("ptr={*}\n", .{ptr});

    var buffer: [1024]u8 = undefined;
    var part1: u64 = 0;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    var grid = std.AutoHashMap(point, bool).init(allocator);
    const nTails = 10;
    var snake: [nTails]point = std.mem.zeroes([nTails]point);
    try grid.put(snake[nTails - 1], true);
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        var iter = tokenize(u8, line, " ");
        var dir = iter.next().?;
        var n = try parseInt(i8, iter.next().?, 10);
        var i: usize = 0;
        while (i < n) : (i += 1) {
            var h = &snake[0];
            switch (dir[0]) {
                'R' => h.x += 1,
                'L' => h.x -= 1,
                'U' => h.y -= 1,
                'D' => h.y += 1,
                else => unreachable,
            }
            print("head {s}\n", .{dir});
            var j: usize = 1;
            while (j < snake.len) : (j += 1) {
                h = &snake[j - 1];
                var t = &snake[j];
                var xdiff = (h.x - t.x);
                var ydiff = (h.y - t.y);
                if (xdiff >= -1 and xdiff <= 1 and ydiff >= -1 and ydiff <= 1) {
                    continue;
                }
                if (t.y < h.y) {
                    t.y += 1;
                } else if (t.y > h.y) {
                    t.y -= 1;
                }
                if (t.x < h.x) {
                    t.x += 1;
                } else if (t.x > h.x) {
                    t.x -= 1;
                }
                print("moving {} -> {},{}\n", .{ j, t.x, t.y });
            }
            try grid.put(snake[nTails - 1], true);
        }
        print("{s}, {}\n", .{ dir, n });
    }
    var iterator = grid.iterator();
    while (iterator.next()) |_| {
        part1 += 1;
    }

    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}
