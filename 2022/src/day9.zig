const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const point = @Vector(2, i32);

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var input = try stdin.readAllAlloc(allocator, 1<<20);

    inline for ([_]usize{2, 10}) |nTails, part| {
        var grid = std.AutoHashMap(point, void).init(allocator);
        defer grid.deinit();

        var snake: [nTails]point = std.mem.zeroes([nTails]point);
        try grid.put(snake[nTails - 1], {});
        var lines = std.mem.tokenize(u8, input, "\n");
        while (lines.next()) |line| {
            var dir = line[0];
            var n = try parseInt(i8, line[2..], 10);
            var i: usize = 0;
            while (i < n) : (i += 1) {
                var h = &snake[0];
                switch (dir) {
                    'R' => h.*[0] += 1,
                    'L' => h.*[0] -= 1,
                    'U' => h.*[1] -= 1,
                    'D' => h.*[1] += 1,
                    else => unreachable,
                }
                var j: usize = 1;
                while (j < snake.len) : (j += 1) {
                    var t = &snake[j];
                    var diff = snake[j-1] - t.*;
                    var abs = @select(i32, diff < @splat(2, @as(i32, 0)), -diff, diff);
                    var skip = abs < @splat(2, @as(i32, 2));
                    if (@reduce(.And, skip)) continue;
                    t.* += std.math.sign(diff);
                }
                try grid.put(snake[nTails - 1], {});
            }
        }
        print("part {d}: {d}\n", .{part + 1, grid.count()});
    }
}
