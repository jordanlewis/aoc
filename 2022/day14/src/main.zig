const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const slot = enum {
    empty,
    sand,
    rock,
};

const point = struct {
    x: u64, 
    y: u64,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const ptr = try allocator.create(i32);
    print("ptr={*}\n", .{ptr});

    var buffer: [1024]u8 = undefined;
    var grid: [170][700]slot = std.mem.zeroes([170][700]slot);
    var part1: u64 = 0;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    var maxY: u64 = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        var iter = tokenize(u8, line, " ");
        var lastPoint = point{.x = 0, .y = 0};
        var newPoint = point{.x = 0, .y = 0};
        while (iter.next()) |word| {
            if (word[0] == '-') {
                // it's an arrow (->)
                continue;
            }
            var commaIter = tokenize(u8, word, ",");
            newPoint.x = try parseInt(u64, commaIter.next().?, 10);
            newPoint.y = try parseInt(u64, commaIter.next().?, 10);
            if (newPoint.y > maxY) {
                maxY = newPoint.y;
            }
            if (std.meta.eql(lastPoint, point{.x = 0, .y = 0})) {
                lastPoint = newPoint;
                continue;
            }
            // Now create a line of rocks in our grid.
            if (newPoint.x == lastPoint.x) {
                // Line on the x axis.
                var y1 = newPoint.y;
                var y2 = lastPoint.y;
                if (y1 > y2) {
                    var tmp = y1;
                    y1 = y2;
                    y2 = tmp;
                }
                while (y1 <= y2) : (y1 += 1) {
                    grid[y1][newPoint.x] = slot.rock;
                }
            } else if (newPoint.y == lastPoint.y) {
                // Line on the y axis.
                var x1 = newPoint.x;
                var x2 = lastPoint.x;
                if (x1 > x2) {
                    var tmp = x1;
                    x1 = x2;
                    x2 = tmp;
                }
                while (x1 <= x2) : (x1 += 1) {
                    grid[newPoint.y][x1] = slot.rock;
                }
            }
            lastPoint = newPoint;
        }
    }
    maxY += 2;
    print("found max y {d}\n", .{maxY});

    var sand = point{.x=500,.y=0};
    while (true) {
        if (sand.y >= maxY - 1) {
            // Reached the floor.
            grid[sand.y][sand.x] = slot.sand;
            sand = point{.x=500,.y=0};
            part1 += 1;
            continue;
        }
        // Loop while there's still space for sand to fall.
        if (grid[sand.y+1][sand.x] == slot.empty) {
            sand.y += 1;
        } else if (grid[sand.y+1][sand.x-1] == slot.empty) {
            sand.y += 1;
            sand.x -= 1;
        } else if (grid[sand.y+1][sand.x+1] == slot.empty) {
            sand.y += 1;
            sand.x += 1;
        } else {
            // Our sand is trapped, so set it in the grid and reset the sand to the top.
            grid[sand.y][sand.x] = slot.sand;
            part1 += 1;
            //print("sand trapped at {d},{d} ({d})\n", .{sand.x, sand.y, part1});
            if (sand.x == 500 and sand.y == 0) {
                // We're unable to move our sand any longer, so exit the loop.
                break;
            }
            sand = point{.x=500,.y=0};
        }
    }

    //for (grid) |line| {
    //    for (line) |pt| {
    //        switch (pt) {
    //            .empty => print(".", .{}),
    //            .rock => print("#", .{}),
    //            .sand => print("o", .{}),
    //        }
    //    }
    //    print("\n", .{});
    //}
    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}
